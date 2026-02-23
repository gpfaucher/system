# Workflow Simplification Design

## Overview

Simplify the development workflow by:
- Removing Claude Code Nix management (fully manual config)
- Fixing zellij to use Alt-based keybinds instead of locked mode
- Correcting kanshi profiles for actual monitor setup
- Simplifying spawn-agent to just create worktrees + zellij sessions

## Changes

### 1. Claude Code - Remove from Nix

**Remove from `nvf.nix`:**
- `claudecode-nvim` plugin and its setup
- Associated keymaps (`<leader>cc`, `<leader>cs`, etc.)
- `snacks-nvim` (only needed for claudecode terminal provider)
- Which-key group for Claude (`<leader>c`)

**Remove from `claude-code.nix`:**
- `claudeJsonContent` - MCP server config
- `claudeSettingsContent` - settings.json
- `claudeSettingsLocalContent` - settings.local.json
- `createMutableConfig` activation script
- All skill definitions and `allSkillFiles`
- OpenCode commands and `allCommandFiles`

**Keep in `claude-code.nix`:**
- `spawn-agent` script (simplified, see section 4)
- `cleanup-code` script (pre-commit hook helper)

**User manages manually:**
- `~/.claude.json` - MCP servers
- `~/.claude/settings.json` - global settings
- `~/.claude/settings.local.json` - local permissions
- `~/.claude/skills/` - custom skills

### 2. Zellij - Alt-based Keybinds

**Changes to `zellij.nix`:**

Remove:
- `default_mode = "locked"`
- `keybinds.unbind = [ "Ctrl h" ]`
- `agent.kdl` layout file

Add Alt-based keybinds:
```nix
keybinds = {
  # Clear default Ctrl bindings that conflict with neovim
  unbind = [
    "Ctrl p"  # pane mode
    "Ctrl t"  # tab mode
    "Ctrl n"  # resize mode
    "Ctrl h"  # move mode
    "Ctrl s"  # scroll mode
    "Ctrl o"  # session mode
    "Ctrl q"  # quit
  ];

  # Alt-based shortcuts (no conflicts with neovim)
  normal = {
    "Alt p" = { SwitchToMode = "pane"; };
    "Alt t" = { SwitchToMode = "tab"; };
    "Alt n" = { SwitchToMode = "resize"; };
    "Alt h" = { SwitchToMode = "move"; };
    "Alt s" = { SwitchToMode = "scroll"; };
    "Alt o" = { SwitchToMode = "session"; };
    "Alt q" = { Quit = {}; };

    # Quick pane navigation without mode switch
    "Alt Left" = { MoveFocus = "Left"; };
    "Alt Right" = { MoveFocus = "Right"; };
    "Alt Up" = { MoveFocus = "Up"; };
    "Alt Down" = { MoveFocus = "Down"; };

    # Quick tab navigation
    "Alt 1" = { GoToTab = 1; };
    "Alt 2" = { GoToTab = 2; };
    "Alt 3" = { GoToTab = 3; };
    "Alt 4" = { GoToTab = 4; };
    "Alt 5" = { GoToTab = 5; };
  };
};
```

### 3. Kanshi - Fix Monitor Profiles

**Current actual setup:**
- `DP-1`: Portrait 27" (2560x1440@100Hz, transform 90) - LEFT
- `HDMI-A-1`: Ultrawide 34" (3440x1440@100Hz) - RIGHT
- `eDP-1`: Laptop display (disabled when docked)

**Updated profiles in `services.nix`:**

```nix
settings = [
  # Primary: Portrait left + Ultrawide right (current dock setup)
  {
    profile.name = "dual-portrait-ultrawide";
    profile.outputs = [
      {
        criteria = "DP-1";
        mode = "2560x1440@100Hz";
        position = "0,0";
        transform = "90";
        scale = 1.0;
        status = "enable";
      }
      {
        criteria = "HDMI-A-1";
        mode = "3440x1440@100Hz";
        position = "1440,0";  # Portrait width = 1440 after rotation
        scale = 1.0;
        status = "enable";
      }
      {
        criteria = "eDP-1";
        status = "disable";
      }
    ];
  }
  # Laptop only (undocked)
  {
    profile.name = "laptop";
    profile.outputs = [
      {
        criteria = "eDP-1";
        mode = "3840x2400@60Hz";
        position = "0,0";
        scale = 2.0;
        status = "enable";
      }
    ];
  }
  # Ultrawide only (portrait disconnected)
  {
    profile.name = "ultrawide-only";
    profile.outputs = [
      {
        criteria = "HDMI-A-1";
        mode = "3440x1440@100Hz";
        position = "0,0";
        scale = 1.0;
        status = "enable";
      }
      {
        criteria = "eDP-1";
        status = "disable";
      }
    ];
  }
  # Portrait only
  {
    profile.name = "portrait-only";
    profile.outputs = [
      {
        criteria = "DP-1";
        mode = "2560x1440@100Hz";
        position = "0,0";
        transform = "90";
        scale = 1.0;
        status = "enable";
      }
      {
        criteria = "eDP-1";
        status = "disable";
      }
    ];
  }
];
```

### 4. Spawn-agent - Simplified

**New behavior:**
1. Parse branch name argument
2. Create git worktree at `.worktrees/<branch-name>`
3. Copy all `.env*` files (root + nested for monorepos)
4. Install dependencies (pnpm/yarn/npm)
5. Create and attach to zellij session named `<branch-name>`

**Remove:**
- Linear issue integration (`--linear` flag)
- Port configuration
- CLAUDE.md context file creation
- Auto-launching nvim/claude in layout

**Simplified script:**
```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: spawn-agent <branch-name> [base-branch]"
  exit 1
}

BRANCH_NAME="${1:-}"
BASE_BRANCH="${2:-}"

[[ -z "$BRANCH_NAME" ]] && usage

# Default base branch
if [[ -z "$BASE_BRANCH" ]]; then
  BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
fi

# Sanitize for directory name
SAFE_NAME=$(echo "$BRANCH_NAME" | tr '/' '-' | tr '[:upper:]' '[:lower:]')
WORKTREE_DIR=".worktrees/$SAFE_NAME"

echo "Creating worktree: $WORKTREE_DIR"
echo "Branch: $BRANCH_NAME (from $BASE_BRANCH)"

# Create or reuse worktree
if [[ -d "$WORKTREE_DIR" ]]; then
  echo "Worktree exists, reusing..."
else
  if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
  else
    git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" "$BASE_BRANCH"
  fi
fi

# Copy .env files
echo "Copying environment files..."
for f in .env .env.local .env.development .env.development.local .envrc; do
  [[ -f "$f" ]] && cp "$f" "$WORKTREE_DIR/"
done

# Nested .env files (monorepo)
find . -maxdepth 4 \( -name ".env*" -o -name ".envrc" \) \
  ! -path "./node_modules/*" \
  ! -path "./.worktrees/*" \
  ! -path "./.git/*" 2>/dev/null | while read -r f; do
  if [[ -f "$f" ]]; then
    dir=$(dirname "$f")
    mkdir -p "$WORKTREE_DIR/$dir" 2>/dev/null || true
    cp "$f" "$WORKTREE_DIR/$f" 2>/dev/null || true
  fi
done || true

# Install dependencies
cd "$WORKTREE_DIR"
if [[ -f "pnpm-lock.yaml" ]]; then
  pnpm install
elif [[ -f "yarn.lock" ]]; then
  yarn install
elif [[ -f "package-lock.json" ]]; then
  npm install
fi

# Create and attach to zellij session
echo "Starting zellij session: $SAFE_NAME"
exec zellij -s "$SAFE_NAME"
```

## Implementation Order

1. Update `services.nix` - fix kanshi profiles
2. Update `zellij.nix` - Alt keybinds, remove locked mode and agent layout
3. Update `claude-code.nix` - remove all config, simplify spawn-agent
4. Update `nvf.nix` - remove claudecode.nvim and snacks.nvim
5. Test: `home-manager switch`
6. Manually set up `~/.claude.json` with MCP servers

## Files Modified

- `modules/home/services.nix` - kanshi profiles
- `modules/home/zellij.nix` - keybinds
- `modules/home/claude-code.nix` - major simplification
- `modules/home/nvf.nix` - remove claudecode.nvim
