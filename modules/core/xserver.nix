_: {
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    xkb = {
      layout = "us";
      variant = "";
    };
  };
}
