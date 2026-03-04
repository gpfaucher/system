{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      libva
      vulkan-loader
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Bus IDs from: lspci | grep -E 'VGA|3D'
      # AMD Phoenix1 at c6:00.0 (c6 hex = 198 decimal)
      # NVIDIA RTX 2000 Ada at 01:00.0
      amdgpuBusId = "PCI:198:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    libva-utils
  ];

}
