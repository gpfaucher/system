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
    enable32Bit = true; # Required for Steam and VR applications

    extraPackages = with pkgs; [
      libva
      vulkan-loader
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };

  # Load both GPU drivers
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

  # NVIDIA configuration - PRIME sync mode for VR
  # NVIDIA RTX 2000 Ada is primary (display + render), AMD is secondary
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;

    # PRIME sync mode - NVIDIA renders, AMD displays
    # Required for VR as NVIDIA needs direct rendering access
    prime = {
      sync.enable = true;

      # Bus IDs from: lspci | grep -E 'VGA|3D'
      amdgpuBusId = "PCI:198:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # System packages for graphics diagnostics
  environment.systemPackages = with pkgs; [
    libva-utils
  ];

  # Wayland environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
