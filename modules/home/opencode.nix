{
  config,
  pkgs,
  lib,
  self,
  ...
}:

let
  # Read prompt files from the flake source
  prompts = {
    architect = builtins.readFile "${self}/prompts/architect.txt";
    build = builtins.readFile "${self}/prompts/build.txt";
    orchestrator = builtins.readFile "${self}/prompts/orchestrator.txt";
    plan = builtins.readFile "${self}/prompts/plan.txt";
    review = builtins.readFile "${self}/prompts/review.txt";
    refactor = builtins.readFile "${self}/prompts/refactor.txt";
    test = builtins.readFile "${self}/prompts/test.txt";
    debug = builtins.readFile "${self}/prompts/debug.txt";
    research = builtins.readFile "${self}/prompts/research.txt";
    explore = builtins.readFile "${self}/prompts/explore.txt";
    general = builtins.readFile "${self}/prompts/general.txt";
    document = builtins.readFile "${self}/prompts/document.txt";
    optimize = builtins.readFile "${self}/prompts/optimize.txt";
    nix-specialist = builtins.readFile "${self}/prompts/nix-specialist.txt";
    security = builtins.readFile "${self}/prompts/security.txt";
    fix = builtins.readFile "${self}/prompts/fix.txt";
  };
in
{
  # OpenCode global configuration
  home.file.".config/opencode/opencode.json" = {
    force = true; # Allow overwriting existing config
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";

      model = "anthropic/claude-sonnet-4-5";
      small_model = "anthropic/claude-haiku-4-5";

      theme = "ayu";

      autoupdate = true;

      # Agent configuration
      agent = {
        architect = {
          description = "Primary agent for brainstorming, design, and planning. Automatically activates before implementation.";
          mode = "primary";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/architect.md}";
          tools = {
            write = true;
            edit = false;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        build = {
          description = "Primary implementation agent for writing production code. The main workhorse for code generation.";
          mode = "primary";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/build.md}";
          tools = {
            write = true;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        orchestrator = {
          description = "Primary agent for managing complex multi-step workflows and coordinating subagents. Uses Opus for maximum intelligence.";
          mode = "primary";
          model = "anthropic/claude-opus-4-5";
          prompt = "{file:~/.config/opencode/prompts/orchestrator.md}";
          tools = {
            write = true;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
            task = true;
          };
        };

        plan = {
          description = "Fast planning agent for breaking down tasks. Uses Haiku for speed.";
          mode = "subagent";
          model = "anthropic/claude-haiku-4-5";
          prompt = "{file:~/.config/opencode/prompts/plan.md}";
          tools = {
            write = true;
            edit = false;
            bash = false;
            read = true;
            glob = true;
            grep = true;
          };
        };

        review = {
          description = "Code review specialist for quality assurance and security analysis.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/review.md}";
          tools = {
            write = false;
            edit = false;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        refactor = {
          description = "Code refactoring and optimization specialist.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/refactor.md}";
          tools = {
            write = false;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        test = {
          description = "Testing specialist for TDD and comprehensive test coverage.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/test.md}";
          tools = {
            write = true;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        debug = {
          description = "Debugging specialist for systematic problem-solving.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/debug.md}";
          tools = {
            write = false;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        research = {
          description = "Codebase exploration and investigation specialist. Fast and thorough.";
          mode = "subagent";
          model = "anthropic/claude-haiku-4-5";
          prompt = "{file:~/.config/opencode/prompts/research.md}";
          tools = {
            write = false;
            edit = false;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        explore = {
          description = "Fast agent for quick codebase exploration. Uses Haiku for speed.";
          mode = "subagent";
          model = "anthropic/claude-haiku-4-5";
          prompt = "{file:~/.config/opencode/prompts/explore.md}";
          tools = {
            write = false;
            edit = false;
            bash = false;
            read = true;
            glob = true;
            grep = true;
          };
        };

        general = {
          description = "General-purpose agent for multi-step tasks. Uses Sonnet for balanced capability.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/general.md}";
          tools = {
            write = true;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
            webfetch = true;
          };
        };

        document = {
          description = "Documentation specialist for technical writing.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/document.md}";
          tools = {
            write = true;
            edit = true;
            bash = false;
            read = true;
            glob = true;
            grep = true;
          };
        };

        optimize = {
          description = "Performance optimization specialist.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/optimize.md}";
          tools = {
            write = false;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        nix-specialist = {
          description = "NixOS and Nix language specialist for system configuration.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/nix-specialist.md}";
          tools = {
            write = true;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        security = {
          description = "Security analysis and hardening specialist.";
          mode = "subagent";
          model = "anthropic/claude-sonnet-4-5";
          prompt = "{file:~/.config/opencode/prompts/security.md}";
          tools = {
            write = false;
            edit = false;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };

        fix = {
          description = "Fast bug fix specialist using Haiku for quick iterations.";
          mode = "subagent";
          model = "anthropic/claude-haiku-4-5";
          prompt = "{file:~/.config/opencode/prompts/fix.md}";
          tools = {
            write = false;
            edit = true;
            bash = true;
            read = true;
            glob = true;
            grep = true;
          };
        };
      };
    };
  };

  # Install all agent prompts as markdown files
  home.file.".config/opencode/prompts/architect.md".text = prompts.architect;
  home.file.".config/opencode/prompts/build.md".text = prompts.build;
  home.file.".config/opencode/prompts/orchestrator.md".text = prompts.orchestrator;
  home.file.".config/opencode/prompts/plan.md".text = prompts.plan;
  home.file.".config/opencode/prompts/review.md".text = prompts.review;
  home.file.".config/opencode/prompts/refactor.md".text = prompts.refactor;
  home.file.".config/opencode/prompts/test.md".text = prompts.test;
  home.file.".config/opencode/prompts/debug.md".text = prompts.debug;
  home.file.".config/opencode/prompts/research.md".text = prompts.research;
  home.file.".config/opencode/prompts/explore.md".text = prompts.explore;
  home.file.".config/opencode/prompts/general.md".text = prompts.general;
  home.file.".config/opencode/prompts/document.md".text = prompts.document;
  home.file.".config/opencode/prompts/optimize.md".text = prompts.optimize;
  home.file.".config/opencode/prompts/nix-specialist.md".text = prompts.nix-specialist;
  home.file.".config/opencode/prompts/security.md".text = prompts.security;
  home.file.".config/opencode/prompts/fix.md".text = prompts.fix;
}
