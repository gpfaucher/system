_: {
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xmonad.hs;
  };


  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    opacityRule = [
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
      backend = "glx";
      vsync = true;
    };
  };

  programs.rofi.enable = true;
}
