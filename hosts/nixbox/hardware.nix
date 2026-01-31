# Hardware configuration for nixbox
#
# PLACEHOLDER: Replace this file with the output of:
#   nixos-generate-config --show-hardware-config
#
# Run this on the target machine after booting the NixOS installer.
# The generated config will include:
#   - Detected kernel modules
#   - Filesystem mounts (by UUID)
#   - CPU microcode updates
#   - Any special hardware quirks
#
# Example for a typical desktop with RTX 3070:
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules - adjust based on actual hardware
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd" for AMD CPU
  boot.extraModulePackages = [ ];

  # PLACEHOLDER: Replace with actual filesystem UUIDs from nixos-generate-config
  # Run on target: nixos-generate-config --show-hardware-config
  # Then replace these placeholder UUIDs with actual values
  #
  # Example BTRFS setup:
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ROOT-UUID";
    fsType = "ext4"; # or "btrfs" with options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-EFI-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Swap - zram recommended for systems with enough RAM
  zramSwap = {
    enable = true;
    memoryPercent = 25; # Server typically needs less swap
    algorithm = "zstd";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU microcode - uncomment the appropriate line after determining CPU vendor
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
