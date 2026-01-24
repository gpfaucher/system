# Declarative Disk Management - Visual Summary

## System Architecture Overview

```
╔═══════════════════════════════════════════════════════════════════╗
║                    CURRENT SYSTEM LAYOUT                          ║
╚═══════════════════════════════════════════════════════════════════╝

HARDWARE
┌─────────────────────────────────────────────────────────────────┐
│ AMD Ryzen CPU  |  62 GB RAM  |  UEFI Firmware  |  2x NVMe SSDs  │
└─────────────────────────────────────────────────────────────────┘

STORAGE DEVICES
┌──────────────────────────┐  ┌──────────────────────────┐
│   nvme0n1                │  │   nvme1n1                │
│   931.5 GB (NixOS)       │  │   953.9 GB (Windows)     │
├──────────────────────────┤  ├──────────────────────────┤
│ nvme0n1p1 (1 GB)         │  │ nvme1n1p1 (200 MB) EFI   │
│ FAT32 - /boot - EFI      │  │ FAT32 - Windows Boot     │
├──────────────────────────┤  │                          │
│ nvme0n1p2 (930 GB)       │  │ nvme1n1p2 (16 MB)        │
│ Btrfs                    │  │ (WinRE Recovery)         │
│ UUID: 388ac5b1-433c...   │  │                          │
│                          │  ├──────────────────────────┤
│ ┌──────────────────────┐ │  │ nvme1n1p3 (952 GB) NTFS  │
│ │ @ (root /)           │ │  │ Windows OS               │
│ │ subvolid=256         │ │  │                          │
│ └──────────────────────┘ │  ├──────────────────────────┤
│ ┌──────────────────────┐ │  │ nvme1n1p4 (751 MB) NTFS  │
│ │ @home (/home)        │ │  │ Windows Recovery         │
│ │ subvolid=257         │ │  │                          │
│ └──────────────────────┘ │  │                          │
└──────────────────────────┘  └──────────────────────────┘
     55 GB used                  (Dual-boot preserved)
     875 GB free

MEMORY & SWAP
┌──────────────────────────────────┐
│ Zram Swap: 30.7 GB               │
│ (50% of RAM)                     │
│ Algorithm: zstd                  │
│ Compression Ratio: 3-4x          │
│ Usage: Currently 0 KB            │
└──────────────────────────────────┘

BOOT CONFIGURATION
┌──────────────────────────────────────────┐
│ Bootloader: systemd-boot (EFI native)   │
│ Boot Menu Timeout: 5 seconds             │
│ Generations Kept: 10                     │
│ Editor: Disabled (secure)                │
│ Dual-boot: Windows auto-detected ✓       │
└──────────────────────────────────────────┘
```

---

## Current vs. Recommended Configuration

```
┌────────────────────────────────────────────────────────────────┐
│ FEATURE COMPARISON                                             │
├────────────────────────────────────────────────────────────────┤

📦 DISK LAYOUT
  Current:  ❌ Static (hardware.nix)        | 📄 1 file
  Target:   ✅ Declarative (disko)          | 🔧 Infrastructure-as-Code

🗂️  SUBVOLUMES
  Current:  ❌ 2 (@, @home)                | Limited organization
  Target:   ✅ 7 (@, @home, @var, @nix,   | Better flexibility
              @tmp, @root, @snapshots)

🔐 COMPRESSION
  Current:  ❌ None                         | 0% space savings
  Target:   ✅ zstd:3                       | ~20 GB savings (36%)

📸 SNAPSHOTS
  Current:  ❌ None                         | No point-in-time recovery
  Target:   ✅ snapper (hourly/daily)      | Quick accidental recovery

🔒 ENCRYPTION
  Current:  ❌ None                         | No protection against theft
  Target:   ✅ LUKS                         | Full-disk encryption

💾 SWAP
  Current:  ⚠️  zram only                   | No disk fallback
  Target:   ✅ zram + 16 GB disk            | OOM safety net

📋 VERSION CONTROL
  Current:  ❌ Git (config only)            | Disk layout not tracked
  Target:   ✅ Git (everything)             | Reproducible setup

🆘 RECOVERY
  Current:  ⚠️  Limited (config backups)    | Data loss vulnerable
  Target:   ✅ Multi-level (4 strategies)   | Comprehensive protection

└────────────────────────────────────────────────────────────────┘
```

---

## Migration Timeline

```
                    ┌─── PHASE 1 ───┐
                    │   WEEK 1       │
                    │   Prepare      │
                    │                │
                    ├─ Add disko     │
                    ├─ Create nix    │
                    ├─ Backup system │
                    └────────────────┘
                           │
                           ▼
                    ┌─── PHASE 2 ───┐
                    │   WEEKS 2-4    │
                    │   Test         │
                    │                │
                    ├─ Dry-run       │
                    ├─ VM testing    │
                    ├─ USB testing   │
                    └────────────────┘
                           │
                           ▼
                    ┌─── PHASE 3 ───┐
                    │   MONTH 2      │
                    │   Plan         │
                    │                │
                    ├─ Encryption    │
                    ├─ Backups       │
                    ├─ Verify config │
                    └────────────────┘
                           │
                           ▼
                    ┌─── PHASE 4 ───┐
                    │   MONTH 3      │
                    │   Deploy       │
                    │                │
                    ├─ Full backup   │
                    ├─ Format disk   │
                    ├─ Install system│
                    ├─ Verify boot   │
                    └────────────────┘
                           │
                           ▼
                    ┌─── PHASE 5 ───┐
                    │   ONGOING      │
                    │   Operate      │
                    │                │
                    ├─ Enable snapshot
                    ├─ Cloud backups │
                    ├─ Monthly drills│
                    └────────────────┘

                    Duration: 3-4 months
                    Risk Level: LOW
```

---

## Backup Strategy Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  BACKUP HIERARCHY                           │
└─────────────────────────────────────────────────────────────┘

LEVEL 1: Configuration
┌───────────────────────────────────────────┐
│ Git Repository (GitHub)                   │
│ ├─ NixOS configuration (flake.nix, etc)  │
│ ├─ Disko configuration                   │
│ └─ Recovery procedures (this repo)        │
│                                           │
│ Frequency: Continuous (push on commit)    │
│ Recovery Time: < 5 minutes                │
│ Data Loss Risk: MINIMAL                   │
└───────────────────────────────────────────┘
              ▼
LEVEL 2A: Local Snapshots
┌───────────────────────────────────────────┐
│ Btrfs Snapshots (snapper)                 │
│ ├─ Hourly snapshots (24 hours)           │
│ ├─ Daily snapshots (30 days)             │
│ └─ Monthly snapshots (12 months)         │
│                                           │
│ Frequency: Automatic (hourly/daily)       │
│ Recovery Time: < 1 minute                 │
│ Data Loss Risk: LOW                       │
└───────────────────────────────────────────┘
              ▼
LEVEL 2B: Cloud Sync
┌───────────────────────────────────────────┐
│ Cloud Backup (Duplicacy/Backblaze)        │
│ ├─ Home directory (/home)                │
│ ├─ Documents & Pictures                   │
│ └─ Encrypted & deduplicated               │
│                                           │
│ Frequency: Daily/Weekly                   │
│ Recovery Time: 1-10 minutes               │
│ Data Loss Risk: VERY LOW                  │
└───────────────────────────────────────────┘
              ▼
LEVEL 3: Full System Backups
┌───────────────────────────────────────────┐
│ External USB Drive (2TB USB-C)            │
│ ├─ Btrfs send/receive (incremental)      │
│ ├─ OR rsync backup (full copy)           │
│ ├─ Monthly snapshots                     │
│ └─ Checksums verified                     │
│                                           │
│ Frequency: Monthly                        │
│ Recovery Time: 30 minutes                 │
│ Data Loss Risk: VERY LOW                  │
└───────────────────────────────────────────┘
              ▼
LEVEL 4: Windows Partition
┌───────────────────────────────────────────┐
│ Windows Disk Image                        │
│ ├─ DD image of nvme1n1                   │
│ ├─ Partition-by-partition backup         │
│ └─ SHA256 checksums                       │
│                                           │
│ Frequency: Manual/Quarterly               │
│ Recovery Time: 1 hour                     │
│ Data Loss Risk: VERY LOW                  │
└───────────────────────────────────────────┘
```

---

## Risk Mitigation Path

```
CURRENT VULNERABILITIES          MITIGATION STRATEGY
┌──────────────────────┐         ┌──────────────────────┐
│ No encryption        │ ────→   │ Add LUKS (Phase 4)   │
│ Physical theft risk  │         │ Full-disk encryption │
└──────────────────────┘         └──────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│ Static config        │ ────→   │ Add disko (Phase 1)  │
│ Hard to reproduce    │         │ Version-controlled   │
└──────────────────────┘         └──────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│ No snapshots         │ ────→   │ Enable snapper       │
│ Accidental deletion  │         │ (Phase 5)            │
│ Data loss           │         │ Hourly/daily backup  │
└──────────────────────┘         └──────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│ Git backup only      │ ────→   │ Add external backup  │
│ Single location      │         │ (Phase 3)            │
│ Hardware failure     │         │ + cloud sync (Phase 3)
└──────────────────────┘         └──────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│ zram only swap       │ ────→   │ Add disk swap        │
│ OOM vulnerability    │         │ (Phase 4)            │
│                      │         │ 16GB safety net      │
└──────────────────────┘         └──────────────────────┘
```

---

## Key Metrics at a Glance

```
STORAGE CAPACITY
┌─────────────────────────────────────────────────────┐
│ Primary Disk (nvme0n1): 931.5 GB                    │
│  ├─ Used: 55 GB (6%)                               │
│  ├─ Available: 875 GB (94%)                         │
│  └─ With compression: 845 GB (after 20GB savings)  │
│                                                      │
│ Secondary Disk (nvme1n1): 953.9 GB (Windows)       │
│                                                      │
│ Total Available: 1,885.4 GB                         │
│ Utilization: 2.9% (very healthy)                   │
└─────────────────────────────────────────────────────┘

SWAP CONFIGURATION
┌─────────────────────────────────────────────────────┐
│ Total RAM: ~62 GB                                   │
│ Zram Swap: 30.7 GB (50% of RAM)                    │
│ Compression: zstd (3-4x ratio)                     │
│ Effective: ~90-120 GB virtual memory                │
│                                                      │
│ Recommended Addition:                              │
│ ├─ Disk Swap: 16 GB (for OOM safety)              │
│ └─ Total Virtual Memory: 106-136 GB                │
└─────────────────────────────────────────────────────┘

SUBVOLUME ORGANIZATION
┌─────────────────────────────────────────────────────┐
│ Current Setup (2 subvolumes)                        │
│ ├─ @ → /                                            │
│ └─ @home → /home                                    │
│                                                      │
│ Recommended (7 subvolumes)                          │
│ ├─ @ → /                                            │
│ ├─ @home → /home                                    │
│ ├─ @var → /var        (logs, caches)              │
│ ├─ @nix → /nix        (store, read-mostly)        │
│ ├─ @tmp → /tmp        (temporary)                 │
│ ├─ @root → /root      (root home)                 │
│ └─ @snapshots → /.snapshots (recovery points)    │
│                                                      │
│ Benefits:                                           │
│ ├─ Better snapshot management                      │
│ ├─ Separate retention policies                     │
│ ├─ Easier disaster recovery                        │
│ └─ Improved security (ro mounting options)         │
└─────────────────────────────────────────────────────┘
```

---

## Document Quick Guide

```
START HERE
    ▼
📄 DISK-MANAGEMENT-INDEX.md
   (Navigation guide - choose your path)
    ▼
    ├─→ 📊 disk-analysis.md (Understand current)
    │
    ├─→ 🚀 quick-reference.md (Quick answers)
    │
    ├─→ 📝 disko-current.nix (Current config)
    │       ├─ Test import (safe)
    │       └─ Learn syntax
    │
    ├─→ ✨ disko-enhanced.nix (Target config)
    │       └─ Production setup
    │
    ├─→ 🛣️  migration-guide.md (How to migrate)
    │       ├─ Phase-by-phase
    │       ├─ Risk mitigation
    │       └─ Rollback procedures
    │
    └─→ 💾 backup-strategy.md (Safety net)
           ├─ 4-level backup hierarchy
           ├─ Recovery procedures
           └─ Automation setup
```

---

## Success Criteria

```
✅ PHASE 1 COMPLETE (Week 1)
   ├─ disko added to flake.nix
   ├─ disko.nix file created
   ├─ Full system backup created
   └─ Documentation reviewed

✅ PHASE 2 COMPLETE (Weeks 2-4)
   ├─ Dry-run tests passed
   ├─ VM tests successful
   ├─ USB tests functional
   └─ Configuration verified

✅ PHASE 3 COMPLETE (Month 2)
   ├─ Enhanced config finalized
   ├─ LUKS encryption planned
   ├─ Backup strategy documented
   └─ Test recovery completed

✅ PHASE 4 COMPLETE (Month 3)
   ├─ System deployed
   ├─ All partitions verified
   ├─ Boot works (NixOS + Windows)
   └─ Data restored

✅ PHASE 5 ONGOING
   ├─ snapper snapshots working
   ├─ Cloud backups configured
   ├─ Monthly recovery drills
   └─ Zero issues reported
```

---

## Resources Quick Links

```
📖 OFFICIAL DOCUMENTATION
   ├─ Disko: https://github.com/nix-community/disko
   ├─ Btrfs: https://btrfs.readthedocs.io/
   ├─ NixOS: https://nixos.org/manual/
   └─ Snapper: https://snapper.io/

💬 COMMUNITY
   ├─ NixOS Discourse: https://discourse.nixos.org/
   ├─ NixOS Wiki: https://wiki.nixos.org/
   └─ Matrix Chat: #nixos:matrix.org

🛠️  TOOLS
   ├─ snapper: Btrfs snapshots
   ├─ Duplicacy: Encrypted backups
   ├─ Backblaze: Cloud backup ($70/year)
   └─ Nextcloud: File sync
```

---

## Implementation Checklist

```
WEEK 1 - PREPARATION
  ☐ Read DISK-MANAGEMENT-INDEX.md
  ☐ Read disk-analysis.md
  ☐ Create full system backup
  ☐ Review disko documentation
  ☐ Understand disko-current.nix
  ☐ Add disko to flake.nix
  ☐ Create disko.nix file
  ☐ Commit to git

WEEKS 2-4 - TESTING
  ☐ Dry-build test (nixos-rebuild dry-build)
  ☐ Dry-run test (disko --mode disko --dry-run)
  ☐ VM test (build and run VM)
  ☐ USB test (test on USB drive)
  ☐ Verify configuration accuracy
  ☐ Document any issues
  ☐ Review migration-guide.md

MONTH 2 - PLANNING
  ☐ Decide on LUKS encryption
  ☐ Review disko-enhanced.nix
  ☐ Plan backup strategy
  ☐ Estimate downtime
  ☐ Create external backup
  ☐ Test recovery procedures
  ☐ Prepare NixOS installer USB

MONTH 3 - DEPLOYMENT
  ☐ Full system backup (to external)
  ☐ Boot NixOS installer
  ☐ Run disko format
  ☐ Run nixos-install
  ☐ Verify all systems boot
  ☐ Test Windows dual-boot
  ☐ Restore user data
  ☐ Commit final configuration

ONGOING - OPERATIONS
  ☐ Enable snapper snapshots
  ☐ Configure Duplicacy/Backblaze
  ☐ Set up automatic backups
  ☐ Monthly recovery drills
  ☐ Monitor disk usage
  ☐ Update documentation
```

---

## Summary

```
🎯 GOAL: Migrate from static to declarative disk management

📊 CURRENT STATE: Healthy, well-optimized system
                  (6% disk usage, good SSD config)

🔧 TARGET STATE: Infrastructure-as-code disk setup
                 (Reproducible, encrypted, backed up)

📅 TIMELINE: 3-4 months (phased, low-risk approach)

✅ BENEFIT: Reproducible system, version control, snapshots,
            encryption, and comprehensive backups

🛡️  SAFETY: Multi-level backups at each phase

📚 DOCUMENTATION: Complete (7 documents, 52 KB)

🚀 READY: All configurations and procedures provided
```
