{pkgs, ...}: {
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.mullvad-vpn.enable = true;

  services.hyprpaper.enable = true;

  # Clipboard manager
  services.cliphist.enable = true;

  # Idle daemon for session locking and DPMS
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof waylock || waylock -fork-on-lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "test $(cat /sys/class/power_supply/AC*/online 2>/dev/null || echo 0) -eq 0 && hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  home.packages = with pkgs; [
    # Wayland-specific utilities
    grimblast
    waylock
    playerctl
    adwaita-icon-theme

    # Display management and presentation
    wl-mirror
    wdisplays
  ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };
}
