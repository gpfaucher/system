{ pkgs, ... }:
{
  services.xserver.enable = false; # No X11
  services.wayland = {
    enable = true;
    sway = {
      enable = true;
    };
  };

}
