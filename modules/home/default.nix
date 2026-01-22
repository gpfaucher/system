{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./river.nix
    ./nvf.nix
    ./shell.nix
    ./terminal.nix
    ./services.nix
    ./theme.nix
  ];

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
      user.email = "gpfaucher@gmail.com";  # TODO: Update with actual email
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Additional packages
  home.packages = with pkgs; [
    # GUI
    jetbrains.datagrip

    # Browsers
    firefox
    neovim
    claude-code

    # Development tools
    opentofu
    awscli2
    gh
    git
    gnumake
    gcc
    tree-sitter
    nodejs_22
    tabby-agent  # AI code completion agent
    fd         # For telescope find_files
    ripgrep    # For telescope live_grep
    docker-compose  # Docker Compose

    # System utilities
    unzip
    wget
    curl
    htop
    tree

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

  # Tabby agent configuration
  # Get token from tabby server web UI or ~/.tabby/config.toml
  home.file.".tabby-client/agent/config.toml".text = ''
    [server]
    endpoint = "http://localhost:8080"
    token = "auth_872164f40d10473e861c75db73842900"
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

  # Firefox configuration for Teams always-available status
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # Disable visibility API to prevent Teams from detecting tab/window switches
        "dom.visibilityAPI.enabled" = false;
      };
      # Userscript to keep Teams status always available
      # Inject into Teams to prevent away status
      userChrome = ''
        /* Teams presence fix - loaded via userChrome */
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
