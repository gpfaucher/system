_: {
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaPersistenced = true; # Preserve video memory on suspend for stable resume
    # Fine-grained power management (turns off GPU when not in use)
    powerManagement.finegrained = true;
    prime = {
      # Offload mode: NVIDIA GPU only used when explicitly requested
      offload = {
        enable = true;
        enableOffloadCmd = true; # Provides nvidia-offload command
      };
      # sync.enable = true;  # Old setting - kept both GPUs always on

      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
    };
  };
}
