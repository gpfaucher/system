{ pkgs, ... }: {
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ amdvlk ];

      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    enableRedistributableFirmware = true;
  };
}
