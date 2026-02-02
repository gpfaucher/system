{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Spawn agent script - creates worktree and launches zellij environment
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

    # If Linear issue provided, use as branch name
    if [[ -n "$LINEAR_ISSUE" ]]; then
      echo "Linear issue: $LINEAR_ISSUE"
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
    touch "$WORKTREE_DIR/.env.local"
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
      mkdir -p "$WORKTREE_DIR/.claude"
      cat > "$WORKTREE_DIR/.claude/AGENT_CONTEXT.md" << EOF
    # Agent Context

    Linear Issue: $LINEAR_ISSUE
    Branch: $BRANCH_NAME
    Port: $PORT

    On startup, fetch the Linear issue details and understand the task.
    EOF
    fi

    # Install dependencies
    WORKTREE_ABS=$(cd "$WORKTREE_DIR" && pwd)
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

    # Launch in new terminal window (ghostty)
    ghostty --working-directory="$WORKTREE_ABS" -e zellij --layout agent --session "$SAFE_NAME" &

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
        ${pkgs.gnused}/bin/sed -i 's/console\.log(.*DEBUG.*);//g' "$file" 2>/dev/null || true

        # Remove // TODO: remove comments
        ${pkgs.gnused}/bin/sed -i '/\/\/ TODO: remove/d' "$file" 2>/dev/null || true
        ${pkgs.gnused}/bin/sed -i '/# TODO: remove/d' "$file" 2>/dev/null || true

        # Re-stage the file if modified
        git add "$file"
      fi
    done
  '';

  # JSON content for mutable config files (created by activation script)
  claudeJsonContent = builtins.toJSON {
    mcpServers = {
      github = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-github" ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_TOKEN}";
        };
      };
      postgres = {
        command = "npx";
        args = [ "-y" "@crystaldba/postgres-mcp" "--access-mode=restricted" "\${DATABASE_URL}" ];
      };
      filesystem = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-filesystem" "/home/gabriel/projects" ];
      };
      context7 = {
        command = "npx";
        args = [ "-y" "@upstash/context7-mcp@latest" ];
      };
      linear = {
        command = "npx";
        args = [ "-y" "mcp-linear" ];
        env = {
          LINEAR_API_KEY = "\${LINEAR_API_KEY}";
        };
      };
    };
  };

  claudeSettingsContent = builtins.toJSON {
    enabledPlugins = {
      "superpowers@claude-plugins-official" = true;
    };
    preferences = { };
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash(git commit*)";
          command = "claude-cleanup";
        }
      ];
    };
  };

  claudeSettingsLocalContent = builtins.toJSON {
    permissions = {
      allow = [
        "Skill(superpowers:executing-plans)"
        "Skill(superpowers:executing-plans:*)"
      ];
    };
  };

  # Helper script to create mutable config files
  # Only creates/updates if file doesn't exist or is a symlink (from old config)
  createMutableConfig = pkgs.writeShellScript "create-claude-mutable-configs" ''
    set -euo pipefail

    create_if_needed() {
      local file="$1"
      local content="$2"
      local dir=$(dirname "$file")

      # Ensure directory exists
      mkdir -p "$dir"

      # If file is a symlink (from old home-manager config), remove it
      if [ -L "$file" ]; then
        echo "Removing symlink: $file"
        rm "$file"
      fi

      # Create file only if it doesn't exist
      if [ ! -f "$file" ]; then
        echo "Creating: $file"
        echo "$content" > "$file"
      else
        echo "Keeping existing: $file"
      fi
    }

    # Create mutable config files
    create_if_needed "$HOME/.claude.json" ${lib.escapeShellArg claudeJsonContent}
    create_if_needed "$HOME/.claude/settings.json" ${lib.escapeShellArg claudeSettingsContent}
    create_if_needed "$HOME/.claude/settings.local.json" ${lib.escapeShellArg claudeSettingsLocalContent}
  '';

  # Skill definitions shared between Claude Code and OpenCode
  # Claude Code reads:  ~/.claude/skills/<name>.md
  # OpenCode reads:     ~/.claude/skills/<name>/SKILL.md
  skills = {
    commit = ''
      ---
      name: commit
      description: Create a well-formatted commit with conventional commit message
      ---

      # Create Commit

      ## Pre-commit Checks

      1. **Review staged changes**:
         ```bash
         git diff --staged
         ```

      2. **Run quick validation** (if available):
         ```bash
         pnpm lint --fix 2>/dev/null || npm run lint --fix 2>/dev/null || true
         pnpm typecheck 2>/dev/null || npm run typecheck 2>/dev/null || true
         ```

      ## Commit Message Format

      Follow [Conventional Commits](https://www.conventionalcommits.org/):

      ```
      <type>(<scope>): <subject>

      <body>

      <footer>
      ```

      ### Types
      - `feat`: New feature
      - `fix`: Bug fix
      - `docs`: Documentation only
      - `style`: Formatting, missing semicolons, etc.
      - `refactor`: Code change that neither fixes a bug nor adds a feature
      - `perf`: Performance improvement
      - `test`: Adding missing tests
      - `chore`: Maintenance tasks

      ### Examples
      ```
      feat(auth): add JWT refresh token support

      Implement automatic token refresh when access token expires.
      Tokens are now stored securely in httpOnly cookies.

      Closes #123
      ```

      ## Create the Commit

      ```bash
      git commit -m "$(cat <<'EOF'
      type(scope): subject

      Body explaining what and why (not how).

      Co-Authored-By: Claude <noreply@anthropic.com>
      EOF
      )"
      ```

      ## After Commit

      - Show commit hash and summary
      - Suggest next steps (push, create PR, continue working)
    '';

    create-pr = ''
      ---
      name: create-pr
      description: Create a pull request with proper description, after running tests
      ---

      # Create Pull Request

      ## Pre-flight Checks

      1. **Run tests** - Ensure all tests pass before creating PR
         ```bash
         pnpm test || npm test || yarn test
         ```

      2. **Run linting** - Fix any lint errors
         ```bash
         pnpm lint || npm run lint
         ```

      3. **Check for uncommitted changes**
         ```bash
         git status
         ```

      ## Create the PR

      1. **Stage and commit** with a descriptive message following conventional commits:
         - `feat:` for new features
         - `fix:` for bug fixes
         - `refactor:` for code changes that neither fix bugs nor add features
         - `docs:` for documentation
         - `test:` for tests
         - `chore:` for maintenance

      2. **Push to remote** with tracking:
         ```bash
         git push -u origin HEAD
         ```

      3. **Create PR** using gh CLI:
         ```bash
         gh pr create --title "type: description" --body "$(cat <<'EOF'
         ## Summary
         - Brief description of changes

         ## Changes
         - List of specific changes made

         ## Test Plan
         - [ ] Tests pass locally
         - [ ] Manual testing performed
         - [ ] Edge cases considered

         ## Screenshots (if UI changes)
         EOF
         )"
         ```

      ## After PR Creation

      - Share the PR URL
      - Note any reviewers that should be assigned
    '';

    review-pr = ''
      ---
      name: review-pr
      description: Review a pull request thoroughly for code quality, security, and correctness
      ---

      # Review Pull Request

      ## Getting PR Context

      1. **Fetch PR details**:
         ```bash
         gh pr view <PR_NUMBER> --json title,body,files,additions,deletions
         gh pr diff <PR_NUMBER>
         ```

      2. **Check out PR locally** (if needed for testing):
         ```bash
         gh pr checkout <PR_NUMBER>
         ```

      ## Review Checklist

      ### Code Quality
      - [ ] Code follows project conventions and style
      - [ ] No unnecessary complexity or over-engineering
      - [ ] Functions/methods are focused and single-purpose
      - [ ] Variable and function names are clear and descriptive
      - [ ] No dead code or commented-out blocks
      - [ ] DRY principle followed (no unnecessary duplication)

      ### Security
      - [ ] No hardcoded secrets or credentials
      - [ ] Input validation present where needed
      - [ ] SQL injection prevention (parameterized queries)
      - [ ] XSS prevention (output encoding)
      - [ ] Authentication/authorization checks in place
      - [ ] No sensitive data in logs

      ### Testing
      - [ ] Tests cover the changes
      - [ ] Edge cases considered
      - [ ] Tests are meaningful (not just coverage padding)
      - [ ] Existing tests still pass

      ### Performance
      - [ ] No N+1 queries
      - [ ] No unnecessary database calls
      - [ ] Large data sets handled appropriately
      - [ ] Async operations used where beneficial

      ### TypeScript/JavaScript Specific
      - [ ] Types are properly defined (no `any` abuse)
      - [ ] Null/undefined handled safely
      - [ ] Error handling is appropriate
      - [ ] No floating promises

      ### React Specific (if applicable)
      - [ ] Hooks follow rules of hooks
      - [ ] Dependencies arrays correct in useEffect/useMemo/useCallback
      - [ ] No unnecessary re-renders
      - [ ] Keys used correctly in lists

      ## Providing Feedback

      Use GitHub review format:
      ```bash
      gh pr review <PR_NUMBER> --comment --body "Review comments here"
      # or
      gh pr review <PR_NUMBER> --approve --body "LGTM!"
      # or
      gh pr review <PR_NUMBER> --request-changes --body "Changes needed: ..."
      ```

      ## Output Format

      Provide review as:
      1. **Summary**: Overall assessment (1-2 sentences)
      2. **Issues**: List of problems found (if any)
      3. **Suggestions**: Optional improvements
      4. **Decision**: Approve / Request Changes / Comment
    '';

    worktree = ''
      ---
      name: worktree
      description: Create a git worktree for parallel development, copying .env and other local files
      ---

      # Git Worktree Setup

      Create an isolated worktree for parallel feature development with all necessary local files.

      ## Usage

      ```
      /worktree <branch-name> [base-branch]
      ```

      - `branch-name`: Name for the new branch (e.g., `feature/auth`)
      - `base-branch`: Branch to base off (default: `main` or `master`)

      ## Process

      ### 1. Determine Base Branch
      ```bash
      # Find default branch
      git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
      ```

      ### 2. Create Worktree
      ```bash
      # Create worktree in sibling directory
      WORKTREE_DIR="../$(basename $PWD)-$BRANCH_NAME"
      git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" "$BASE_BRANCH"
      ```

      ### 3. Copy Local Files

      Copy files that aren't tracked by git but needed for development:

      ```bash
      # Root-level environment files
      cp .env "$WORKTREE_DIR/" 2>/dev/null || true
      cp .env.local "$WORKTREE_DIR/" 2>/dev/null || true
      cp .env.development "$WORKTREE_DIR/" 2>/dev/null || true
      cp .env.development.local "$WORKTREE_DIR/" 2>/dev/null || true
      cp .envrc "$WORKTREE_DIR/" 2>/dev/null || true

      # Monorepo: Copy nested .env files preserving directory structure
      # Find all .env* and .envrc files, exclude node_modules and .worktrees
      find . -maxdepth 4 -name ".env*" -o -name ".envrc" 2>/dev/null | \
        grep -v node_modules | grep -v .worktrees | while read -r envfile; do
          dir=$(dirname "$envfile")
          mkdir -p "$WORKTREE_DIR/$dir"
          cp "$envfile" "$WORKTREE_DIR/$envfile" 2>/dev/null || true
        done

      # Local config overrides
      mkdir -p "$WORKTREE_DIR/.claude"
      cp .claude/settings.local.json "$WORKTREE_DIR/.claude/" 2>/dev/null || true

      # IDE settings (if not gitignored)
      cp -r .idea "$WORKTREE_DIR/" 2>/dev/null || true
      cp -r .vscode "$WORKTREE_DIR/" 2>/dev/null || true

      # Local database files (SQLite, etc.)
      cp *.db "$WORKTREE_DIR/" 2>/dev/null || true
      cp *.sqlite "$WORKTREE_DIR/" 2>/dev/null || true
      ```

      ### 4. Install Dependencies
      ```bash
      cd "$WORKTREE_DIR"

      # Node.js projects
      if [ -f "pnpm-lock.yaml" ]; then
        pnpm install
      elif [ -f "yarn.lock" ]; then
        yarn install
      elif [ -f "package-lock.json" ]; then
        npm install
      fi

      # Python projects
      if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
      elif [ -f "pyproject.toml" ]; then
        pip install -e .
      fi
      ```

      ### 5. Output

      Report:
      - Worktree location: `$WORKTREE_DIR`
      - Branch created: `$BRANCH_NAME`
      - Based on: `$BASE_BRANCH`
      - Files copied: list of .env files and configs copied
      - Next steps: `cd $WORKTREE_DIR && claude` or `cd $WORKTREE_DIR && opencode`

      ## Cleanup

      When done with the worktree:
      ```bash
      git worktree remove "$WORKTREE_DIR"
      git branch -d "$BRANCH_NAME"  # if merged
      ```

      ## List Worktrees
      ```bash
      git worktree list
      ```
    '';

    test = ''
      ---
      name: test
      description: Run tests and analyze failures
      ---

      # Run Tests

      ## Detect Test Framework

      ```bash
      # Check for test scripts
      if [ -f "package.json" ]; then
        # Node.js project
        if grep -q '"test"' package.json; then
          pnpm test || npm test || yarn test
        fi

        # Check for specific frameworks
        if grep -q "vitest" package.json; then
          pnpm vitest run
        elif grep -q "jest" package.json; then
          pnpm jest
        fi
      fi

      # Python
      if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
        pytest -v
      fi
      ```

      ## Test Options

      ### Run specific tests
      ```bash
      # Vitest/Jest - by file
      pnpm test src/auth/__tests__/login.test.ts

      # Vitest/Jest - by pattern
      pnpm test -t "should authenticate user"

      # Pytest - by pattern
      pytest -k "test_login"
      ```

      ### Watch mode
      ```bash
      pnpm test --watch
      pytest --watch
      ```

      ### Coverage
      ```bash
      pnpm test --coverage
      pytest --cov
      ```

      ## Analyze Failures

      When tests fail:

      1. **Read the error message carefully**
      2. **Identify the failing assertion**
      3. **Check the test file** to understand expected behavior
      4. **Check the implementation** for the bug
      5. **Fix and re-run**

      ## Output

      Report:
      - Total tests: X
      - Passed: X
      - Failed: X
      - Skipped: X
      - Duration: Xs

      For failures, show:
      - Test name
      - Expected vs actual
      - Relevant code snippet
      - Suggested fix
    '';

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
      - Run dev server in shell pane (port is pre-configured)
      - If Linear issue: Claude will fetch and understand the task

      ## Cleanup

      When done with the agent/feature:
      ```bash
      git worktree remove .worktrees/<branch-name>
      git branch -d <branch-name>  # if merged
      ```

      ## List Active Agents

      ```bash
      git worktree list
      ```
    '';
  };

  # Generate home.file entries for both Claude Code and OpenCode formats
  mkSkillFiles = name: content: {
    # Claude Code format: ~/.claude/skills/<name>.md
    ".claude/skills/${name}.md".text = content;
    # OpenCode format: ~/.claude/skills/<name>/SKILL.md
    ".claude/skills/${name}/SKILL.md".text = content;
  };

  # Merge all skill file entries
  allSkillFiles = lib.foldl' (acc: name: acc // mkSkillFiles name skills.${name}) { } (builtins.attrNames skills);

  # OpenCode custom commands (slash commands in the TUI)
  # These go in ~/.config/opencode/commands/<name>.md
  opencodeCommands = {
    "commit" = ''
      ---
      description: Create a well-formatted conventional commit
      ---
      Review staged changes with `git diff --staged`. Run linting if available.

      Create a commit following Conventional Commits format:
      - `feat:` new feature, `fix:` bug fix, `refactor:`, `docs:`, `test:`, `chore:`

      Use a HEREDOC for the message. Add `Co-Authored-By: Claude <noreply@anthropic.com>` footer.

      After committing, show the hash and suggest next steps.
    '';

    "create-pr" = ''
      ---
      description: Run tests, commit, push, and create a pull request
      ---
      1. Run tests: `pnpm test || npm test`
      2. Run linting: `pnpm lint || npm run lint`
      3. Check for uncommitted changes and stage/commit if needed (conventional commit format)
      4. Push to remote: `git push -u origin HEAD`
      5. Create PR using `gh pr create` with:
         - Title following conventional commits
         - Body with: ## Summary, ## Changes, ## Test Plan (checkboxes)
      6. Share the PR URL

      $ARGUMENTS
    '';

    "review-pr" = ''
      ---
      description: Thoroughly review a pull request
      ---
      Review PR $ARGUMENTS for:

      1. Fetch PR: `gh pr view $1 --json title,body,files,additions,deletions` and `gh pr diff $1`
      2. Check: code quality, security (no secrets, SQL injection, XSS), testing coverage, performance (N+1 queries), TypeScript types (no `any`), React hooks rules
      3. Provide: summary, issues found, suggestions, decision (approve/request changes)
      4. Post review: `gh pr review $1 --comment --body "..."`
    '';

    "worktree" = ''
      ---
      description: Create a git worktree with .env files and dependencies
      ---
      Create a git worktree for parallel development:

      1. Determine base branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` or default to `main`
      2. Create worktree: `git worktree add "../$(basename $PWD)-$1" -b "$1" "$BASE"`
      3. Copy local files:
         - Root: `.env`, `.env.local`, `.env.development`, `.env.development.local`, `.envrc`
         - Monorepo: Find all `.env*` and `.envrc` files up to 4 levels deep, preserving directory structure (excludes node_modules, .worktrees)
         - Config: `.claude/settings.local.json`, `.idea/`, `.vscode/`, `*.db`, `*.sqlite`
      4. Install deps: detect pnpm/yarn/npm/pip and install
      5. Report location, branch, files copied, and suggest `cd ../dir && opencode`

      Branch name: $1
      Base branch: $2 (optional, defaults to main)
    '';

    "test" = ''
      ---
      description: Run tests and analyze failures
      ---
      Detect the test framework and run tests:
      - Node.js: check for vitest/jest in package.json, run with pnpm/npm/yarn
      - Python: check for pytest.ini/pyproject.toml, run pytest -v

      Report: total, passed, failed, skipped, duration.
      For failures: show test name, expected vs actual, relevant code, suggested fix.

      $ARGUMENTS
    '';
  };

  mkCommandFiles = name: content: {
    ".config/opencode/commands/${name}.md".text = content;
  };

  allCommandFiles = lib.foldl' (acc: name: acc // mkCommandFiles name opencodeCommands.${name}) { } (builtins.attrNames opencodeCommands);
in
{
  # Use activation script to create mutable config files
  # These files are NOT managed by home.file because Claude Code needs to write to them at runtime
  # home.file creates symlinks to the read-only Nix store, which causes Claude Code to hang
  home.activation.createClaudeConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${createMutableConfig}
  '';

  # Scripts for parallel agent workflow
  home.packages = [
    spawn-agent
    cleanup-code
  ];

  # Skills and commands can be symlinks (read-only is fine)
  home.file = allSkillFiles // allCommandFiles;
}
