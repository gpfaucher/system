{ config, lib, ... }:

{
  # Disko declarative disk configuration
  # This matches the current disk layout - DO NOT apply without backup
  #
  # WARNING: This configuration is for DOCUMENTATION ONLY
  # Applying this will DESTROY ALL DATA on the specified disk
  #
  # Current disk layout (nvme0n1):
  #   - nvme0n1p1: 1GB EFI boot partition (vfat)
  #   - nvme0n1p2: Remaining space for btrfs with subvolumes
  #     - @ (root)
  #     - @home (home directories)
  #
  # To apply (DESTRUCTIVE - will erase disk):
  #   sudo nix run github:nix-community/disko -- --mode disko ./modules/system/disko.nix
  #
  # For fresh installs, see modules/system/DISKO-README.md

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Force overwrite
                subvolumes = {
                  # Root filesystem
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };
                  # Home directories
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };
                  # Optional: Separate nix subvolume for easier snapshotting
                  # Currently, /nix is part of @ root subvolume
                  # Uncomment to create separate subvolume on fresh install:
                  # "@nix" = {
                  #   mountpoint = "/nix";
                  #   mountOptions = [
                  #     "compress=zstd"
                  #     "noatime"
                  #     "ssd"
                  #     "discard=async"
                  #     "space_cache=v2"
                  #   ];
                  # };
                };
              };
            };
          };
        };
      };
    };
  };
}
