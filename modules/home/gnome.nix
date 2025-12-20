{pkgs, lib, ...}: {
  # Enable dconf for GNOME settings
  dconf = {
    enable = true;

    settings = {
      # Dark theme
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
        icon-theme = "Adwaita";
      };

      # Touchpad settings
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
        natural-scroll = true;
      };

      # Mouse settings
      "org/gnome/desktop/peripherals/mouse" = {
        natural-scroll = false;
      };

      # Workspaces on all monitors
      "org/gnome/mutter" = {
        workspaces-only-on-primary = false;
        edge-tiling = true;
      };

      # Window buttons
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      # Favorite apps in dock
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "org.gnome.Console.desktop"
        ];
        disable-user-extensions = false;
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
        ];
      };

      # Night light
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
      };

      # Power settings
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 900;
      };
    };
  };

  # GNOME Extensions and tools
  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    gnome-tweaks
  ];
}
