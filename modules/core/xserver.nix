_: {
  services.xserver = {
    enable = false;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.picom = {
    enable = false;
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    shadow = true;
  };
}
