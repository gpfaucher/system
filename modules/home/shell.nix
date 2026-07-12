{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
      set fish_greeting

      fish_add_path -g ~/.local/bin
      fish_add_path -g ~/.npm-global/bin

      set -gx GOPATH ~/.local/share/go
      fish_add_path -g $GOPATH/bin

      zoxide init fish | source
      atuin init fish | source
    '';

    shellAbbrs = {
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gs = "git status";

      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      cd = "z";
    };

    functions = { };
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
    zoxide
    atuin
    eza
    bat
    fzf
  ];
}
