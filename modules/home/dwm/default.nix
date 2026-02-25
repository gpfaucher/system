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

  # Xresources for xrdb patch (Stylix colors loaded at X startup)
  # Xft.dpi = 192 gives 2x HiDPI scaling on the 3840x2400 laptop panel
  xresources.properties = {
    "Xft.dpi" = 192;
    "Xcursor.size" = 48;
    "dwm.normbgcolor" = "#${colors.base01}";
    "dwm.normbordercolor" = "#${colors.base02}";
    "dwm.normfgcolor" = "#${colors.base05}";
    "dwm.selbgcolor" = "#${colors.base08}";
    "dwm.selbordercolor" = "#${colors.base08}";
    "dwm.selfgcolor" = "#${colors.base00}";
  };

  # Packages needed for the DWM environment
  home.packages = with pkgs; [
    # Display
    autorandr
    arandr

    # System tray applets
    blueman
    networkmanagerapplet

    # Audio control
    pavucontrol

    # Screenshot (flameshot is HiDPI-aware, maim/slop is blurry at 2x)
    flameshot
    xclip
    xdotool

    # Wallpaper
    feh

    # X11 utilities
    xrandr
    xsetroot
    hsetroot
    xprop
    xev
  ];
}
