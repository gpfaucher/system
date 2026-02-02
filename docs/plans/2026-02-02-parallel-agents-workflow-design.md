# Parallel Claude Code Agents Workflow Design

**Date**: 2026-02-02
**Status**: Ready for Implementation

## Overview

A workflow for running 5+ Claude Code agents in parallel, each working on independent features using git worktrees, with full Linear/GitHub integration and automated cleanup.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Terminal Window: feature-auth (one per feature)             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Zellij Session (locked mode - keys pass to nvim)        │ │
│ │ ┌─────────────────────────┬───────────────────────────┐ │ │
│ │ │                         │ Claude Code               │ │ │
│ │ │   Neovim                │ (coder/claudecode.nvim)   │ │ │
│ │ │   + claudecode.nvim     ├───────────────────────────┤ │ │
│ │ │                         │ Shell / Dev Server        │ │ │
│ │ │                         │ (port 300X pre-configured)│ │ │
│ │ └─────────────────────────┴───────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

× 5+ parallel instances (one terminal window per feature)
```

## Components

### 1. Zellij Configuration (`modules/home/zellij.nix`)

Restore minimal UI config from git history:

```nix
{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_layout = "compact";
      pane_frames = false;
      simplified_ui = true;
      hide_session_name = true;
      show_startup_tips = false;
      mouse_mode = false;
      default_mode = "locked";  # Ctrl+g to unlock for zellij management
      keybinds = {
        unbind = [ "Ctrl h" ];  # Don't conflict with nvim window nav
      };
    };
  };

  # Agent layout for spawn-agent
  xdg.configFile."zellij/layouts/agent.kdl".text = ''
    layout {
      pane size=1 borderless=true {
        plugin location="compact-bar"
      }
      pane split_direction="vertical" {
        pane size="60%" command="nvim"
        pane split_direction="horizontal" {
          pane size="60%" command="claude"
          pane  // shell for dev server
        }
      }
    }
  '';
}
```

### 2. Neovim Claude Code Integration (`modules/home/nvf.nix`)

Add coder/claudecode.nvim:

```nix
# At top of file, add plugin fetch
claudecode-nvim = pkgs.vimUtils.buildVimPlugin {
  pname = "claudecode-nvim";
  version = "unstable-2026-02-02";
  src = pkgs.fetchFromGitHub {
    owner = "coder";
    repo = "claudecode.nvim";
    rev = "main";
    sha256 = ""; # Will need to get actual hash
  };
  dependencies = [ pkgs.vimPlugins.snacks-nvim ];
  doCheck = false;
  meta.homepage = "https://github.com/coder/claudecode.nvim";
};

# In extraPlugins section
claudecode = {
  package = claudecode-nvim;
  setup = ''
    require("claudecode").setup({
      auto_start = true,
      terminal = {
        split_side = "right",
        split_width_percentage = 0.4,
        provider = "snacks",
      },
      diff = {
        enabled = true,
        auto_close_on_accept = true,
      },
    })
  '';
};

# Add keybindings
keymaps = [
  # ... existing keymaps ...

  # Claude Code
  {
    key = "<leader>cc";
    mode = "n";
    action = "<cmd>ClaudeCodeToggle<cr>";
    desc = "Toggle Claude Code";
  }
  {
    key = "<leader>cs";
    mode = "n";
    action = "<cmd>ClaudeCodeSend<cr>";
    desc = "Send to Claude";
  }
  {
    key = "<leader>cs";
    mode = "v";
    action = "<cmd>ClaudeCodeSend<cr>";
    desc = "Send selection to Claude";
  }
  {
    key = "<leader>ca";
    mode = "n";
    action = "<cmd>ClaudeCodeAdd<cr>";
    desc = "Add file to Claude context";
  }
  {
    key = "<leader>ct";
    mode = "n";
    action = "<cmd>ClaudeCodeTreeAdd<cr>";
    desc = "Add from file tree";
  }
];

# Update which-key groups
{ "<leader>c", group = "Claude/Code" },
```

### 3. Spawn Agent Script (`modules/home/claude-code.nix`)

Add to claude-code.nix:

```nix
{ config, pkgs, lib, ... }:

let
  # Spawn agent script
  spawn-agent = pkgs.writeShellScriptBin "spawn-agent" ''
    set -euo pipefail

    usage() {
      echo "Usage: spawn-agent [--linear ISSUE_ID] <branch-name> [base-branch]"
      echo ""
      echo "Options:"
      echo "  --linear ISSUE_ID   Fetch issue from Linear, use for branch naming"
      echo ""
      echo "Examples:"
      echo "  spawn-agent feature/auth main"
      echo "  spawn-agent --linear LIN-123"
      exit 1
    }

    LINEAR_ISSUE=""
    BRANCH_NAME=""
    BASE_BRANCH=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
      case $1 in
        --linear)
          LINEAR_ISSUE="$2"
          shift 2
          ;;
        -h|--help)
          usage
          ;;
        *)
          if [[ -z "$BRANCH_NAME" ]]; then
            BRANCH_NAME="$1"
          elif [[ -z "$BASE_BRANCH" ]]; then
            BASE_BRANCH="$1"
          fi
          shift
          ;;
      esac
    done

    # If Linear issue provided, fetch details
    if [[ -n "$LINEAR_ISSUE" ]]; then
      echo "Fetching Linear issue $LINEAR_ISSUE..."
      # Claude will handle this via MCP when the session starts
      BRANCH_NAME="$LINEAR_ISSUE"
    fi

    if [[ -z "$BRANCH_NAME" ]]; then
      usage
    fi

    # Determine base branch
    if [[ -z "$BASE_BRANCH" ]]; then
      BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    fi

    # Sanitize branch name for directory
    SAFE_NAME=$(echo "$BRANCH_NAME" | tr '/' '-' | tr '[:upper:]' '[:lower:]')
    REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
    WORKTREE_DIR=".worktrees/$SAFE_NAME"

    # Calculate port (based on number of existing worktrees)
    WORKTREE_COUNT=$(git worktree list | wc -l)
    PORT=$((3000 + WORKTREE_COUNT))

    echo "Creating worktree: $WORKTREE_DIR"
    echo "Branch: $BRANCH_NAME (from $BASE_BRANCH)"
    echo "Port: $PORT"

    # Create worktree
    git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" "$BASE_BRANCH" 2>/dev/null || \
      git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"

    # Copy environment files
    echo "Copying environment files..."
    for envfile in .env .env.local .env.development .env.development.local .envrc; do
      if [[ -f "$envfile" ]]; then
        cp "$envfile" "$WORKTREE_DIR/"
        echo "  Copied $envfile"
      fi
    done

    # Copy nested .env files (monorepo support)
    find . -maxdepth 4 \( -name ".env*" -o -name ".envrc" \) \
      ! -path "./node_modules/*" \
      ! -path "./.worktrees/*" \
      ! -path "./.git/*" 2>/dev/null | while read -r envfile; do
      dir=$(dirname "$envfile")
      mkdir -p "$WORKTREE_DIR/$dir"
      cp "$envfile" "$WORKTREE_DIR/$envfile" 2>/dev/null || true
    done

    # Set unique port in .env.local
    echo "" >> "$WORKTREE_DIR/.env.local"
    echo "# Auto-configured by spawn-agent" >> "$WORKTREE_DIR/.env.local"
    echo "PORT=$PORT" >> "$WORKTREE_DIR/.env.local"
    echo "VITE_PORT=$PORT" >> "$WORKTREE_DIR/.env.local"
    echo "NEXT_PORT=$PORT" >> "$WORKTREE_DIR/.env.local"

    # Copy IDE/editor settings
    for dir in .idea .vscode .claude; do
      if [[ -d "$dir" ]]; then
        cp -r "$dir" "$WORKTREE_DIR/"
      fi
    done

    # Create CLAUDE.md with context if Linear issue
    if [[ -n "$LINEAR_ISSUE" ]]; then
      cat > "$WORKTREE_DIR/.claude/AGENT_CONTEXT.md" << EOF
    # Agent Context

    Linear Issue: $LINEAR_ISSUE
    Branch: $BRANCH_NAME
    Port: $PORT

    On startup, fetch the Linear issue details and understand the task.
    EOF
    fi

    # Install dependencies
    cd "$WORKTREE_DIR"
    if [[ -f "pnpm-lock.yaml" ]]; then
      echo "Installing dependencies with pnpm..."
      pnpm install
    elif [[ -f "yarn.lock" ]]; then
      echo "Installing dependencies with yarn..."
      yarn install
    elif [[ -f "package-lock.json" ]]; then
      echo "Installing dependencies with npm..."
      npm install
    elif [[ -f "requirements.txt" ]]; then
      echo "Installing Python dependencies..."
      pip install -r requirements.txt
    elif [[ -f "pyproject.toml" ]]; then
      echo "Installing Python project..."
      pip install -e .
    fi

    # Open new terminal window with zellij
    echo ""
    echo "Launching agent environment..."
    echo "  Worktree: $WORKTREE_DIR"
    echo "  Port: $PORT"
    echo ""

    # Launch in new terminal window
    # ghostty is the default terminal
    ghostty --working-directory="$(pwd)" -e zellij --layout agent --session "$SAFE_NAME" &

    echo "Agent spawned! Switch to the new terminal window."
  '';

  # Cleanup script for pre-commit hook
  cleanup-code = pkgs.writeShellScriptBin "claude-cleanup" ''
    set -euo pipefail

    # Get staged files
    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|jsx|ts|tsx|py|go|rs)$' || true)

    if [[ -z "$STAGED_FILES" ]]; then
      exit 0
    fi

    echo "Cleaning up staged files..."

    for file in $STAGED_FILES; do
      if [[ -f "$file" ]]; then
        # Remove debug console.logs (but keep intentional ones)
        sed -i 's/console\.log(.*DEBUG.*);//g' "$file" 2>/dev/null || true

        # Remove // TODO: remove comments
        sed -i '/\/\/ TODO: remove/d' "$file" 2>/dev/null || true
        sed -i '/# TODO: remove/d' "$file" 2>/dev/null || true

        # Remove temporary variable suffixes
        # _old, _backup, _temp, _test, _optimized, _new, _v2
        # Only in variable names, not in strings
        # This is conservative - only catches obvious patterns

        # Re-stage the file if modified
        git add "$file"
      fi
    done
  '';

in
{
  # ... existing claude-code.nix content ...

  # Add scripts to PATH
  home.packages = [
    spawn-agent
    cleanup-code
  ];
}
```

### 4. Linear MCP Configuration

Add to claude-code.nix `claudeJsonContent`:

```nix
claudeJsonContent = builtins.toJSON {
  mcpServers = {
    # ... existing servers ...

    linear = {
      command = "npx";
      args = [ "-y" "@anthropic/mcp-linear" ];
      # Or use official Linear MCP:
      # transport = "http";
      # url = "https://mcp.linear.app/mcp";
    };
  };
};
```

### 5. Hooks Configuration

Add to claude-code.nix `claudeSettingsContent`:

```nix
claudeSettingsContent = builtins.toJSON {
  # ... existing settings ...

  hooks = {
    PreToolUse = [
      {
        matcher = "Bash(git commit*)";
        command = "claude-cleanup";
      }
    ];
  };
};
```

### 6. Updated Skills

Add to `skills` in claude-code.nix:

```nix
skills = {
  # ... existing skills ...

  spawn-agent = ''
    ---
    name: spawn-agent
    description: Create a new parallel agent environment with git worktree
    ---

    # Spawn Agent

    Create a new isolated development environment for a feature.

    ## Usage

    ```bash
    spawn-agent [--linear ISSUE_ID] <branch-name> [base-branch]
    ```

    ## Examples

    ```bash
    # Simple feature branch
    spawn-agent feature/user-auth main

    # From Linear issue (fetches details automatically)
    spawn-agent --linear LIN-123
    ```

    ## What It Does

    1. Creates git worktree at `.worktrees/<branch-name>`
    2. Copies all `.env*` files (including nested for monorepos)
    3. Configures unique port (3001, 3002, etc.) in `.env.local`
    4. Installs dependencies (pnpm/yarn/npm/pip)
    5. Opens new terminal with zellij layout:
       - Left: Neovim with claudecode.nvim
       - Top-right: Claude Code
       - Bottom-right: Shell for dev server

    ## After Spawning

    - Switch to the new terminal window
    - Claude is ready with workspace context
    - Run dev server: `pnpm dev` (port is pre-configured)
    - If Linear issue: Claude will fetch and understand the task
  '';

  pr = ''
    ---
    name: pr
    description: Create a pull request with self-review
    ---

    # Create Pull Request

    ## Pre-flight

    1. Run tests and lint
    2. Review your own changes for:
       - Debug code / console.logs
       - Temporary names (*_old, *_optimized, *_temp)
       - TODO comments that should be removed
       - Hardcoded values that should be env vars

    ## Create PR

    1. Stage and commit with conventional commit message
    2. Push to remote: `git push -u origin HEAD`
    3. Create PR:

    ```bash
    gh pr create --title "type: description" --body "$(cat <<'EOF'
    ## Summary
    - Brief description

    ## Changes
    - List changes

    ## Test Plan
    - [ ] Tests pass
    - [ ] Manual testing done

    ## Linear Issue
    Closes LIN-XXX (if applicable)
    EOF
    )"
    ```

    ## Self-Review

    After creating the PR, review it yourself:

    ```bash
    gh pr diff
    ```

    Check for:
    - [ ] Security issues (secrets, SQL injection, XSS)
    - [ ] Missing error handling
    - [ ] Missing tests for new code paths
    - [ ] Code style consistency

    Post a self-review comment with any findings.
  '';
};
```

### 7. Update default.nix

```nix
# In modules/home/default.nix, add:
imports = [
  # ... existing imports ...
  ./zellij.nix
];
```

## Workflow

### Starting Work on a Feature

```bash
# From main repo
spawn-agent --linear LIN-456

# Or without Linear
spawn-agent feature/new-api main
```

### In the Spawned Environment

1. **Zellij opens** with nvim (left), claude (top-right), shell (bottom-right)
2. **Claude has context** via claudecode.nvim WebSocket
3. **Work on feature** - Claude can read/edit via nvim, see diagnostics
4. **Test**: In shell pane, `pnpm dev` runs on pre-assigned port
5. **Create PR**: `/pr` skill handles commit, push, PR creation, self-review

### Cleanup

```bash
# When done with a feature
git worktree remove .worktrees/feature-name
git branch -d feature-name  # if merged
```

## File Summary

| File | Action |
|------|--------|
| `modules/home/zellij.nix` | Create (new file) |
| `modules/home/nvf.nix` | Edit (add claudecode.nvim) |
| `modules/home/claude-code.nix` | Edit (add scripts, Linear MCP, hooks, skills) |
| `modules/home/default.nix` | Edit (import zellij.nix) |

## Dependencies

- `zellij` package
- `ghostty` (already configured)
- `claude` CLI
- Linear MCP (via npm)
- GitHub MCP (already configured)

## Sources

- [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim) - Neovim integration
- [git-worktree-runner](https://github.com/coderabbitai/git-worktree-runner) - Worktree automation patterns
- [worktree-workflow](https://github.com/forrestchang/worktree-workflow) - Claude Code worktree toolkit
- [Linear MCP](https://linear.app/docs/mcp) - Linear integration
- [Claude Code Hooks](https://code.claude.com/docs/en/hooks-guide) - Automation hooks
