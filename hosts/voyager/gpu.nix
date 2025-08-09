_: {
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    prime = {
      sync.enable = true;

      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
    };
  };
}
