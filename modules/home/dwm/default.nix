{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;

  # Generate config.h with Stylix colors substituted
  # substituteAll replaces @varname@ patterns
  configFile = pkgs.substituteAll {
    src = ./config.h;
    base00 = "#${colors.base00}";
    base01 = "#${colors.base01}";
    base02 = "#${colors.base02}";
    base03 = "#${colors.base03}";
    base04 = "#${colors.base04}";
    base05 = "#${colors.base05}";
    base06 = "#${colors.base06}";
    base07 = "#${colors.base07}";
    base08 = "#${colors.base08}";
    base09 = "#${colors.base09}";
    base0A = "#${colors.base0A}";
    base0B = "#${colors.base0B}";
    base0C = "#${colors.base0C}";
    base0D = "#${colors.base0D}";
    base0E = "#${colors.base0E}";
    base0F = "#${colors.base0F}";
  };

  customDwm = pkgs.dwm.overrideAttrs (old: {
    patches = [
      ./patches/dwm-pertag-6.2.diff
      ./patches/dwm-cool_autostart-6.5.diff
      ./patches/dwm-vanitygaps-20200610-f09418b.diff
      ./patches/dwm-movestack-6.1.diff
      ./patches/dwm-restartsig-20180523-6.2.diff
      ./patches/dwm-restoreafterrestart-20220709-d3f93c7.diff
      ./patches/dwm-attachbelow-6.2.diff
      ./patches/dwm-swallow-6.3.diff
      ./patches/dwm-savefloats-20181212-b69c870.diff
      ./patches/dwm-fakefullscreen-20210714-138b405.diff
      ./patches/dwm-statusallmons-6.2.diff
      ./patches/dwm-warp-6.4.diff
      ./patches/dwm-systray-6.7.diff
      ./patches/dwm-statuscmd-20210405-67d76bd.diff
      ./patches/dwm-smartborders-6.2.diff
      ./patches/dwm-centeredmaster-20160719-56a31dc.diff
      ./patches/dwm-deck-6.2.diff
      ./patches/dwm-fibonacci-6.2.diff
      ./patches/dwm-cyclelayouts-20180524-6.2.diff
      ./patches/dwm-namedscratchpads-6.2.diff
      ./patches/dwm-steam-6.2.diff
      ./patches/dwm-focusonnetactive-6.2.diff
      ./patches/dwm-sticky-6.5.diff
      ./patches/dwm-cfacts-6.2.diff
      ./patches/dwm-xrdb-6.4.diff
    ];

    postPatch = (old.postPatch or "") + ''
      cp ${configFile} config.def.h
    '';

    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.xorg.libXcursor
    ];
  });
in
{
  imports = [
    ./picom.nix
    ./slstatus.nix
    ./dmenu.nix
    ./dunst.nix
  ];

  # Override the system DWM package
  nixpkgs.overlays = [
    (final: prev: {
      dwm = customDwm;
    })
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
