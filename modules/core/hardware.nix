{ pkgs
, config
, ...
}: {
  xdg.portal.config.common.default = "*";
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

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

      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
