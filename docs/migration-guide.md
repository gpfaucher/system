# Migration Guide: From Static hardware.nix to Disko

## Overview

This guide explains how to migrate from the current static hardware configuration to a declarative disko-based setup.

---

## Phase 1: Preparation (Low Risk)

### Step 1.1: Add Disko to Flake

Edit `flake.nix` to add disko as input:

```nix
# In inputs section, add:
inputs = {
  # ... existing inputs ...
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

# In outputs section, add disko to modules:
outputs = { self, nixpkgs, disko, ... }@inputs:
  {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      modules = [
        disko.nixosModules.disko
        ./hosts/laptop
        # ... rest of modules ...
      ];
    };
  };
```

### Step 1.2: Create Disko Configuration File

Create `hosts/laptop/disko.nix` with the basic (non-destructive) configuration that matches current setup.

This documents the current layout without making changes.

### Step 1.3: Test Import (No Changes)

```bash
# Just import disko configuration - it won't format anything
nixos-rebuild switch --flake .#laptop
```

**What happens:** NixOS loads disko configuration but in "dry-run" mode. No disks are touched.

---

## Phase 2: Testing (Medium Risk - Only on Test System!)

### ⚠️ BACKUP FIRST

```bash
# Full backup before any changes
sudo timeshift --create --comments "Before disko migration"

# OR with rsync to external drive
rsync -avz --delete / /media/backup/
```

### Option A: Fresh Install on USB Test Drive (RECOMMENDED)

```bash
# Create a USB test drive
# Partition as /dev/sdX

# Format and install with disko (test configuration)
sudo disko format --disk /dev/sdX

# Boot into the fresh installation
# Verify everything works
```

### Option B: Dry-Run on Current System

```bash
# See what disko would do (doesn't execute)
sudo disko disko --disk /dev/nvme0n1 --mode disko --dry-run

# Review output carefully
# Verify partitioning matches expectations
```

---

## Phase 3: Migration Path Decision

### Path A: Gradual (Zero Downtime)

If you want to keep the system running while migrating:

1. **Install disko configuration** alongside current hardware.nix
2. **Continue using hardware.nix** (keep system stable)
3. **Test disko on a secondary drive** or VM
4. **When confident**, switch to disko at next reinstall

**Pros:** Zero downtime, low risk
**Cons:** Slower, requires waiting for reinst

all

### Path B: Clean Install (Cleanest)

For a fresh, optimized system:

1. Boot NixOS installer (USB)
2. Run disko to partition/format fresh:
   ```bash
   sudo disko format --disk /dev/nvme0n1 ./disko.nix
   ```
3. Install NixOS with flake:
   ```bash
   sudo nixos-install --flake .#laptop
   ```
4. Reboot

**Pros:** Cleanest install, optimized layout
**Cons:** Requires reinstall, data migration needed

---

## Step-by-Step: Gradual Migration (Recommended)

### 1. Add Disko to Flake

```bash
cd ~/projects/system

# Edit flake.nix
# Add disko input and import
```

### 2. Create hosts/laptop/disko.nix

Use the "disko_current.nix" configuration provided.

### 3. Update hosts/laptop/default.nix

```nix
{
  imports = [
    ./disko.nix          # NEW: Import disko
    ./hardware.nix       # Keep for now (disko may override)
    # ... rest of imports ...
  ];
}
```

### 4. Build (Test Import)

```bash
# This will fail if there are conflicts, but won't modify disks
nix flake check
nixos-rebuild dry-build --flake .#laptop
```

### 5. Test on VM (Optional)

```bash
# Build a VM that uses disko
nix build .#nixosConfigurations.laptop.config.system.build.vm
./result/bin/run-laptop-vm

# In VM:
# - Verify mount points
# - Check subvolumes
# - Test snapshots (if configured)
```

### 6. Eventually: Clean Install

When ready for the full migration:

```bash
# Boot into NixOS installer USB
# Run disko
sudo disko format --disk /dev/nvme0n1 ./hosts/laptop/disko.nix

# Install system
sudo nixos-install --flake github:gabrieljense/system#laptop

# Reboot
reboot
```

---

## Recommended Enhanced Migration Path

For this specific system (dual-boot, 62GB RAM):

### Immediate Changes (disko)

- ✅ Add disko configuration to version control
- ✅ Document current disk layout (disko_current.nix)

### Short-term (< 3 months)

- ✅ Enable Btrfs compression (zstd:3)
- ✅ Add @snapshots subvolume
- ✅ Test snapshot tooling (snapper)

### Medium-term (3-6 months)

- 🔄 Add LUKS encryption (requires reinstall)
- 🔄 Add disk swap partition (16GB)
- 🔄 Reorganize into more subvolumes

### Long-term (6+ months)

- 🤔 Evaluate RAID if adding more disks
- 🤔 Consider LVM for flexibility
- 🤔 Automate backup snapshots

---

## Rollback Plan

If something goes wrong:

### If Import Fails

```bash
# Remove disko from imports
# Revert flake.nix changes
git checkout flake.nix
nixos-rebuild switch
```

### If System Won't Boot (Post-Format)

```bash
# Boot NixOS installer USB
# Mount root filesystem
# Restore from backup
```

### If Disko Configuration is Wrong

```bash
# Boot into recovery mode
# Fix disko.nix
# Re-run disko format
# Re-install system
```

---

## Troubleshooting

### Issue: "disko not found"

```bash
# Make sure flake.nix includes disko and modules import it
# Update flake lock
nix flake update
```

### Issue: Partition UUIDs don't match

```bash
# After formatting with disko, UUIDs will change
# Update disko.nix with new UUIDs:
lsblk -o NAME,UUID
# Or let disko handle it automatically
```

### Issue: Dual-boot broken after disko

```bash
# Disko shouldn't touch Windows partitions
# Verify disko.nix only references nvme0n1
# Check that Windows EFI is marked read-only
```

### Issue: Data loss

**PREVENTION:**

- Always backup first
- Test on secondary drive first
- Use dry-run mode

**RECOVERY:**

```bash
# If using timeshift backup
sudo timeshift --restore

# If using rsync backup
rsync -avz /media/backup/ /
```

---

## Validation Checklist

After migration, verify:

- [ ] System boots successfully
- [ ] All filesystems mounted correctly
  ```bash
  mount | grep btrfs
  ```
- [ ] Subvolumes present
  ```bash
  btrfs subvolume list /
  ```
- [ ] Disk space correct
  ```bash
  df -h
  ```
- [ ] Zram swap active
  ```bash
  cat /proc/swaps
  ```
- [ ] Windows still boots (dual-boot)
  ```bash
  # Restart and check boot menu
  ```
- [ ] Snapshots work (if configured)
  ```bash
  btrfs subvolume snapshot / /.snapshots/test-$(date +%s)
  ```
- [ ] NixOS rebuilds work
  ```bash
  nixos-rebuild switch
  ```

---

## Timeline Recommendation

**Phase 1 (Week 1):** Add disko to flake, create disko.nix (documentation)
**Phase 2 (Weeks 2-4):** Test with dry-run, on VM, and on USB drive
**Phase 3 (Month 2):** Perform clean install with enhanced configuration
**Phase 4 (Ongoing):** Configure snapshots, compression, automation

This approach is **non-disruptive** and allows you to migrate at your own pace.
