{ config, pkgs, lib, ... }:
{
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xdg/xmonad.hs; # Assumes this file is in the same directory
  };

  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    opacityRule = [
      "100:name *= 'i3lock'"
      "99:fullscreen"
      "90:class_g = 'Alacritty' && focused"
      "65:class_g = 'Alacritty' && !focused"
    ];

    shadow = true;
    shadowOpacity = 0.75;
    settings = {
      xrender-sync-fence = true;
      mark-ovredir-focused = false;
      use-ewmh-active-win = true;

      unredir-if-possible = false;
      backend = "glx"; # try "glx" if xrender doesn't help
      vsync = true;
    };
  };

  programs.alacritty.enable = true;
  programs.rofi.enable = true;
}
