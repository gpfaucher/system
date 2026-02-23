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
    ./nvf.nix
    ./shell.nix
    ./terminal.nix
    ./zellij.nix
    ./services.nix
    ./theme.nix
    ./zed.nix
    ./ssh.nix
  ];

  # Home Manager configuration
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    # Set neovim as default editor
    sessionVariables = {
      EDITOR = "zeditor --wait";
      VISUAL = "zeditor --wait";
    };
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Gabriel Faucher";
      user.email = "gpfaucher@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Delta - git diff viewer (moved from programs.git.delta)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  # Additional packages
  home.packages = with pkgs; [
    # GUI
    jetbrains.datagrip
    zoom-us # Video conferencing
    teams-for-linux
    libreoffice-fresh # Office suite
    vscode-fhs
    warp-terminal

    # Browsers
    firefox
    google-chrome
    inputs.zen-browser.packages.${pkgs.system}.twilight
    neovim
    neovide

    # Development tools
    nixd # Nix language server
    claude-code
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

  # KDE Plasma handles screenshots (Spectacle) and screen recording natively
  # Use Meta+Shift+Print for area screenshot, Meta+Print for full screen
  # Screen recording available via OBS or KDE's built-in recorder

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
