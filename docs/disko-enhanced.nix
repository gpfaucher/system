# Enhanced Disko configuration with improvements
# Changes from current setup:
# 1. LUKS encryption on root partition
# 2. More subvolumes for better organization
# 3. Snapshots support configured
# 4. Separate swap partition (fallback for zram)
# 5. Larger EFI partition for safety

{ lib, ... }:

{
  disko.devices = {
    disk.nvme0 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          # EFI Boot Partition (increased from 1G to 2G for safety)
          boot = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          # Swap partition (8-16 GB for OOM safety)
          # Provides fallback when zram is exhausted
          swap = {
            size = "16G";
            type = "8200"; # Linux swap
            content = {
              type = "swap";
              priority = 0; # Lower than zram (zram has priority 5)
            };
          };

          # Encrypted root partition
          root = {
            size = "100%";
            type = "8300";
            content = {
              type = "luks";
              name = "luks-root";
              passwordFile = "/tmp/luks-password"; # Provide at boot
              content = {
                type = "btrfs";
                format = "btrfs";
                subvolumes = {
                  # Root subvolume
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd:3" # zstd compression (level 3, good balance)
                      "noatime" # No access time updates
                      "ssd" # SSD optimizations
                      "discard=async" # Async TRIM
                      "space_cache=v2" # Modern space cache
                    ];
                  };

                  # Home subvolume
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };

                  # Snapshots subvolume (for snapper integration)
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "compress=zstd:3"
                    ];
                  };

                  # /var subvolume (logs, caches, ephemeral data)
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # /nix subvolume (package store, read-mostly)
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # /tmp subvolume (temporary files)
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # /root subvolume (root user home)
                  "@root" = {
                    mountpoint = "/root";
                    mountOptions = [
                      "compress=zstd:3"
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
    };

    # Secondary disk: Windows (preserved, not managed)
    # Documents the dual-boot setup
  };
}
