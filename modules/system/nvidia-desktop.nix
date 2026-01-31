{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================
  # NVIDIA Desktop/Server Graphics Configuration
  # ============================================
  # For systems with NVIDIA as the primary/only GPU
  # (no hybrid/PRIME setup like laptops)

  # Enable graphics with hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      nvidia-vaapi-driver  # NVIDIA VAAPI driver for video acceleration
      libva                # VA-API library
      libva-vdpau-driver   # VDPAU backend for VA-API
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };

  # NVIDIA driver configuration
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Use proprietary driver (better stability for RTX 30 series)
    open = false;

    # Modesetting is required for Wayland
    modesetting.enable = true;

    # Power management - disabled for desktop/server
    # (no need for power saving on always-on systems)
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use production driver branch
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Enable nvidia-settings GUI
    nvidiaSettings = true;
  };

  # NVIDIA container toolkit for Docker/Kubernetes GPU workloads
  hardware.nvidia-container-toolkit.enable = true;

  # System packages for GPU diagnostics and management
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring
    libva-utils          # vainfo for testing VAAPI
    vulkan-tools         # vulkaninfo
    glxinfo              # OpenGL info
    nvidia-vaapi-driver  # For hardware video decode
  ];

  # Environment variables for NVIDIA + Wayland
  environment.sessionVariables = {
    # Use NVIDIA for VA-API (hardware video decode)
    LIBVA_DRIVER_NAME = "nvidia";

    # Required for Wayland compositors
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";

    # Enable Wayland for Electron/Chromium apps
    NIXOS_OZONE_WL = "1";

    # Enable native Wayland for Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # CUDA paths for development
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
  };

  # Ensure NVIDIA modules are loaded at boot
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Enable DRM kernel mode setting
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
}
