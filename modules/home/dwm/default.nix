{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;
in
{
  imports = [
    ./picom.nix
    ./slstatus.nix
    ./dmenu.nix
    ./dunst.nix
  ];

  # Autostart script for DWM (cool_autostart patch reads ~/.dwm/autostart.sh)
  home.file.".dwm/autostart.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Kill existing instances to avoid duplicates on restart
      pkill -x picom 2>/dev/null; sleep 0.2
      pkill -x slstatus 2>/dev/null
      pkill -x dunst 2>/dev/null

      picom &
      slstatus &
      dunst &
      nm-applet &
      blueman-applet &
      feh --bg-fill ~/.wallpaper 2>/dev/null &
      autorandr --change &
    '';
  };

  # Xresources for xrdb patch (Stylix colors loaded at X startup)
  xresources.properties = {
    "dwm.normbgcolor" = "#${colors.base00}";
    "dwm.normbordercolor" = "#${colors.base01}";
    "dwm.normfgcolor" = "#${colors.base05}";
    "dwm.selbgcolor" = "#${colors.base0D}";
    "dwm.selbordercolor" = "#${colors.base0D}";
    "dwm.selfgcolor" = "#${colors.base00}";
  };

  # Packages needed for the DWM environment
  home.packages = with pkgs; [
    # Compositor and display
    feh
    autorandr
    arandr

    # System tray applets
    blueman
    networkmanagerapplet

    # Audio control
    pavucontrol

    # Screenshot
    maim
    xclip
    xdotool

    # Screen lock
    slock

    # X11 utilities
    xrandr
    xsetroot
    xprop
    xev
  ];
}
