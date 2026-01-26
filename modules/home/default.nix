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
    ./services.nix
    ./theme.nix
    ./opencode.nix
    ./beads.nix
  ];

  # Enable Beads for persistent agent task memory
  programs.beads = {
    enable = true;
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
    borderColorFocused = "83a598";
    borderColorUnfocused = "504945";
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

    # Browsers
    firefox
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
    tabby-agent # AI code completion agent
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
    networkmanagerapplet # nm-applet - NetworkManager GUI tray applet for Wayland/River

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

  # Tabby server configuration - auto-discover git repos in ~/projects
  home.activation.tabbyServerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.tabby
    
    # Generate config by scanning ~/projects for git repositories
    CONFIG="$HOME/.tabby/config.toml"
    $DRY_RUN_CMD rm -f "$CONFIG"
    
    for dir in $HOME/projects/*/; do
      if [ -d "$dir/.git" ]; then
        name=$(basename "$dir")
        echo "[[repositories]]" >> "$CONFIG"
        echo "name = \"$name\"" >> "$CONFIG"
        echo "git_url = \"file://$dir\"" >> "$CONFIG"
        echo "" >> "$CONFIG"
      fi
    done
  '';



  # Tabby agent configuration
  # Token is encrypted using agenix and decrypted to /run/agenix/tabby-token
  # The config file is generated at activation time to read the decrypted token
  home.activation.tabbyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/.tabby-client/agent
        
        # Read token from agenix-decrypted file, or use a placeholder if not available yet
        if [ -f /run/agenix/tabby-token ]; then
          TOKEN=$(cat /run/agenix/tabby-token)
        else
          TOKEN="TOKEN_NOT_DECRYPTED_YET"
          echo "Warning: /run/agenix/tabby-token not found. Run 'sudo nixos-rebuild switch' first."
        fi
        
        $DRY_RUN_CMD cat > $HOME/.tabby-client/agent/config.toml << EOF
    [server]
    endpoint = "http://localhost:8080"
    token = "$TOKEN"
    EOF
        
        $DRY_RUN_CMD chmod 600 $HOME/.tabby-client/agent/config.toml
  '';

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
        kill $(cat /tmp/screenrecord.pid)
        rm /tmp/screenrecord.pid
        mkdir -p ~/Videos/Recordings
        mv /tmp/recording.mp4 ~/Videos/Recordings/$(date +%Y%m%d_%H%M%S).mp4
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

  # Firefox configuration for Teams always-available status
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # Disable visibility API to prevent Teams from detecting tab/window switches
        "dom.visibilityAPI.enabled" = false;
      };
      # Full gruvbox theme for Firefox UI
      userChrome = ''
        /* Gruvbox Dark Theme */
        :root {
          --bg0: #282828;
          --bg1: #3c3836;
          --bg2: #504945;
          --fg: #ebdbb2;
          --blue: #83a598;
          --red: #fb4934;
          --green: #b8bb26;
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
      # Gruvbox theme for about: pages
      userContent = ''
        /* Style about: pages */
        @-moz-document url-prefix(about:) {
          body {
            background-color: #282828 !important;
            color: #ebdbb2 !important;
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
