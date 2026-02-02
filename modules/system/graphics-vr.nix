{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable graphics with hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vulkan-loader
    ];
  };

  # Load both GPU drivers
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  # NVIDIA PRIME offload mode (works with Wayland)
  # Sync mode is X11-only and won't work with River/Wayland
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Bus IDs
      amdgpuBusId = "PCI:198:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    libva-utils
    nvtopPackages.nvidia
  ];

  # Wayland environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
