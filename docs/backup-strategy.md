# Backup & Snapshot Strategy for NixOS System

## Overview

This document outlines a comprehensive backup and snapshot strategy for your dual-boot laptop using Btrfs, Disko, and declarative NixOS configuration.

---

## Part 1: Backup Strategy Hierarchy

### Level 1: System Configuration Backup (Git)

**What:** NixOS configuration in `/home/gabriel/projects/system`
**Frequency:** Continuous (after each commit)
**Storage:** GitHub (remote)
**Recovery Time:** < 5 minutes
**Data Loss Risk:** Minimal (unless GitHub account compromised)

```bash
# Daily backup (already using git)
cd ~/projects/system
git push

# Verify backup
git log --oneline | head -5
```

**Recovery:**
```bash
# Clone fresh system configuration
git clone https://github.com/gabrieljense/system.git
# Install with disko
sudo disko format --disk /dev/nvme0n1 ./hosts/laptop/disko.nix
nixos-install --flake .#laptop
```

---

### Level 2: Home Directory Backup (Btrfs Snapshots + Cloud)

**What:** `/home/gabriel` user data
**Frequency:** Daily (automatic snapshots) + Weekly (cloud sync)
**Storage:** Local snapshots + Nextcloud/Backblaze
**Recovery Time:** 1 minute (restore from snapshot) or 1 hour (cloud download)
**Data Loss Risk:** Moderate (protected against hardware failure and accidental deletion)

#### 2A: Local Btrfs Snapshots (Hourly/Daily)

```nix
# In hosts/laptop/default.nix or new module services.nix

services.snapper = {
  enable = true;
  snapshotRootOnBoot = true;
  configs = {
    home = {
      SUBVOLUME = "/home";
      MOUNT_POINT = "/home";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      
      # Keep daily snapshots for 1 month
      TIMELINE_LIMIT_DAILY = 30;
      # Keep hourly snapshots for 24 hours
      TIMELINE_LIMIT_HOURLY = 24;
      # Keep monthly snapshots for 1 year
      TIMELINE_LIMIT_MONTHLY = 12;
      
      # Space optimization
      FREE_LIMIT = "0.2";           # Keep 20% free space minimum
      FREE_LIMIT_PERCENTAGE = "20"; # Or 20%
    };
    root = {
      SUBVOLUME = "/";
      MOUNT_POINT = "/";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_DAILY = 14;    # Keep 2 weeks for root
      TIMELINE_LIMIT_HOURLY = 12;
      TIMELINE_LIMIT_MONTHLY = 3;
    };
  };
};
```

**Usage:**
```bash
# List snapshots
snapper -c home list

# Restore a file from snapshot
snapper -c home status 5..0 | grep deleted_file
snapper -c home diff 5 deleted_file

# Restore directory to point-in-time
snapper -c home undochange 5..0
```

#### 2B: Cloud Sync (Nextcloud/Backblaze)

```bash
# Option 1: Nextcloud sync (free tier available)
# Install Nextcloud client, sync ~/Documents and ~/Pictures

# Option 2: Backblaze (unlimited, $70/year)
# Continuously backs up /home to cloud
# Can restore entire directories quickly

# Option 3: Duplicacy (open-source, flexible)
# Encrypts and deduplicates backups
# Supports multiple cloud backends
```

**Configuration for Duplicacy:**
```bash
# Install
nixos-rebuild switch  # after adding to packages

# Initialize
duplicacy init -repository /home/gabriel backup s3://my-bucket

# Automatic backup (add to cron)
0 2 * * * duplicacy backup -repository /home/gabriel
0 3 * * 0 duplicacy prune -repository /home/gabriel -keep 0:30 -keep 7:7 -keep 30:3 -keep 365:1
```

---

### Level 3: Full System Image Backup (External Drive)

**What:** Complete system state (for disaster recovery)
**Frequency:** Monthly or before major changes
**Storage:** External 2TB USB-C drive
**Recovery Time:** 30 minutes
**Data Loss Risk:** Low (hardware redundancy)

#### 3A: Btrfs Send/Receive

```bash
#!/bin/bash
# backup-system.sh

BACKUP_MOUNT="/mnt/backup"
DATE=$(date +%Y%m%d-%H%M%S)

# Mount backup drive
sudo mount /dev/disk/by-uuid/XXXXX-XXXXX $BACKUP_MOUNT

# Create snapshots
sudo btrfs subvolume snapshot -r / $BACKUP_MOUNT/root-$DATE
sudo btrfs subvolume snapshot -r /home $BACKUP_MOUNT/home-$DATE

# Or use send/receive (incremental)
# Create base snapshot
sudo btrfs subvolume snapshot -r / $BACKUP_MOUNT/root-base
# Create incremental snapshot
sudo btrfs subvolume snapshot -r / /.snapshots/root-incremental
# Send incremental
sudo btrfs send -p $BACKUP_MOUNT/root-base /.snapshots/root-incremental | \
  sudo btrfs receive $BACKUP_MOUNT/

# Unmount
sudo umount $BACKUP_MOUNT
```

#### 3B: Rsync (Traditional, Flexible)

```bash
#!/bin/bash
# backup-rsync.sh

BACKUP_MOUNT="/mnt/backup"
DATE=$(date +%Y%m%d)

sudo mount /dev/disk/by-uuid/XXXXX-XXXXX $BACKUP_MOUNT

# Full backup with checksums
rsync -avz --checksums \
  --exclude={/sys,/proc,/dev,/run,/tmp,.cache,/boot/efi-windows} \
  / $BACKUP_MOUNT/system-$DATE/

# Create metadata
echo "Backup created: $DATE" > $BACKUP_MOUNT/system-$DATE/BACKUP_INFO
nixos-rebuild build --flake ~/projects/system#laptop 2>&1 | \
  tee $BACKUP_MOUNT/system-$DATE/nixos-version.txt

sudo umount $BACKUP_MOUNT
```

---

### Level 4: Windows Partition Preservation

**What:** /dev/nvme1n1 partitions (Windows)
**Frequency:** Manually before major Windows updates
**Storage:** External drive snapshot
**Recovery Time:** 1 hour
**Data Loss Risk:** Very low (dedicated disk)

```bash
# Create Windows backup image
sudo dd if=/dev/nvme1n1 of=/mnt/backup/windows-backup-$(date +%s).img bs=1M

# Or partition-by-partition
sudo dd if=/dev/nvme1n1p3 of=/mnt/backup/windows-os.img bs=1M
sudo dd if=/dev/nvme1n1p4 of=/mnt/backup/windows-recovery.img bs=1M

# Verify with checksums
sha256sum /mnt/backup/windows-*.img | tee /mnt/backup/windows-backup-checksums.txt
```

---

## Part 2: Automated Snapshot & Backup Schedule

### Daily Automated Tasks

```bash
# In /etc/cron.d/backups or systemd timer

# 2 AM: System snapshots (managed by snapper)
0 2 * * * /usr/bin/snapper -c home create --description "daily-home"
0 2 * * * /usr/bin/snapper -c root create --description "daily-root"

# 3 AM: Cleanup old snapshots
0 3 * * * /usr/bin/snapper -c home cleanup timeline
0 3 * * * /usr/bin/snapper -c root cleanup timeline

# 4 AM: Incremental cloud backup (if external backup present)
0 4 * * * /opt/backup-incremental.sh 2>&1 | logger
```

### Monthly Automated Tasks

```bash
# First day of month: Full backup to external drive
0 1 1 * * /opt/backup-full.sh 2>&1 | logger

# Verify backups
0 2 1 * * /opt/verify-backups.sh 2>&1 | logger
```

---

## Part 3: Recovery Procedures

### Scenario 1: Accidental File Deletion

**Time to recover:** < 1 minute
**Steps:**
```bash
# List hourly snapshots from past 24 hours
snapper -c home list -t single | grep hourly

# Find snapshot before deletion
snapper -c home diff 10..0 | grep deleted-file.txt

# Restore file
snapper -c home status 10..0 --inaccessible
sudo cp /.snapshots/10/snapshot/home/gabriel/deleted-file.txt ~/

# Or rollback entire directory
snapper -c home undochange 10..0
```

### Scenario 2: Hard Drive Failure

**Time to recover:** 1-2 hours
**Prerequisites:** External backup exists
**Steps:**
```bash
# Boot NixOS installer USB
# Replace failed drive
# Partition and format with disko
sudo disko format --disk /dev/nvme0n1 ./disko.nix

# Restore from backup
sudo mount /dev/nvme0n1p2 /mnt
sudo btrfs receive -f /mnt/backup/home-backup.btrfs /mnt/home

# Or restore with rsync
rsync -avz /mnt/backup/system-latest/ /mnt/

# Reinstall bootloader
sudo nixos-install --flake .#laptop
```

### Scenario 3: Complete System Corruption

**Time to recover:** 30 minutes
**Prerequisites:** Git repo + external backup
**Steps:**
```bash
# Boot NixOS installer
# Partition with disko (using config from git)
git clone https://github.com/gabrieljense/system.git
sudo disko format --disk /dev/nvme0n1 ./system/hosts/laptop/disko.nix

# Install base system
sudo nixos-install --flake ./system#laptop

# Restore home directory
sudo mount /dev/nvme0n1p2 /mnt
rsync -avz /backup/home-latest/ /mnt/home/

# Or restore from cloud backup
# Download from Backblaze/Nextcloud
```

### Scenario 4: Windows Won't Boot After Disko

**Time to recover:** 5 minutes
**Steps:**
```bash
# NixOS should still boot (disko doesn't touch Windows disk)
# Boot NixOS
# Verify Windows EFI mounted
mount | grep efi-windows

# Check systemd-boot menu
# Windows should auto-appear if EFI partition mounted

# If not, manually add to boot menu
efibootmgr -c -d /dev/nvme1n1 -p 1 -L "Windows" -l '\EFI\Microsoft\Boot\bootmgfw.efi'
```

---

## Part 4: Backup Strategy Configuration (Nix)

Create `modules/system/backups.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  # Enable snapper for automatic snapshots
  services.snapper.enable = true;

  # Enable fstrim for SSD optimization
  services.fstrim.enable = true;

  # Install backup tools
  environment.systemPackages = with pkgs; [
    btrfs-progs
    snapper
    rsync
    duplicacy
    compsize      # Check btrfs compression ratio
  ];

  # Automatic daily cleanup
  systemd.timers.snapper-cleanup = {
    description = "Cleanup old snapshots";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      OnBootSec = "5min";
      Unit = "snapper-cleanup.service";
    };
  };

  systemd.services.snapper-cleanup = {
    description = "Cleanup snapshots";
    script = ''
      ${pkgs.snapper}/bin/snapper -c home cleanup timeline
      ${pkgs.snapper}/bin/snapper -c root cleanup timeline
    '';
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "journal";
    };
  };
}
```

---

## Part 5: Recovery Testing & Validation

### Monthly Recovery Drill

```bash
#!/bin/bash
# test-recovery.sh

echo "Testing snapshot recovery..."

# Create test file
touch ~/test-recovery.txt

# Create snapshot
snapper -c home create --description "test-recovery"

# Delete test file
rm ~/test-recovery.txt

# List snapshots
snapper -c home list

# Find snapshot before deletion
SNAP_NUM=$(snapper -c home list -t single | grep test-recovery | head -1 | awk '{print $1}')

# Verify recovery would work
snapper -c home diff $SNAP_NUM..0 | grep test-recovery

# Restore
snapper -c home undochange $((SNAP_NUM-1))..$SNAP_NUM

# Verify recovery
if [ -f ~/test-recovery.txt ]; then
  echo "✓ Recovery successful"
else
  echo "✗ Recovery failed"
fi
```

Run this monthly:
```bash
0 5 15 * * /opt/test-recovery.sh 2>&1 | mail -s "Recovery Test" gabriel@example.com
```

---

## Summary Table

| Level | What | Frequency | Storage | Recovery Time |
|-------|------|-----------|---------|----------------|
| 1 | NixOS Config | Git (continuous) | GitHub | < 5 min |
| 2A | Home Snapshots | Hourly/Daily | Local Btrfs | < 1 min |
| 2B | Cloud Sync | Weekly | Nextcloud/Backblaze | 1-10 min |
| 3A | Full System | Monthly | External 2TB USB | 30 min |
| 3B | Rsync Backup | Monthly | External USB | 30 min |
| 4 | Windows Partition | Manual/Quarterly | External USB | 1 hour |

---

## Recommended Implementation Order

1. **Week 1:** Set up Snapper for automated snapshots
2. **Week 2:** Configure Duplicacy or Nextcloud sync to cloud
3. **Week 3:** Create external backup drive setup
4. **Week 4:** Document recovery procedures and test monthly

This comprehensive backup strategy provides **multiple layers of protection** with different recovery time objectives and redundancy characteristics.

