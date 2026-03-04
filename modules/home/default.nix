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
    ./nvim
    ./shell.nix
    ./terminal.nix
    ./services.nix
    ./theme.nix
    ./zed.nix
    ./ssh.nix
    ./vscode.nix
    ./kde.nix
    ./tmux.nix
  ];

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 48.86;
    longitude = 2.35;
    temperature = {
      day = 6500;
      night = 3500;
    };
    settings = {
      general = {
        fade = 1;
        adjustment-method = "wayland";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = lib.mkForce "zeditor --wait";
    };

    pointerCursor = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
      gtk.enable = true;
    };
  };

  programs.home-manager.enable = true;

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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu";
      gpu-context = "wayland";
      profile = "gpu-hq";
      ytdl-format = "bestvideo+bestaudio";
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true;
      recolor-keephue = true;
    };
  };

  home.packages = with pkgs; [
    jetbrains-toolbox
    libreoffice-fresh # Office suite
    warp-terminal

    firefox
    google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight
    neovide

    claude-code
    (inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = map (
        p:
        if (p.pname or "") == "bun" then
          p.overrideAttrs (bunOld: rec {
            version = "1.3.10";
            src = fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
              hash = "sha256-9XvAGH45Yj3nFro6OJ/aVIay175xMamAulTce3M9Lgg=";
            };
          })
        else
          p
      ) old.nativeBuildInputs;
      preBuild =
        ''
          mkdir -p .github
          touch .github/TEAM_MEMBERS
        ''
        + (old.preBuild or "");
    }))
    opentofu
    pulumi-bin
    awscli2
    gh
    gnumake
    nodejs_22
    bun # required by opencode
    docker-compose
    python312

    eza
    zoxide
    atuin
    bat
    fzf
    jq
    yq-go
    tldr
    duf
    dust
    procs
    bottom
    btop

    gdb
    lldb

    kubectl
    k9s
    kubernetes-helm

    postgresql
    mariadb
    redis
    mongosh

    google-cloud-sdk
    # azure-cli # az -- disabled: broken in nixpkgs (missing azure.mgmt.web.v2024_11_01)

    nodePackages.prettier
    black
    ruff
    shellcheck
    shfmt

    unzip
    wget
    curl
    htop
    tree
    psmisc

    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts

    imv
    yt-dlp

    wf-recorder
    obs-studio

    udiskie

    trashy

    ouch

    easyeffects
    helvum

    wl-clipboard
  ];

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        # Web
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";

        # Images
        "image/png" = "imv-dir.desktop";
        "image/jpeg" = "imv-dir.desktop";
        "image/gif" = "imv-dir.desktop";
        "image/webp" = "imv-dir.desktop";
        "image/svg+xml" = "imv-dir.desktop";
        "image/bmp" = "imv-dir.desktop";
        "image/tiff" = "imv-dir.desktop";

        # Video
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";

        # Audio
        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/wav" = "mpv.desktop";
        "audio/x-wav" = "mpv.desktop";

        # PDF / Documents
        "application/pdf" = "org.pwmt.zathura.desktop";
        "application/epub+zip" = "org.pwmt.zathura.desktop";

        # Text / Code
        "text/plain" = "zeditor.desktop";
        "text/x-csrc" = "zeditor.desktop";
        "text/x-python" = "zeditor.desktop";
        "application/json" = "zeditor.desktop";
        "application/xml" = "zeditor.desktop";
        "application/x-yaml" = "zeditor.desktop";

        # File manager
        "inode/directory" = "yazi.desktop";

        # Meeting links → native apps
        "x-scheme-handler/zoommtg" = "Zoom.desktop";
        "x-scheme-handler/zoomus" = "Zoom.desktop";
        "x-scheme-handler/zoomphonecall" = "Zoom.desktop";
        "x-scheme-handler/msteams" = "teams-for-linux.desktop";
      };
    };
  };

  # Credentials are encrypted with agenix and decrypted directly to ~/.aws/credentials
  home.file.".aws/config".text = ''
    [default]
    region = eu-central-1
    output = json
  '';

  home.activation.awsDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.aws
    $DRY_RUN_CMD chmod 700 $HOME/.aws
  '';

  # Firefox configuration for Teams always-available status
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # Disable visibility API to prevent Teams from detecting tab/window switches
        "dom.visibilityAPI.enabled" = false;

        "media.webrtc.camera.allow-pipewire" = true;

        # VA-API hardware video decode
        "media.ffmpeg.vaapi.enabled" = true;

        "gfx.webrender.all" = true;
        "layers.gpu-process.enabled" = true;

        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-connections" = 1800;

        "network.dnsCacheEntries" = 4000;
        "network.dnsCacheExpiration" = 3600;

        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "browser.ping-centre.telemetry" = false;

        "extensions.pocket.enabled" = false;

        "browser.sessionstore.resume_from_crash" = true;
        "toolkit.winRegisterApplicationRestart" = false;

        # Session store interval: 5 min instead of default 15 sec
        "browser.sessionstore.interval" = 300000;

        "browser.compactmode.show" = true;
      };
      userChrome = ''
        /* Ayu Dark Theme */
        :root {
          --bg0: #0b0e14;
          --bg1: #131721;
          --bg2: #202229;
          --fg: #e6e1cf;
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
      userContent = ''
        /* Style about: pages */
        @-moz-document url-prefix(about:) {
          body {
            background-color: #0b0e14 !important;
            color: #e6e1cf !important;
          }
        }
      '';
      extraConfig = ''
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      '';
    };
  };

  home.file.".config/chrome-flags.conf".text = ''
    --enable-features=VaapiVideoDecodeLinuxGL
  '';

  # Teams always-available userscript — install in browser with Tampermonkey
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
