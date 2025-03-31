{ config, ... }: {
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    powerManagement.enable = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  powerManagement.resumeCommands = ''
    wlr-randr --output DP-2 --mode 3440x1440@144 &
    rm -rf ~/Documents ~/Desktop/ ~/Downloads/
    sudo evremap remap ~/.config/evremap/config.toml &
  '';

  programs.river = {
    enable = true;
  };

  services.displayManager.ly.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };
}
