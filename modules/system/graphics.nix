{ config, pkgs, lib, ... }:

{
  # Enable graphics (AMD as primary GPU)
  hardware.graphics.enable = true;

  # NVIDIA configuration for hybrid graphics (PRIME offload)
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;

    # PRIME offload mode - AMD as primary, NVIDIA on-demand
    prime = {
      offload = {
        enable = true;
        # Provides the `nvidia-offload` command to run apps on NVIDIA GPU
        enableOffloadCmd = true;
      };

      # Bus IDs - find with: lspci | grep -E 'VGA|3D'
      # Example output: "01:00.0 VGA compatible controller: AMD..."
      # Convert to format: "PCI:1:0:0"
      # amdgpuBusId = "PCI:X:X:X";   # TODO: Fill from lspci
      # nvidiaBusId = "PCI:X:X:X";   # TODO: Fill from lspci
    };
  };

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
