# Disko - Declarative Disk Management

This directory contains disko configuration for declarative disk partitioning and formatting.

## Current Status

**DOCUMENTATION ONLY** - The disko configuration in `disko.nix` matches the current disk layout but is NOT currently imported into the system configuration. This is intentional.

## What is Disko?

Disko is a tool for declarative disk partitioning in NixOS. It allows you to:

- Define disk layouts as Nix code
- Automate installation processes
- Ensure reproducible disk configurations
- Document your disk layout in version control

## Current Disk Layout

The `disko.nix` file documents the current laptop setup:

```
/dev/nvme0n1 (main NixOS disk)
├── nvme0n1p1 - 1GB EFI boot partition (vfat)
│   └── Mounted at /boot
└── nvme0n1p2 - Remaining space (btrfs)
    ├── @ subvolume → / (root)
    └── @home subvolume → /home
```

Additionally, there's a dual-boot Windows disk (`/dev/nvme1n1`) that is NOT managed by disko.

## ⚠️ SAFETY WARNINGS

**DO NOT RUN DISKO APPLY ON A LIVE SYSTEM WITHOUT FULL BACKUP**

Running disko in `--mode disko` will:

- **DESTROY ALL DATA** on the specified disk
- Repartition the disk from scratch
- Format all partitions
- Create new filesystems

This is only safe for:

- Fresh installations
- Disaster recovery with backups
- Test VMs

## How to Use

### For Fresh Installations

1. Boot into NixOS installer ISO
2. Clone your configuration
3. Review and adjust `disko.nix` if needed
4. Apply the configuration:
   ```bash
   sudo nix run github:nix-community/disko -- --mode disko ./modules/system/disko.nix
   ```
5. Mount filesystems and continue installation

### For Documentation Only (Current Mode)

The configuration serves as:

- Documentation of the current disk layout
- Reference for future reinstalls
- Basis for test VM configurations
- Template for other machines

## Enabling Disko (Future)

To actually use disko in your system configuration:

1. Import the disko module in your host configuration:

   ```nix
   # In hosts/laptop/default.nix
   imports = [
     ../../modules/system/disko.nix
     # ... other imports
   ];
   ```

2. Add disko module to NixOS configuration:

   ```nix
   # In flake.nix outputs.nixosConfigurations.laptop.modules
   disko.nixosModules.disko
   ```

3. This allows disko to manage `/etc/fstab` generation and other integration points

**Note**: Even when imported, disko won't repartition your disk. The destructive operations only happen when you run `nix run ... --mode disko`.

## Future Enhancements

Consider these improvements for fresh installs:

### Separate Nix Subvolume

```nix
"@nix" = {
  mountpoint = "/nix";
  mountOptions = [ "compress=zstd" "noatime" ];
};
```

Benefits: Easier to snapshot system state without nix store

### LUKS Encryption

```nix
content = {
  type = "luks";
  name = "crypted";
  settings.allowDiscards = true;
  content = {
    type = "btrfs";
    # ... subvolumes ...
  };
};
```

Benefits: Full disk encryption for sensitive data

### Swap Partition

Currently using zram swap. Could add a swap partition or file:

```nix
swap = {
  size = "16G";
  content = {
    type = "swap";
    resumeDevice = true;  # For hibernation
  };
};
```

### Additional Subvolumes

- `@snapshots` - For btrfs snapshots
- `@log` - Separate /var/log for easier cleanup
- `@tmp` - Temporary files

## Testing Changes

Before applying to real hardware:

1. Test in a VM:

   ```bash
   nix run github:nix-community/disko -- --mode disko --test ./modules/system/disko.nix
   ```

2. Review the generated commands:
   ```bash
   nix run github:nix-community/disko -- --mode mount ./modules/system/disko.nix --dry-run
   ```

## References

- [Disko Documentation](https://github.com/nix-community/disko)
- [Disko Examples](https://github.com/nix-community/disko/tree/master/example)
- [NixOS Wiki - Btrfs](https://nixos.wiki/wiki/Btrfs)
- [NixOS Wiki - Full Disk Encryption](https://nixos.wiki/wiki/Full_Disk_Encryption)

## Maintenance

When updating hardware or changing disk layouts:

1. Update `disko.nix` to reflect changes
2. Keep UUIDs in `hardware.nix` as canonical source
3. Test changes in VM before applying to hardware
4. Document any deviations from this template

## Questions?

- Why not use disko for everything? Because the system is already installed and working. Disko is most valuable for fresh installs.
- Can I apply this safely? **NO** - not without backing up all data first. It will destroy everything on the disk.
- Should I import this module? Only if you want disko to manage fstab generation. Currently, hardware.nix handles this fine.
