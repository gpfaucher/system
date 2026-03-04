{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor.theme = "breeze_cursors";
      cursor.size = 24;
      iconTheme = "breeze-dark";
    };

    panels = [
      {
        location = "bottom";
        hiding = "autohide";
        height = 36;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.taskmanager";
            config.General = {
              launchers = [];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    hotkeys.commands = {
      "launch-terminal" = {
        key = "Meta+Return";
        command = "ghostty";
      };
      "launch-nmtui" = {
        key = "Meta+N";
        command = "ghostty -e nmtui";
      };
      "launch-btop" = {
        key = "Meta+O";
        command = "ghostty -e btop";
      };
      "launch-pulsemixer" = {
        key = "Meta+A";
        command = "ghostty -e pulsemixer";
      };
      "launch-lazygit" = {
        key = "Meta+G";
        command = "ghostty -e lazygit";
      };
      "launch-yazi" = {
        key = "Meta+E";
        command = "ghostty -e yazi";
      };
      "launch-bluetuith" = {
        key = "Meta+X";
        command = "ghostty -e bluetuith";
      };
    };

    shortcuts = {
      kwin = {
        "Window Close" = "Meta+Q";
        "Window Fullscreen" = "Meta+F";
        "Window Minimize" = "Meta+M";
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Switch to Desktop 8" = "Meta+8";
        "Switch to Desktop 9" = "Meta+9";
      };
      "org.kde.krunner.desktop"."_launch" = "Meta+D";
      ksmserver."Lock Session" = "Meta+Shift+L";
    };

    kwin = {
      virtualDesktops = {
        rows = 1;
        number = 9;
      };
    };

    configFile = {
      "kdeglobals"."General"."fixed" = "JetBrainsMono Nerd Font,14,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    };
  };
}
