{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:

{
  imports = [
    ./river.nix
    ./nvf.nix
    ./shell.nix
    ./terminal.nix
    ./zellij.nix
    ./services.nix
    ./theme.nix
    ./opencode.nix
    ./claude-code.nix
    ./beads.nix
    ./ssh.nix
  ];

  # Enable Beads for persistent agent task memory
  # FIXME: Disabled due to vendoring mismatch in upstream package
  programs.beads = {
    enable = false;
    enableDaemon = false; # Opt-in for daemon (auto-sync)
  };

  # Home Manager configuration
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    # Set neovim as default editor
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Enable River WM
  programs.river = {
    enable = true;
    terminal = "ghostty";
    borderColorFocused = "59c2ff"; # ayu blue
    borderColorUnfocused = "272d38"; # ayu dark bg
    keyboardRepeatDelay = 250;
    keyboardRepeatRate = 30;
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Gabriel Faucher";
      user.email = "gpfaucher@gmail.com"; # TODO: Update with actual email
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };
  };

  # Additional packages
  home.packages = with pkgs; [
    # GUI
    jetbrains.datagrip
    zed-editor-fhs
    zoom-us # Video conferencing
    teams-for-linux
    libreoffice-fresh # Office suite
    vscode-fhs

    # Browsers
    firefox
    google-chrome
    inputs.zen-browser.packages.${pkgs.system}.twilight
    neovim
    claude-code

    # Development tools
    opencode
    opentofu
    awscli2
    gh
    git
    gnumake
    gcc
    tree-sitter
    nodejs_22
    bun # Fast JavaScript runtime and package manager (required by opencode)
    fd # For telescope find_files
    ripgrep # For telescope live_grep
    docker-compose # Docker Compose
    python312 # Python runtime for LSP
    tmux # Terminal multiplexer

    # Modern CLI tools
    delta # Git diff viewer with syntax highlighting
    eza # Modern ls replacement
    zoxide # Smart cd with 'z' command
    atuin # Database-backed shell history
    bat # Better cat with syntax highlighting
    fzf # Fuzzy finder
    jq # JSON processor
    yq-go # YAML processor
    tldr # Simplified man pages
    duf # Better df
    dust # Better du
    procs # Better ps
    bottom # btm - better top/htop
    btop # Resource monitor with GPU support

    # Debuggers
    gdb
    lldb

    # Kubernetes tools
    kubectl # Kubernetes CLI
    k9s # Kubernetes TUI
    kubernetes-helm # Kubernetes package manager

    # Database clients
    postgresql # psql client
    mariadb # mysql client
    redis # redis-cli
    mongosh # MongoDB shell

    # Cloud tools
    google-cloud-sdk # gcloud
    azure-cli # az

    # Formatters/Linters
    nodePackages.prettier
    black # Python formatter
    ruff # Python linter
    shellcheck # Shell script linter
    shfmt # Shell script formatter

    # System utilities
    unzip
    wget
    curl
    htop
    tree
    psmisc # killall command

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
  ];

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = false;
    };
  };

  # AWS configuration
  # Credentials are encrypted with agenix and decrypted directly to ~/.aws/credentials
  # This just sets up the non-secret config file
  home.file.".aws/config".text = ''
    [default]
    region = eu-central-1
    output = json
  '';

  # Ensure .aws directory exists with proper permissions
  home.activation.awsDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.aws
    $DRY_RUN_CMD chmod 700 $HOME/.aws
  '';

  # # Wallpaper configuration
  # xdg.configFile."wpaperd/config.toml".text = ''
  #   [default]
  #   path = "${../../../assets/wallpaper.png}"
  #   duration = "30m"
  #   mode = "center"
  # '';

  # Screenshot and screenrecord scripts
  home.file.".local/bin/screenshot-area" = {
    executable = true;
    text = ''
      #!/bin/sh
      grim -g "$(slurp)" - | wl-copy
    '';
  };

  home.file.".local/bin/screenshot-screen" = {
    executable = true;
    text = ''
      #!/bin/sh
      grim - | wl-copy
    '';
  };

  home.file.".local/bin/screenshot-save" = {
    executable = true;
    text = ''
      #!/bin/sh
      mkdir -p ~/Pictures/Screenshots
      grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
    '';
  };

  home.file.".local/bin/screenrecord-area" = {
    executable = true;
    text = ''
      #!/bin/sh
      wf-recorder -g "$(slurp)" -f /tmp/recording.mp4 &
      echo $! > /tmp/screenrecord.pid
    '';
  };

  home.file.".local/bin/screenrecord-screen" = {
    executable = true;
    text = ''
      #!/bin/sh
      wf-recorder -f /tmp/recording.mp4 &
      echo $! > /tmp/screenrecord.pid
    '';
  };

  home.file.".local/bin/screenrecord-save" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -f /tmp/screenrecord.pid ]; then
        PID=$(cat /tmp/screenrecord.pid)
        kill -INT "$PID" 2>/dev/null
        # Wait for wf-recorder to finalize the MP4 file
        while kill -0 "$PID" 2>/dev/null; do sleep 0.1; done
        rm /tmp/screenrecord.pid
        mkdir -p ~/Videos/Recordings
        mv /tmp/recording.mp4 ~/Videos/Recordings/$(date +%Y%m%d_%H%M%S).mp4
        notify-send "Recording saved" "~/Videos/Recordings/"
      fi
    '';
  };

  home.file.".local/bin/display-info" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Display current monitor configuration summary
      echo "=== Current Display Configuration ==="
      wlr-randr | grep -E "(^[A-Z]|Enabled:|Position:|Mode:|Scale:|Transform:)"
    '';
  };

  # Workspace startup scripts for different monitor profiles
  # Tags: 1=1, 2=2, 3=4, 4=8, 5=16, 6=32, 7=64, 8=128, 9=256

  home.file.".local/bin/workspace-ultrawide-only" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="/run/current-system/sw/bin:$PATH"
      # Ultrawide-only workspace setup
      # Tag 1: nvim in paddock-app + claude code
      # Tag 2: zen browser
      # Tag 3: two terminals (apps/ui, apps/api)
      # Tag 4: datagrip
      # Tag 9: teams

      sleep 1  # Wait for display to be ready

      # Tag 1: nvim + claude code
      ghostty --title="nvim-paddock" --working-directory="$HOME/projects/paddock-app" -e nvim &
      sleep 0.5
      ghostty --title="claude-paddock" --working-directory="$HOME/projects/paddock-app" -e claude &

      # Tag 2: zen browser (main instance)
      zen &

      # Tag 3: terminals for apps/ui and apps/api
      sleep 0.5
      ghostty --title="term-ui" --working-directory="$HOME/projects/paddock-app/apps/ui" &
      sleep 0.3
      ghostty --title="term-api" --working-directory="$HOME/projects/paddock-app/apps/api" &

      # Tag 4: datagrip
      sleep 0.5
      datagrip &

      # Tag 9: teams
      sleep 0.5
      teams-for-linux &
    '';
  };

  home.file.".local/bin/workspace-dual-monitor" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="/run/current-system/sw/bin:$PATH"
      # Dual monitor (vertical + ultrawide) workspace setup
      # Ultrawide tags 1-4, 9: paddock development + teams
      # Vertical tags 6-8: claude code terminals + zen (separate instance)

      sleep 1  # Wait for display to be ready

      # === ULTRAWIDE MONITOR ===
      # Tag 1: nvim in paddock-app
      ghostty --title="nvim-paddock" --working-directory="$HOME/projects/paddock-app" -e nvim &

      # Tag 2: zen browser (main instance)
      zen &

      # Tag 3: terminals for apps/ui and apps/api
      sleep 0.5
      ghostty --title="term-ui" --working-directory="$HOME/projects/paddock-app/apps/ui" &
      sleep 0.3
      ghostty --title="term-api" --working-directory="$HOME/projects/paddock-app/apps/api" &

      # Tag 4: datagrip
      sleep 0.5
      datagrip &

      # Tag 9: teams
      sleep 0.5
      teams-for-linux &

      # === VERTICAL MONITOR ===
      # Tag 6: claude code in system project
      sleep 0.5
      ghostty --title="claude-system" --working-directory="$HOME/projects/system" -e claude &

      # Tag 7: claude code in paddock-app project
      sleep 0.3
      ghostty --title="claude-paddock-v" --working-directory="$HOME/projects/paddock-app" -e claude &

      # Tag 8: zen browser (separate instance with different profile)
      # Create profile dir if it doesn't exist, then launch with separate profile
      mkdir -p "$HOME/.zen/vertical"
      sleep 0.3
      zen --profile "$HOME/.zen/vertical" --no-remote --class zen-vertical &
    '';
  };

  home.file.".local/bin/workspace-laptop-only" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      export PATH="/run/current-system/sw/bin:$PATH"
      # Laptop-only workspace setup
      # Tag 1: nvim in paddock-app
      # Tag 2: zen browser
      # Tag 3: two terminals (apps/ui, apps/api)
      # Tag 4: datagrip
      # Tag 5: claude code
      # Tag 9: teams

      sleep 1  # Wait for display to be ready

      # Tag 1: nvim in paddock-app
      ghostty --title="nvim-paddock" --working-directory="$HOME/projects/paddock-app" -e nvim &

      # Tag 2: zen browser
      sleep 0.5
      zen &

      # Tag 3: terminals for apps/ui and apps/api
      sleep 0.5
      ghostty --title="term-ui" --working-directory="$HOME/projects/paddock-app/apps/ui" &
      sleep 0.3
      ghostty --title="term-api" --working-directory="$HOME/projects/paddock-app/apps/api" &

      # Tag 4: datagrip
      sleep 0.5
      datagrip &

      # Tag 5: claude code
      sleep 0.5
      ghostty --title="claude-main" --working-directory="$HOME/projects/paddock-app" -e claude &

      # Tag 9: teams
      sleep 0.5
      teams-for-linux &
    '';
  };

  # Firefox configuration for Teams always-available status
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # Disable visibility API to prevent Teams from detecting tab/window switches
        "dom.visibilityAPI.enabled" = false;
      };
      # Full ayu dark theme for Firefox UI
      userChrome = ''
        /* Ayu Dark Theme */
        :root {
          --bg0: #0b0e14;
          --bg1: #1f2430;
          --bg2: #272d38;
          --fg: #bfbdb6;
          --blue: #59c2ff;
          --red: #f07178;
          --green: #aad94c;
        }

        /* Tab styling */
        .tabbrowser-tab {
          background-color: var(--bg1) !important;
          color: var(--fg) !important;
        }
        .tabbrowser-tab[selected] {
          background-color: var(--bg2) !important;
        }

        /* Address bar */
        #urlbar {
          background-color: var(--bg1) !important;
          color: var(--fg) !important;
          border: 1px solid var(--bg2) !important;
        }

        /* Toolbar */
        #navigator-toolbox {
          background-color: var(--bg0) !important;
        }
      '';
      # Ayu dark theme for about: pages
      userContent = ''
        /* Style about: pages */
        @-moz-document url-prefix(about:) {
          body {
            background-color: #0b0e14 !important;
            color: #bfbdb6 !important;
          }
        }
      '';
      # Enable userChrome.css
      extraConfig = ''
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      '';
    };
  };

  # Greasemonkey/Tampermonkey userscript for Teams - install in browser
  home.file.".local/share/userscripts/teams-always-available.user.js" = {
    text = ''
      // ==UserScript==
      // @name         Teams Always Available
      // @namespace    http://tampermonkey.net/
      // @version      1.0
      // @description  Keep Microsoft Teams status as Available
      // @match        https://teams.microsoft.com/*
      // @match        https://*.teams.microsoft.com/*
      // @grant        none
      // @run-at       document-start
      // ==/UserScript==

      (function() {
        'use strict';

        // Override visibility API to always report visible
        Object.defineProperty(document, 'hidden', { value: false, writable: false });
        Object.defineProperty(document, 'visibilityState', { value: 'visible', writable: false });

        // Block visibility change events
        document.addEventListener('visibilitychange', function(e) {
          e.stopImmediatePropagation();
        }, true);

        // Override hasFocus to always return true
        Document.prototype.hasFocus = function() { return true; };

        // Simulate activity every 30 seconds to prevent idle timeout
        setInterval(function() {
          document.dispatchEvent(new MouseEvent('mousemove', {
            bubbles: true,
            cancelable: true,
            clientX: Math.random() * 100,
            clientY: Math.random() * 100
          }));
        }, 30000);

        console.log('[Teams Always Available] Active - status will remain Available');
      })();
    '';
  };
}
