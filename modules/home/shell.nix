{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
      set fish_greeting

      bind -M insert ctrl-e edit_command_buffer
      bind -M default ctrl-e edit_command_buffer

      fish_add_path -g ~/.local/bin
      fish_add_path -g ~/.npm-global/bin

      set -gx GOPATH ~/.local/share/go
      fish_add_path -g $GOPATH/bin

    '';

    shellAbbrs = {
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gs = "git status";

      clm = "codex --oss --local-provider lmstudio";

      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      cd = "z";
      sys = "cd ~/Developer/system";
      root = "cd (git rev-parse --show-toplevel)";
    };

    functions = { };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd=z" ];
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      filter_mode_shell_up_key_binding = "session";
      search_mode = "fuzzy";
      style = "compact";
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height=70%"
      "--layout=reverse"
      "--border"
      "--info=inline"
    ];
    fileWidget.options = [
      "--walker-skip=.git,node_modules,result,target,.direnv"
      "--preview='bat --color=always --style=numbers --line-range=:200 {}'"
      "--bind='ctrl-/:change-preview-window(down|hidden|)'"
    ];
    changeDirWidget.options = [
      "--walker-skip=.git,node_modules,result,target,.direnv"
      "--preview='eza --tree --color=always --level=2 {}'"
    ];
    # Atuin deliberately owns Ctrl-R; fzf owns files and directories.
    historyWidget.command = "";
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    settings.mgr = {
      show_hidden = true;
      sort_by = "natural";
      sort_dir_first = true;
    };
    keymap.mgr.prepend_keymap = [
      {
        on = [
          "g"
          "r"
        ];
        run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
        desc = "Go to Git repository root";
      }
      {
        on = [
          "g"
          "s"
        ];
        run = "cd ~/Developer/system";
        desc = "Go to system configuration";
      }
      {
        on = "!";
        for = "unix";
        run = ''shell "$SHELL" --block'';
        desc = "Open a shell here";
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = false;

      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";

      directory = {
        style = "blue";
      };

      character = {
        success_symbol = "[->](purple)";
        error_symbol = "[->](red)";
        vimcmd_symbol = "[<-](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
        stashed = "=";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };

  home.packages = with pkgs; [
    eza
    bat
  ];
}
