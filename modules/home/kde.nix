{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;

    # IMPORTANT: Makes config fully declarative
    # All settings not in this file reset to defaults on login
    overrideConfig = true;

    # === Workspace ===
    workspace = {
      colorScheme = "BreezeDark";
      theme = "breeze-dark";
      cursor.theme = "breeze_cursors";
      iconTheme = "breeze-dark";
    };

    # === Fonts ===
    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    };

    # === Keyboard (crucial for vim + Kinesis) ===
    input.keyboard = {
      numlockOnStartup = "on";
      repeatDelay = 250; # ms before repeat starts (fast!)
      repeatRate = 30; # repeats per second (fast!)
      # Don't set caps:ctrl here - Kinesis handles it
    };

    # === KWin (Window Manager) ===
    kwin = {
      # Window decorations
      titlebarButtons = {
        left = ["close" "minimize" "maximize"];
        right = [];
      };

      # Effects
      effects = {
        shakeCursor.enable = false;
        desktopSwitching.animation = "slide";
      };

      # Virtual desktops
      virtualDesktops = {
        rows = 1;
        number = 4;
        names = ["Main" "Code" "Web" "Media"];
      };
    };

    # === Panel Configuration ===
    panels = [
      {
        location = "bottom";
        height = 44;
        hiding = "none";
        floating = false;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    # === Shortcuts (Vim-style!) ===
    shortcuts = {
      # KWin window management
      kwin = {
        # Vim-style focus navigation
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";

        # Move windows
        "Window Quick Tile Bottom" = "Meta+Shift+J";
        "Window Quick Tile Left" = "Meta+Shift+H";
        "Window Quick Tile Right" = "Meta+Shift+L";
        "Window Quick Tile Top" = "Meta+Shift+K";

        # Window actions
        "Window Close" = "Meta+Q";
        "Window Maximize" = "Meta+M";
        "Window Minimize" = "Meta+N";
        "Window Fullscreen" = "Meta+F";

        # Virtual desktops
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Window to Desktop 1" = "Meta+Shift+1";
        "Window to Desktop 2" = "Meta+Shift+2";
        "Window to Desktop 3" = "Meta+Shift+3";
        "Window to Desktop 4" = "Meta+Shift+4";

        # Overview
        "Overview" = "Meta+Space";
        "ExposeAll" = "Meta+Tab";
      };

      # Plasma shortcuts
      plasmashell = {
        "show application launcher" = "Meta+A";
      };

      # Spectacle (screenshots)
      "org.kde.spectacle.desktop" = {
        "RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };

    # === Custom Hotkeys (launch apps) ===
    hotkeys.commands = {
      launch-terminal = {
        name = "Launch Terminal";
        key = "Meta+Return";
        command = "kitty";
      };
      launch-browser = {
        name = "Launch Browser";
        key = "Meta+B";
        command = "firefox";
      };
      launch-files = {
        name = "Launch Files";
        key = "Meta+E";
        command = "dolphin";
      };
    };

    # === Power Management ===
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        powerButtonAction = "showLogoutScreen";
        dimDisplay = {
          enable = true;
          idleTimeout = 300; # 5 minutes
        };
      };
      battery = {
        autoSuspend = {
          action = "sleep";
          idleTimeout = 600; # 10 minutes
        };
      };
    };

    # === Spectacle (Screenshots) ===
    spectacle = {
      shortcuts = {
        captureRectangularRegion = "Meta+Shift+S";
        captureActiveWindow = "Meta+Shift+Print";
      };
    };

    # === KRunner ===
    krunner = {
      position = "center";
      activateWhenTypingOnDesktop = false;
    };

    # === Extra config files (for things plasma-manager doesn't cover) ===
    configFile = {
      # Dolphin settings
      "dolphinrc" = {
        "General" = {
          "ShowFullPath" = true;
          "SortingChoice" = "CaseInsensitiveSorting";
        };
      };
    };
  };

  # === Additional Packages ===
  home.packages = with pkgs; [
    # KDE utilities
    kdePackages.kcalc
    kdePackages.kate # Good backup editor
    kdePackages.filelight # Disk usage visualizer
    kdePackages.kompare # Diff viewer
    kdePackages.xdg-desktop-portal-kde

    # Theming
    tela-circle-icon-theme

    # Utils
    kdotool # xdotool for KDE
    wl-clipboard # Wayland clipboard
    xdg-desktop-portal-gtk
    wireplumber
  ];

  # === GPG/SSH Agent ===
  services.gpg-agent = {
    pinentry.package = lib.mkForce pkgs.kwalletcli;
    extraConfig = "pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet";
  };
}
