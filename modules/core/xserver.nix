{ config, ... }: {
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  powerManagement.resumeCommands = ''
    wlr-randr --output DP-2 --mode 3440x1440@144 &
    rm -rf ~/Documents ~/Desktop/ ~/Downloads/
  '';

  programs.river = {
    enable = true;
  };
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm.enable = true;
  };
}
