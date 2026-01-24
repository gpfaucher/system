# Declarative Disk Management - Quick Reference Guide

## System Overview at a Glance

```
┌─────────────────────────────────────────────────────────────────┐
│                    CURRENT DISK LAYOUT                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  nvme0n1 (931.5 GB - NixOS)              nvme1n1 (953.9 GB)     │
│  ├─ nvme0n1p1 (1 GB)    ← EFI Boot  │  ├─ nvme1n1p1 Windows    │
│  └─ nvme0n1p2 (930 GB)  ← Btrfs    │  └─ nvme1n1p3-4 Windows  │
│     ├─ @ (/)                       │                            │
│     └─ @home (/home)               │   [Dual-boot system]      │
│                                     │                            │
│  Swap: zram0 (30.7 GB, 50% RAM)    │   Boot: systemd-boot      │
│                                     │   Encryption: None         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Quick Facts

| Aspect          | Current               | Recommended            |
| --------------- | --------------------- | ---------------------- |
| **Disk Layout** | Static (hardware.nix) | Declarative (disko)    |
| **Filesystems** | Btrfs (2 subvols)     | Btrfs (7 subvols)      |
| **Compression** | None                  | zstd:3                 |
| **Encryption**  | None                  | LUKS (optional)        |
| **Swap**        | zram only             | zram + 16GB disk       |
| **Snapshots**   | None                  | snapper (hourly/daily) |
| **Boot Loader** | systemd-boot          | systemd-boot           |
| **Dual-boot**   | Windows preserved     | Windows preserved      |

---

## Disko Benefits Checklist

- [x] Reproducible disk layouts (can reinstall exact same setup)
- [x] Automated partitioning (no manual steps)
- [x] Version controlled in git (track all changes)
- [x] Easy to modify and test
- [x] Supports complex setups (RAID, LVM, encryption)
- [x] Infrastructure-as-code for storage
- [x] One-command system restore

---

## Implementation Timeline

```
WEEK 1: Setup
├─ Add disko to flake.nix inputs
├─ Create hosts/laptop/disko.nix (basic)
└─ Test import (no disk changes)

WEEK 2-4: Testing
├─ Dry-run with --mode disko --dry-run
├─ Test on USB drive or VM
└─ Verify configuration is correct

MONTH 2+: Deployment
├─ Create full backup (external drive)
├─ Run disko format (formats disk)
├─ Install with enhanced config (LUKS, compression)
└─ Restore data from backup

ONGOING: Operations
├─ Enable snapper for snapshots
├─ Configure cloud backups
├─ Monthly recovery drills
└─ Monitor disk usage
```

---

## Key Files & Locations

### Current System

```
/etc/nixos/configuration.nix       [Generated]
/etc/nixos/hardware-configuration  [Current setup]
~/projects/system/hosts/laptop/
  ├─ default.nix                   [Host config]
  └─ hardware.nix                  [Disk layout (static)]
```

### After Disko Migration

```
~/projects/system/
  ├─ flake.nix                     [Add disko input]
  └─ hosts/laptop/
      ├─ default.nix               [Import disko.nix]
      ├─ disko.nix                 [Disk layout (declarative)]
      └─ hardware.nix              [Keep for compatibility]
```

---

## Common Commands

### Inspect Current Disk

```bash
# Show partitions
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT

# Show Btrfs subvolumes
sudo btrfs subvolume list /

# Show mount options
mount | grep btrfs

# Show disk usage
df -h
btrfs filesystem usage /
```

### Disko Commands (When Implemented)

```bash
# Check configuration
nix flake check

# Dry-run (see what would happen)
sudo disko disko --disk /dev/nvme0n1 --mode disko --dry-run

# Format disk (DESTRUCTIVE!)
sudo disko format --disk /dev/nvme0n1 ./hosts/laptop/disko.nix

# Install system
sudo nixos-install --flake .#laptop
```

### Snapshot Commands (With Snapper)

```bash
# List snapshots
snapper -c home list
snapper -c root list

# Create snapshot manually
snapper -c home create --description "before-update"

# Restore file from snapshot
snapper -c home undochange 5..0

# Delete old snapshots
snapper -c home cleanup timeline
```

### Backup Commands

```bash
# Backup to external drive
rsync -avz --delete / /mnt/backup/

# Create Btrfs snapshot
sudo btrfs subvolume snapshot -r / /mnt/backup/root-backup

# Verify backup
sha256sum /mnt/backup/* | tee /mnt/backup/checksums.txt
```

---

## Troubleshooting Checklist

| Problem              | Check                      | Solution                                  |
| -------------------- | -------------------------- | ----------------------------------------- |
| Disko not found      | disko in flake.nix inputs? | Add disko to inputs and modules           |
| Format failed        | Is disk unmounted?         | Unmount all partitions first              |
| Boot fails           | Can you access recovery?   | Boot NixOS installer, restore from backup |
| Windows won't boot   | Is Windows EFI mounted?    | Check /boot/efi-windows                   |
| Out of disk space    | Snapshots too many?        | Clean with `snapper cleanup`              |
| Performance degraded | Compression enabled?       | Check mount options, disable if slow      |

---

## Security Considerations

### Current Risks

- ⚠️ No encryption (full disk readable without auth)
- ⚠️ No snapshots (no recovery from accidents)
- ⚠️ Single backup location (git only, no disk backup)

### Mitigation Path

1. **Add disko** → Reproducible setup ✓
2. **Add compression** → Better disk usage ✓
3. **Enable snapshots** → Quick recovery ✓
4. **Add LUKS encryption** → Protect against theft
5. **Add external backups** → Protect against hardware failure

### Recommended Encryption Setup (With Disko)

```nix
# In disko.nix
content = {
  type = "luks";
  name = "luks-root";
  passwordFile = "/tmp/luks-password";
  content = {
    type = "btrfs";
    # ... rest of config
  };
};
```

**Notes:**

- Password required at boot
- Consider FIDO2/TPM for unattended boots
- Encrypted disko config can be in git (no secrets)

---

## Performance Tuning

### Current Setup (Good)

- ✅ Async discard enabled (TRIM optimization)
- ✅ space_cache=v2 (modern, performant)
- ✅ SSD-aware mount options
- ✅ zram swap (fast, efficient)

### Enhanced Setup (Better)

- ✅ Add compression (zstd:3)
  - 30-50% space savings
  - Faster with zstd than uncompressed I/O
- ✅ Remove noatime updates
  - Less metadata writes
- ✅ Separate @nix subvolume
  - Enables ro-mounting for security
- ✅ Snapshots with proper cleanup
  - Prevents disk exhaustion

---

## Capacity Planning

```
Current Usage:
- Total: 931.5 GB (nvme0n1)
- Used: 55 GB (6%)
- Free: 875 GB (94%)

With Recommended Enhancements:
- Compression savings: ~20 GB (36% of 55 GB)
- Snapshots space: ~30 GB (keep last 7 days)
- Free space: ~845 GB (still plenty)

Estimated Snapshot Storage:
- 24 hourly snapshots @ ~500 MB = 12 GB
- 7 daily snapshots @ ~2 GB = 14 GB
- Total snapshot impact: ~26 GB (2.8% of disk)
```

---

## Next Steps (Ordered by Priority)

1. **Week 1:**
   - [ ] Read and understand disko documentation
   - [ ] Create backup of current system
   - [ ] Add disko to flake.nix

2. **Week 2-3:**
   - [ ] Create disko.nix matching current setup
   - [ ] Test import (dry-build)
   - [ ] Test on VM

3. **Month 2:**
   - [ ] Create enhanced disko.nix with compression
   - [ ] Do full backup to external drive
   - [ ] Decide on encryption (LUKS or skip)

4. **Month 3:**
   - [ ] Boot NixOS installer USB
   - [ ] Run `disko format` with enhanced config
   - [ ] Run `nixos-install --flake .#laptop`
   - [ ] Verify all systems work

5. **Ongoing:**
   - [ ] Enable and test snapper
   - [ ] Set up cloud backups (Backblaze/Nextcloud)
   - [ ] Monthly recovery drills
   - [ ] Document any issues

---

## Resources & Documentation

### Official Documentation

- **disko:** https://github.com/nix-community/disko
- **Btrfs:** https://btrfs.readthedocs.io/
- **NixOS:** https://nixos.org/manual/
- **Snapper:** https://snapper.io/

### Relevant NixOS Modules

```bash
# View available disko options
nixos-option -r disko

# View snapper options
nixos-option -r services.snapper

# View hardware options
nixos-option -r hardware
```

### Community Resources

- NixOS Discourse: https://discourse.nixos.org/
- NixOS Matrix Chat: #nixos:matrix.org
- disko Examples: https://github.com/nix-community/disko/tree/master/examples

---

## Summary

| Aspect                | Status          | Recommendation       |
| --------------------- | --------------- | -------------------- |
| **Current Setup**     | Stable, working | Keep as-is for now   |
| **Disko Integration** | Not implemented | Add in week 1-2      |
| **Compression**       | Disabled        | Enable (zstd:3)      |
| **Snapshots**         | None            | Enable with snapper  |
| **Encryption**        | None            | Add in future        |
| **Backups**           | Git only        | Add external + cloud |
| **Dual-boot**         | Working         | Preserve Windows     |
| **Performance**       | Good            | Can be optimized     |

**Overall Assessment:** ✅ Healthy system with clear improvement path.

The system is currently stable. Migrating to disko will improve **reproducibility**, **maintainability**, and enable future enhancements like **encryption** and **automated snapshots** without disrupting the current setup.
