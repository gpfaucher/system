{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  username = "gabrielfaucher";
in
{
  system.stateVersion = 7;
  system.primaryUser = "${username}";

  # 1. User Setup (Crucial for macOS paths)
  users.users."${username}" = {
    home = "/Users/gabrielfaucher";
    isHidden = false;
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };

  programs.fish.enable = true;

  config.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
      set fish_greeting

      fish_add_path -g ~/.local/bin
      fish_add_path -g ~/.npm-global/bin
      fish_add_path -g /opt/homebrew/bin  # Homebrew on Apple Silicon

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
      lg = "lazygit";

      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      cd = "z";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
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
        format = "\\([$state( $progress_current/$progress_total)]($style)\) ";
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

  # 2. Network & DNS
  home = {
    packages = with pkgs;
      [
        yazi
        lazygit
      ];
  };

  networking.dns = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # 4. Declarative Homebrew (Installs Outlook/Citrix as Apps)
  homebrew = {
    enable = true;

    # Apps to install (Cask) -- These appear in /Applications
    onActivation.cleanup = "uninstall"; # Clean up old versions

    casks = [
      "ghostty"
      "microsoft-outlook" # Syncs your Exchange calendar to Apple Calendar
      "citrix-workspace" # Your corporate VDI login
      "iterm2"
      "karabiner-elements"
      "zoom"
      "iterm2"
    ];

    brews = [
      # Apple Silicon native CLI tools via Homebrew
      "openshift-cli" # oc/kubectl for OKD/OpenShift (Apple Silicon build)
    ];
  };

  system.defaults = {
    dock.autohide = false;
    finder.AppleShowAllExtensions = true;
  };
}
