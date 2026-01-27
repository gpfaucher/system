{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable graphics with hardware video encoding support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for some VR applications
    
    # AMD VAAPI support for hardware encoding (ALVR VR streaming)
    # Mesa provides radeonsi_drv_video.so for AMD Phoenix1 GPU
    extraPackages = with pkgs; [
      libva # VA-API library
    ];
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva # 32-bit VA-API support for VR
    ];
  };

  # Load both GPU drivers
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  # NVIDIA configuration for hybrid graphics (PRIME offload)
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;

    # PRIME offload mode - AMD primary, NVIDIA on-demand for better battery
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
    # Fix cursor issues on wlroots compositors with NVIDIA
    WLR_NO_HARDWARE_CURSORS = "1";

    # Enable Wayland for Electron/Chromium apps on NixOS
    NIXOS_OZONE_WL = "1";

    # Enable native Wayland for Firefox
    MOZ_ENABLE_WAYLAND = "1";
  };
}
