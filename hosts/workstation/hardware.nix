# Placeholder hardware configuration for the workstation.
#
# IMPORTANT: After installing NixOS on the target machine, regenerate this
# file with the actual disk UUIDs and detected modules:
#
#     sudo nixos-generate-config --show-hardware-config > hosts/workstation/hardware.nix
#
# Then re-add the zramSwap block at the bottom and remove the placeholder
# UUIDs below. The values here are illustrative only — they will not boot
# unless you replace them with the UUIDs printed by `blkid` on the new box.
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

  # Typical desktop NVMe / SATA workstation modules. Adjust if your storage
  # controller differs (e.g. add "ahci" for SATA-only systems).
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];

  # AMD Ryzen CPU virtualization module.
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # ── REPLACE THESE UUIDs WITH THE OUTPUT OF `blkid` ──────────────────────
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-EFI-UUID";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Compressed RAM swap. Workstations usually have plenty of RAM, so this
  # remains useful as a safety net under sudden memory pressure.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
