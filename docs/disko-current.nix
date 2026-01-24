# Disko configuration that matches CURRENT disk layout
# This replicates the existing partitioning without changes
# Use case: Document current setup, prepare for reproduction

{ lib, ... }:

{
  disko.devices = {
    disk.nvme0 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          # EFI Boot Partition
          boot = {
            size = "1G";
            type = "EF00";  # EFI System partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };

          # Root filesystem (Btrfs with subvolumes)
          root = {
            size = "100%";
            type = "8300";  # Linux filesystem
            content = {
              type = "btrfs";
              format = "btrfs";
              subvolumes = {
                # @ is root subvolume
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"        # Optional: enable compression
                    "noatime"              # Faster access (no atime updates)
                    "ssd"                  # SSD optimizations
                    "discard=async"        # Async TRIM
                    "space_cache=v2"       # Modern space cache
                  ];
                };

                # @home subvolume for /home
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

                # Optional subvolumes for snapshots
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                # @var for /var (logs, caches)
                "@var" = {
                  mountpoint = "/var";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "ssd"
                    "discard=async"
                  ];
                };

                # @nix for /nix/store (read-only in practice)
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "ssd"
                  ];
                };
              };
            };
          };
        };
      };
    };

    # Optional: Declare Windows partitions for documentation
    # These are not managed by disko (read-only preservation)
    nodev = {
      "/boot/efi-windows" = {
        fsType = "vfat";
        device = "/dev/disk/by-uuid/F41B-3E96";
        options = [ "ro" "nofail" "fmask=0077" "dmask=0077" ];
      };
    };
  };
}
