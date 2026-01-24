# Declarative Disk Management Analysis for NixOS System

## Executive Summary

This system has a **dual-disk, dual-boot setup** with:
- **Primary disk (nvme0n1)**: 931.5GB NixOS with Btrfs + zram swap
- **Secondary disk (nvme1n1)**: 953.9GB Windows (NTFS)
- **Boot setup**: Systemd-boot with auto-detected Windows entry
- **No LUKS encryption** on Linux partitions (currently unencrypted)
- **No disko integration** (currently using static hardware.nix)

---

## 1. CURRENT DISK LAYOUT ANALYSIS

### Partition Table Overview

```
DISK 1: nvme0n1 (931.5 GB - NixOS Primary)
├── nvme0n1p1    (1 GB)      FAT32     /boot                 [EFI Boot]
└── nvme0n1p2    (930.5 GB)  Btrfs     / & /home             [Linux Root]

DISK 2: nvme1n1 (953.9 GB - Windows Secondary)
├── nvme1n1p1    (200 MB)    FAT32     /boot/efi-windows     [Windows EFI]
├── nvme1n1p2    (16 MB)     (unknown) [WinRE Recovery]
├── nvme1n1p3    (952.9 GB)  NTFS      [Windows OS]
└── nvme1n1p4    (751 MB)    NTFS      [Windows Recovery]
```

### UUID Mapping

```
nvme0n1p1 (EFI Boot)      : EA15-090D
nvme0n1p2 (Btrfs)         : 388ac5b1-433c-46d2-8c1f-88cfdfae5297
nvme1n1p1 (Windows EFI)   : F41B-3E96
nvme1n1p3 (Windows OS)    : AA1A1C1E1A1BE5DB
nvme1n1p4 (Win Recovery)  : DAE6980DE697E851
```

### Mount Points & Storage Usage

```
Current Mount Status:
- /                : /dev/nvme0n1p2 (Btrfs subvol=@)       [875 GB free, 55 GB used]
- /home            : /dev/nvme0n1p2 (Btrfs subvol=@home)   [shared filesystem]
- /boot            : /dev/nvme0n1p1 (FAT32)                [933 MB free, 90 MB used]
- /boot/efi-windows: /dev/nvme1n1p1 (FAT32, read-only)     [for Windows auto-detect]
- [SWAP]           : /dev/zram0 (30.7 GB compressed RAM)   [50% of available RAM]
```

---

## 2. BTRFS SUBVOLUME STRUCTURE

### Current Subvolumes

```
Btrfs UUID: 388ac5b1-433c-46d2-8c1f-88cfdfae5297
Device: /dev/nvme0n1p2
Total Size: 930.5 GB
Used: 52.32 GiB (5.6%)

Subvolumes:
├── @ (ID 256)      → mounted at /
└── @home (ID 257)  → mounted at /home
```

### Mount Options (Current)

```
rw,relatime,ssd,discard=async,space_cache=v2,subvolid=256,subvol=/@,x-initrd.mount
```

**Key Features:**
- ✅ SSD optimizations: `ssd`, `discard=async`
- ✅ Space caching: `space_cache=v2` (modern, performant)
- ✅ Async discard: Doesn't block writes
- ⚠️  No snapshots configured
- ⚠️  No compression enabled
- ⚠️  No RAID or redundancy

---

## 3. SWAP CONFIGURATION ANALYSIS

### Current Setup: Zram Swap

```nix
zramSwap = {
  enable = true;
  memoryPercent = 50;      # 50% of total RAM
  algorithm = "zstd";      # Zstandard compression
};
swapDevices = [ ];         # No disk swap
```

**System Memory:**
- Zram size: ~31 GB (calculated as 50% of ~62 GB RAM)
- Current usage: 0 KB (unused)
- Priority: 5 (higher than disk swap, if any existed)

**Why Zram is Excellent Here:**
- ✅ ~3-4x compression ratio with zstd
- ✅ 60-80% faster than disk swap
- ✅ Reduces I/O wear on SSD
- ✅ Perfect for modern high-RAM systems
- ⚠️  Vulnerable to kernel OOM killer (no fallback to disk)

**Recommendation:** Keep zram; consider optional disk swap for true safety net.

---

## 4. BOOT PARTITION ANALYSIS

### EFI Setup Details

```
Primary EFI: /dev/nvme0n1p1 (1 GB)
- File system: FAT32 (UEFI standard)
- UUID: EA15-090D
- Mount: /boot
- Used: 90 MB / 1022 MB (9%)
- Permissions: fmask=0077, dmask=0077 (secure)

Secondary EFI: /dev/nvme1n1p1 (200 MB) 
- File system: FAT32 (Windows)
- UUID: F41B-3E96
- Mount: /boot/efi-windows (read-only, nofail)
- Purpose: Windows auto-detection for dual-boot
```

### Bootloader Configuration

```nix
boot.loader.systemd-boot = {
  enable = true;
  configurationLimit = 10      # Keep last 10 generations
  editor = false               # Disable editor (security)
  consoleMode = "auto"         # Auto-detect console
};

boot.loader.timeout = 5        # 5-second boot menu delay
boot.loader.efi.canTouchEfiVariables = true
```

**Boot Sequence:**
1. UEFI firmware loads systemd-boot from EFI partition
2. Systemd-boot scans `/boot` for NixOS generations
3. Systemd-boot auto-detects Windows when `/boot/efi-windows` is mounted
4. User selects OS (5-second timeout)
5. Selected OS boots

---

## 5. ENCRYPTION STATUS

### Current State: ⚠️ UNENCRYPTED

```
Partition          Encryption Status
─────────────────────────────────────
nvme0n1p1 (EFI)   None (FAT32)
nvme0n1p2 (Root)  None (Btrfs)
nvme1n1p1 (Win)   None (FAT32)
nvme1n1p3-4 (Win) BitLocker (potentially, Windows may have enabled it)
```

**Security Implications:**
- ⚠️  Full disk readable without authentication
- ⚠️  No protection against physical theft
- ⚠️  NixOS configuration visible from boot media
- ⚠️  User data in /home unencrypted at rest

**Recommendation:** Add LUKS encryption for production use.

---

## 6. CURRENT vs. DISKO: COMPARISON

### Current Approach (Static hardware.nix)

```
Pros:
✅ Simple and straightforward
✅ Works fine for single machine
✅ No additional dependencies

Cons:
❌ Manual partition management required
❌ Hard to reproduce on new hardware
❌ Difficult to modify partitions
❌ No version control of disk layout
❌ Error-prone manual steps during reinstall
❌ No advanced features (snapshots, RAID, etc.)
```

### Disko Approach (Declarative)

```
Pros:
✅ Reproducible disk layouts (git version controlled)
✅ Automated partitioning and formatting
✅ Easy reinstallation (one command)
✅ Supports complex setups (RAID, LVM, encryption)
✅ Integrates seamlessly with NixOS
✅ Can automate multi-disk configurations
✅ Enables infrastructure-as-code for storage
✅ Easy to modify and test layouts

Cons:
⚠️  Additional tooling to maintain
⚠️  Requires familiarity with disko DSL
⚠️  Risk of accidental data loss if misconfigured
```

---

## 7. DISKO INTEGRATION BENEFITS FOR THIS SYSTEM

### Use Cases Enabled by Disko

1. **System Reinstallation**
   ```bash
   disko --mode disko --disk /path/to/device
   # Automatically repartitions and formats
   # No manual steps or risk of mistakes
   ```

2. **Backup Strategy**
   - Keep disko config in git
   - Quickly rebuild on new hardware
   - Document exact disk layout for posterity

3. **Future Enhancements**
   - Add LUKS encryption layer
   - Configure Btrfs compression
   - Set up automated snapshots
   - Add optional disk swap fallback

4. **Multi-Machine Setup**
   - Easily deploy same layout to multiple laptops
   - Version control infrastructure

---

## 8. HARDWARE CAPABILITIES

### System Details

```
CPU: AMD Ryzen (supports KVM)
RAM: ~62 GB (inferred from zram sizing)
Boot Mode: UEFI
Storage: 2x NVMe SSDs (modern, fast)
Dual-Boot: Yes (Windows + NixOS)

Boot Modules:
- nvme, xhci_pci, thunderbolt, usb_storage, sd_mod, rtsx_pci_sdmmc
```

### Optimization Opportunities

- ✅ SSD-aware mount options already set
- ✅ Async discard already configured
- ✅ Zram swap for fast memory compression
- ⚠️  Could enable Btrfs compression (lz4 or zstd)
- ⚠️  Could enable Btrfs snapshots
- ⚠️  Could add encryption

---

