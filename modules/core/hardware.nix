{
  pkgs,
  config,
  ...
}:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ amdvlk ];
      enable32Bit = true;

      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    enableRedistributableFirmware = true;
    nvidia = {
      modesetting.enable = true;
      open = true;

      powerManagement.enable = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
