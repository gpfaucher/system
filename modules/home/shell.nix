_: {
  # OpenCode minimal config - intelligence lives in AGENTS.md
  xdg.configFile."opencode/config.json" = {
    text = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "mcp": {
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "headers": {"Authorization": "Bearer {env:CONTEXT7_API_KEY}"}
          },
          "gh_grep": {"type": "remote", "url": "https://mcp.grep.app"},
          "filesystem": {
            "type": "local",
            "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/home/gabriel"]
          },
          "github": {
            "type": "local",
            "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
            "environment": {"GITHUB_PERSONAL_ACCESS_TOKEN": "{env:GITHUB_TOKEN}"}
          },
          "memory": {
            "type": "local",
            "command": ["npx", "-y", "@modelcontextprotocol/server-memory"]
          },
          "searxng": {
            "type": "local",
            "command": ["npx", "-y", "mcp-searxng"],
            "environment": {"SEARXNG_URL": "http://localhost:8080"}
          },
          "sequential_thinking": {
            "type": "local",
            "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]
          },
          "docker": {
            "type": "local",
            "command": ["npx", "-y", "@modelcontextprotocol/server-docker"]
          }
        },
        "provider": {
          "synthetic": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Synthetic",
            "options": {
              "baseURL": "https://api.synthetic.new/v1",
              "apiKey": "{env:SYNTHETIC_API_KEY}"
            },
            "models": {
              "hf:Qwen/Qwen3-Coder-480B-A35B-Instruct": {"name": "Qwen 3 Coder"},
              "hf:zai-org/GLM-4.5": {"name": "GLM 4.5"}
            }
          }
        },
        "instructions": ["AGENTS.md"],
        "agent": {
          "build": {
            "description": "Full development agent with write access",
            "mode": "primary",
            "temperature": 0.3,
            "prompt": "You are a senior software engineer. Follow AGENTS.md instructions. Use multiple MCP tools in parallel when appropriate to gather comprehensive information before implementing.\n\nGit commits: After completing implementation work, automatically commit changes using conventional commits format (feat:, fix:, refactor:, docs:, etc.). Do not wait to be asked - commit proactively when work is complete."
          },
          "plan": {
            "description": "Read-only planning and analysis",
            "mode": "primary",
            "temperature": 0.1,
            "tools": {"write": false, "edit": false, "bash": false},
            "prompt": "You are a technical architect. Follow AGENTS.md instructions. Use multiple MCP tools in parallel to research before providing recommendations. Do not make code changes."
          },
          "research": {
            "mode": "subagent",
            "temperature": 0.2,
            "tools": {"write": false, "edit": false, "bash": false},
            "prompt": "Research specialist. Use searxng, context7, gh_grep, github, memory in parallel. Synthesize from multiple sources."
          },
          "security": {
            "mode": "subagent",
            "temperature": 0.1,
            "tools": {"write": false, "edit": false, "bash": false},
            "prompt": "Security auditor. Use MCP tools to find vulnerabilities, CVEs, and security patterns."
          }
        }
      }
    '';
  };

  # Global AGENTS.md with comprehensive MCP usage instructions
  xdg.configFile."opencode/AGENTS.md" = {
    text = ''
      # OpenCode Agent Instructions

      ## Core Principle: MCP-First Development

      **NEVER rely on training data alone.** Always verify with current sources via MCP tools.

      ## Parallel Execution Pattern

      Since subagents execute serially, use the primary agent with **parallel MCP calls**:

      ```
      # BAD - Serial subagent calls (slow)
      @research topic1
      @research topic2

      # GOOD - Parallel MCP calls in primary agent
      Call context7, gh_grep, searxng simultaneously in one response
      ```

      ## MCP Tools: When and How

      ### 1. context7 (Library Documentation)
      **Use for:** Official docs, API references, framework guides

      **Workflow:**
      1. First resolve library ID: `context7_resolve-library-id` with library name
      2. Then fetch docs: `context7_get-library-docs` with resolved ID and topic

      **Examples:**
      - NixOS: `/nixos/nixpkgs`, `/websites/nixos_manual_nixos_unstable`
      - ML: Search for "pytorch", "transformers", "jax"
      - Web: Search for "react", "nextjs", "typescript"

      **Parallel usage:** Call multiple resolves/fetches together

      ### 2. gh_grep (Code Search)
      **Use for:** Real-world implementations, patterns, idioms

      **Search tips:**
      - Use literal code: `useState(`, `mkOption`, `import torch`
      - Filter by language: `["TypeScript", "Nix", "Python"]`
      - Use regex with `useRegexp: true` for complex patterns

      **Examples:**
      - Find NixOS patterns: `services.` with language Nix
      - Find React hooks: `useEffect\(\(\) =>` with useRegexp
      - Find CUDA code: `cudaMalloc` with language C++

      **Parallel usage:** Search multiple patterns at once

      ### 3. searxng (Web Search)
      **Use for:** Current trends, tutorials, comparisons, error messages

      **When to use:**
      - "Best practices for X in 2025"
      - Error message debugging
      - Library comparisons
      - Recent announcements

      **Parallel usage:** Multiple queries in one response

      ### 4. github (GitHub API)
      **Use for:** Issues, PRs, repository exploration

      **Common operations:**
      - Search issues for known bugs
      - Find similar PRs
      - Check repository structure
      - Review discussions

      ### 5. memory (Knowledge Graph)
      **Use for:** Persistent context across sessions

      **Operations:**
      - `memory_read_graph` - Check existing knowledge
      - `memory_create_entities` - Store new learnings
      - `memory_search_nodes` - Find related context
      - `memory_add_observations` - Update existing knowledge

      **Store:**
      - Configuration decisions and rationale
      - Successful patterns
      - Failed approaches (to avoid repeating)
      - User preferences

      ### 6. sequential_thinking
      **Use for:** Complex multi-step reasoning

      **When to use:**
      - Architectural decisions
      - Debugging complex issues
      - Planning large features
      - Comparing multiple approaches

      ### 7. docker
      **Use for:** Container management and inspection

      ### 8. filesystem
      **Use for:** File operations (already available via Read/Write)

      ## Domain-Specific Workflows

      ### NixOS Configuration

      1. **Research phase (parallel):**
         - context7: `/nixos/nixpkgs` for option reference
         - gh_grep: Search for similar configs
         - searxng: NixOS wiki articles
         - github: Check nixpkgs issues

      2. **Implementation:**
         - Follow 2-space indentation
         - Trailing commas in attrsets
         - Use `alejandra` for formatting
         - Prefer declarative options

      3. **Memory:**
         - Store working configurations
         - Record option interactions

      ### ML/AI Development

      1. **Research phase (parallel):**
         - context7: PyTorch/JAX/HF docs
         - gh_grep: Training loops, model code
         - searxng: Latest papers, benchmarks
         - github: Library issues for bugs

      2. **Implementation:**
         - Consider GPU memory
         - Use mixed precision (fp16/bf16)
         - Profile before optimizing
         - For NixOS: Verify CUDA compatibility

      3. **Memory:**
         - Store hyperparameters
         - Record successful configs
         - Track performance baselines

      ### Web Development

      1. **Research phase (parallel):**
         - context7: Framework docs
         - gh_grep: Component patterns
         - searxng: Best practices
         - github: Similar implementations

      2. **Implementation:**
         - TypeScript for type safety
         - Proper error boundaries
         - Accessibility considerations
         - Performance budgets

      ### Security Auditing

      1. **Research phase (parallel):**
         - searxng: CVE databases, advisories
         - gh_grep: Vulnerability patterns
         - github: Security fixes in similar code
         - memory: Known vulnerabilities

      2. **Focus areas:**
         - NO hardcoded secrets (use env vars)
         - Input validation
         - SQL injection, XSS
         - Dependency vulnerabilities
         - NixOS hardening options

      ## Code Quality Standards

      ### General
      - Write self-documenting code
      - Add comments only for "why", not "what"
      - Prefer small, focused functions
      - Handle errors explicitly

      ### NixOS-Specific
      - Use `lib.mkOption` for custom options
      - Leverage `lib.mkIf` for conditional config
      - Use `lib.types.*` for type safety
      - Test with `nix flake check`

      ### Python/ML
      - Type hints everywhere
      - Docstrings for public APIs
      - Profile with `torch.profiler` or `jax.profiler`
      - Pin dependencies in flake

      ### Security
      - Use sops-nix or agenix for secrets
      - Enable firewall
      - Minimize attack surface
      - Regular dependency updates

      ## Workflow Summary

      1. **Understand** - Read the request carefully
      2. **Research** - Use MCP tools in parallel
      3. **Plan** - Think through approach
      4. **Implement** - Write code with references
      5. **Store** - Save learnings to memory
      6. **Verify** - Test and validate

      ## Common Pitfalls

      - ❌ Implementing without research
      - ❌ Using subagents when MCP parallel calls would work
      - ❌ Hardcoding values that should be configurable
      - ❌ Ignoring error cases
      - ❌ Not storing learnings in memory

      ## Quick Reference

      | Task | Tools (in parallel) |
      |------|---------------------|
      | New feature | context7 + gh_grep + searxng |
      | Debug error | searxng + github + gh_grep |
      | NixOS config | context7(/nixos/nixpkgs) + gh_grep(mkOption) |
      | Security audit | searxng(CVE) + gh_grep(patterns) + memory |
      | API design | context7(framework) + gh_grep(examples) |
      | Performance | searxng(benchmarks) + gh_grep(optimizations) |
    '';
  };


  programs.fish = {
    enable = true;
    loginShellInit = ''
      # Auto-start Hyprland on tty1
      if test (tty) = "/dev/tty1"
        exec Hyprland
      end
    '';
    shellAbbrs = {
      ga = "git add";
      gl = "git log --pretty=format:'%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --date=short";
      gc = "git commit -a";
      gca = "git commit --amend";
      gd = "git diff";
      gcom = "git checkout master";
      grh = "git reset --hard";
      lg = "lazygit";
    };
    interactiveShellInit = ''
      set fish_greeting
      set -g fish_key_bindings fish_vi_key_bindings
      set NIX_BUILD_SHELL "fish"

      # Oxocarbon Fish Theme (for syntax highlighting, etc.)
      set -g fish_color_normal f2f4f8
      set -g fish_color_command 42be65
      set -g fish_color_keyword be95ff
      set -g fish_color_error ee5396
      set -g fish_color_param 3ddbd9
      set -g fish_color_string 33b1ff
      set -g fish_color_quote 33b1ff
      set -g fish_color_redirection 78a9ff
      set -g fish_color_comment 525252
      set -g fish_color_operator be95ff
      set -g fish_color_end be95ff
      set -g fish_color_autosuggestion 525252
      set -g fish_color_history_current --bold
      set -g fish_color_search_match --background=33b1ff40
      set -g fish_color_selection --background=262626

      # Pager (Tab Completion Menu) Colors
      set -g fish_pager_color_prefix 78a9ff
      set -g fish_pager_color_completion f2f4f8
      set -g fish_pager_color_description 525252
      set -g fish_pager_color_selected_background --background=262626
      set -g fish_pager_color_progress 3ddbd9

      # Initialize Starship prompt.
      starship init fish | source
    '';
    functions = {
      fish_user_key_bindings = ''
        bind -M insert ctrl-o "tms; commandline -f repaint"
        bind -M default ctrl-o "tms; commandline -f repaint"
      '';
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format =
        "$username"
        + "$hostname"
        + "$directory"
        + "$git_branch"
        + "$git_state"
        + "$git_status"
        + "$cmd_duration"
        + "$line_break"
        + "$python"
        + "$character";

      directory = {
        style = "blue";
      };

      character = {
        success_symbol = "[⟶](purple)";
        error_symbol = "[⟶](red)";
        vimcmd_symbol = "[⟵](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        # Using a multi-line string here is fine because it doesn't have trailing backslashes.
        format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };
}
