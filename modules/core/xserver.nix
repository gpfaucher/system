{ config, ... }: {
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  programs.river = {
    enable = true;
  };
  services.xserver = {
    enable = true;
      videoDrivers = [ "nvidia" ];
    displayManager.gdm.enable = true;
    #   # windowManager.xmonad = {
    #   #   enable = true;
    #   #   enableContribAndExtras = true;
    #   # };
    #   # xkb = {
    #   #   layout = "us";
    #   #   variant = "";
    #   # };
  };
}
