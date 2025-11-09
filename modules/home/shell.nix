_: {
  xdg.configFile."opencode/config.json" = {
    text = ''
      {
      "$schema": "https://opencode.ai/config.json",
      "mcp": {
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "enabled": true,
            "headers": {
              "Authorization": "Bearer ctx7sk-a8bd2804-d72c-4423-8822-91720bd755be"
            }
          }
        },
        "provider": {
          "synthetic": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Synthetic",
            "options": {
              "baseURL": "https://api.synthetic.new/v1",
              "apiKey": "syn_3293e2d06f19bcd7b3ebacca0eb5ca7b"
            },
            "models": {
              "hf:Qwen/Qwen3-Coder-480B-A35B-Instruct": {
                "name": "Qwen 3 Coder"
              },
              "hf:zai-org/GLM-4.5": {
                "name": "GLM 4.5"
              }
            }
          }
        }

      }
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
