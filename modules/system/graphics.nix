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
    enable32Bit = true; # Required for Steam and some applications

    # AMD VAAPI support for hardware video encoding/decoding
    # Mesa provides radeonsi_drv_video.so for AMD Phoenix1 GPU
    extraPackages = with pkgs; [
      libva # VA-API library
      vulkan-loader # Vulkan runtime
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva # 32-bit VA-API support
    ];
  };

  # Load both GPU drivers
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  # NVIDIA configuration - PRIME offload mode
  # AMD Phoenix1 is primary (display), NVIDIA RTX 2000 Ada is secondary (compute on-demand)
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;

    # PRIME offload mode - AMD primary, NVIDIA on-demand
    # Use nvidia-offload or prime-run to run apps on NVIDIA GPU
    # Note: sync mode is X11-only and breaks Wayland compositors
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

  # System packages for graphics diagnostics
  environment.systemPackages = with pkgs; [
    libva-utils # vainfo for testing VAAPI drivers
  ];

  # Wayland environment variables
  environment.sessionVariables = {
    # Enable Wayland for Electron/Chromium apps on NixOS
    NIXOS_OZONE_WL = "1";

    # Enable native Wayland for Firefox
    MOZ_ENABLE_WAYLAND = "1";
  };
}
