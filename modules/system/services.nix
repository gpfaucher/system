{ config, lib, pkgs, ... }:

{
  # dconf for GTK/GNOME settings (required by stylix)
  programs.dconf.enable = true;

  # CUPS printing service
  services.printing.enable = true;

  # Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Polkit for authentication dialogs
  security.polkit.enable = true;

  # XDG portal configuration for Wayland/wlroots
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config = {
      common = {
        default = [ "wlr" ];
      };
      river = {
        default = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  # Rootless Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;  # Sets DOCKER_HOST for the user
    };
  };
}
