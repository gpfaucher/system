# Declarative Disk Management - Complete Research & Analysis

## Document Index

This comprehensive research package contains complete analysis of the current disk management setup and a detailed path to migrate to declarative disk management using Disko.

### 📋 Documents Overview

#### 1. **disk-analysis.md** (7.1 KB)
**Start here for understanding the current system.**

Complete analysis of the existing disk setup including:
- Current partition layout and UUIDs
- Btrfs subvolume structure
- Swap configuration (zram analysis)
- Boot partition and EFI setup
- Encryption status (currently unencrypted)
- Comparison between current and disko approaches
- Hardware capabilities and optimization opportunities

**Key Findings:**
- ✅ Healthy system with good SSD optimizations
- ⚠️ No disko integration (static configuration)
- ⚠️ No LUKS encryption
- ⚠️ No snapshots or automated backups

---

#### 2. **quick-reference.md** (9.2 KB)
**Quick reference guide and checklists.**

At-a-glance information for day-to-day operations:
- System overview diagram
- Quick facts table (current vs. recommended)
- Implementation timeline
- Common commands reference
- Troubleshooting checklist
- Security considerations
- Performance tuning guide
- Next steps checklist

**Use when:** You need quick answers or command reference.

---

#### 3. **disko-current.nix** (3.1 KB)
**Disko configuration matching CURRENT setup.**

Ready-to-use Nix configuration that:
- Replicates exact current partitioning
- Documents disk layout in declarative form
- Includes basic Btrfs subvolume setup
- Good for initial testing and learning

**Use when:**
- Testing disko import (no changes to disk)
- Creating backup reference configuration
- Learning disko syntax

**Status:** Non-destructive, safe to commit to git

---

#### 4. **disko-enhanced.nix** (4.2 KB)
**Enhanced Disko configuration with improvements.**

Production-ready configuration with enhancements:
- LUKS encryption on root partition
- Larger EFI partition (2GB for safety)
- Swap partition (16GB fallback for zram)
- 7 Btrfs subvolumes (organized, flexible)
- Compression enabled (zstd:3)
- Snapshot support via separate @snapshots subvolume

**Use when:**
- Deploying enhanced system
- Want encryption and better organization
- Planning long-term system stability

**Warning:** Requires full system reinstall and data migration

---

#### 5. **migration-guide.md** (6.8 KB)
**Step-by-step migration from static to declarative disks.**

Comprehensive migration planning:
- Phase 1: Low-risk preparation steps
- Phase 2: Testing with dry-run and USB
- Phase 3: Migration path decision (gradual vs. clean)
- Step-by-step implementation guide
- Rollback and recovery procedures
- Troubleshooting for common issues
- Validation checklist
- Recommended timeline (3-4 months)

**Use when:**
- Planning the migration
- Need detailed step-by-step instructions
- Want to understand risk mitigation

**Recommended Approach:** Gradual migration (zero downtime)

---

#### 6. **backup-strategy.md** (11 KB)
**Comprehensive backup and snapshot strategy.**

Multi-level backup strategy with:
- Level 1: Git-based config backup (GitHub)
- Level 2A: Btrfs snapshots (hourly/daily with snapper)
- Level 2B: Cloud sync (Nextcloud/Backblaze/Duplicacy)
- Level 3A: Full system backups (btrfs send/receive)
- Level 3B: Rsync backups (to external drive)
- Level 4: Windows partition preservation
- Recovery procedures for 4 disaster scenarios
- Nix configuration for backup automation
- Recovery testing and validation procedures

**Use when:**
- Setting up automated backups
- Need recovery procedure for specific scenario
- Want to test recovery capability

**Implementation Order:**
1. Week 1: Snapper snapshots
2. Week 2: Cloud sync (Duplicacy/Nextcloud)
3. Week 3: External backup setup
4. Week 4: Documentation and testing

---

## Quick Navigation

### For Different Audiences

**System Administrator / DevOps:**
1. Read: disk-analysis.md (current state)
2. Review: disko-enhanced.nix (target state)
3. Plan: migration-guide.md (execution)
4. Implement: backup-strategy.md (safety net)

**NixOS Enthusiast:**
1. Read: quick-reference.md (overview)
2. Study: disko-current.nix (syntax)
3. Experiment: disko-enhanced.nix (advanced)
4. Reference: migration-guide.md (when ready)

**Security-Focused:**
1. Read: disk-analysis.md (encryption status)
2. Review: disko-enhanced.nix (LUKS config)
3. Plan: backup-strategy.md (disaster recovery)
4. Check: quick-reference.md (security table)

**Backup/Recovery Focused:**
1. Read: backup-strategy.md (complete overview)
2. Reference: quick-reference.md (commands)
3. Test: recovery procedures (monthly drills)

---

## Current System Summary

```
System: NixOS Laptop (Gabriel's Development Machine)
Hardware: AMD Ryzen, 62GB RAM, 2x NVMe SSDs, UEFI
Dual-Boot: Windows + NixOS

Current Setup:
├─ Storage: Btrfs (931.5 GB)
├─ Swap: zram 30.7 GB (50% of RAM)
├─ Boot: systemd-boot (EFI)
├─ Encryption: None
├─ Snapshots: None
├─ Configuration: Static hardware.nix
└─ Disk Management: Manual

Goal: Migrate to Declarative Disk Management
├─ Tool: Disko (nix-community)
├─ Benefits: Reproducible, version-controlled, infrastructure-as-code
├─ Timeline: 3-4 months (phased approach)
└─ Risk Level: Low (with proper planning)
```

---

## Key Statistics

| Metric | Value |
|--------|-------|
| **Primary Disk** | 931.5 GB (nvme0n1) |
| **Secondary Disk** | 953.9 GB (nvme1n1, Windows) |
| **Current Usage** | 55 GB (6% of primary) |
| **Free Space** | 875 GB (94%) |
| **RAM** | ~62 GB |
| **Btrfs Subvolumes** | 2 current, 7 recommended |
| **Boot Method** | UEFI + systemd-boot |
| **Backup Locations** | 1 (git) → 4 recommended |

---

## Implementation Roadmap

### Phase 1: Preparation (Week 1)
- [ ] Read all documentation
- [ ] Create full system backup
- [ ] Add disko to flake.nix
- [ ] Create basic disko.nix

### Phase 2: Testing (Weeks 2-4)
- [ ] Test disko import (dry-build)
- [ ] Test on VM
- [ ] Test on USB drive
- [ ] Verify configuration

### Phase 3: Enhancement (Month 2)
- [ ] Create enhanced disko.nix
- [ ] Add compression settings
- [ ] Plan LUKS encryption
- [ ] Create full external backup

### Phase 4: Deployment (Month 3)
- [ ] Boot NixOS installer
- [ ] Run disko format
- [ ] Run nixos-install
- [ ] Verify all systems

### Phase 5: Operations (Ongoing)
- [ ] Enable snapper
- [ ] Configure cloud backups
- [ ] Monthly recovery drills
- [ ] Monitor and optimize

---

## Key Decisions to Make

1. **Encryption**: Add LUKS now or later?
   - Recommendation: Add in Phase 4 (requires reinstall anyway)

2. **Snapshots**: Enable snapper for hourly/daily snapshots?
   - Recommendation: Yes, after migration to disko

3. **Backups**: Set up cloud backups?
   - Recommendation: Yes, use Duplicacy or Backblaze

4. **Swap**: Keep zram-only or add disk swap?
   - Recommendation: Add 16GB disk swap for safety

5. **Compression**: Enable Btrfs compression?
   - Recommendation: Yes, use zstd:3 (good balance)

---

## Files Organization

```
/home/gabriel/projects/system/
├── docs/
│   ├── DISK-MANAGEMENT-INDEX.md          [This file]
│   ├── disk-analysis.md                   [Current state analysis]
│   ├── quick-reference.md                 [Quick reference guide]
│   ├── disko-current.nix                  [Basic disko config]
│   ├── disko-enhanced.nix                 [Enhanced disko config]
│   ├── migration-guide.md                 [Step-by-step migration]
│   └── backup-strategy.md                 [Backup procedures]
├── hosts/
│   └── laptop/
│       ├── default.nix                    [Host configuration]
│       ├── hardware.nix                   [Current hardware setup]
│       └── disko.nix                      [TO CREATE: disko config]
└── flake.nix                              [TO UPDATE: add disko input]
```

---

## Quick Start

### I want to understand the current system
```bash
# Read the analysis
cat docs/disk-analysis.md
```

### I want to migrate to disko soon
```bash
# 1. Read overview
cat docs/quick-reference.md

# 2. Plan migration
cat docs/migration-guide.md

# 3. Understand backups first
cat docs/backup-strategy.md
```

### I want to see example configurations
```bash
# Current (safe to test)
cat docs/disko-current.nix

# Enhanced (for full deployment)
cat docs/disko-enhanced.nix
```

### I need backup/recovery procedures
```bash
# Complete backup guide
cat docs/backup-strategy.md

# For specific scenarios, see:
# - Accidental file deletion
# - Hard drive failure
# - Complete system corruption
# - Windows boot issues
```

---

## Resources

### Official Documentation
- **Disko Project**: https://github.com/nix-community/disko
- **Disko Manual**: https://github.com/nix-community/disko#readme
- **Btrfs Documentation**: https://btrfs.readthedocs.io/
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/

### Community
- **NixOS Discourse**: https://discourse.nixos.org/
- **NixOS Wiki**: https://wiki.nixos.org/
- **Matrix Chat**: #nixos:matrix.org

### Tools Referenced
- **snapper**: https://snapper.io/ (Btrfs snapshots)
- **Duplicacy**: https://duplicacy.com/ (Backup tool)
- **Backblaze**: https://www.backblaze.com/ (Cloud backup)
- **Nextcloud**: https://nextcloud.com/ (File sync)

---

## Support & Questions

When you encounter issues:

1. **Check:** quick-reference.md troubleshooting section
2. **Search:** migration-guide.md for specific scenario
3. **Review:** backup-strategy.md recovery procedures
4. **Consult:** disko documentation (GitHub)
5. **Ask:** NixOS community (Discourse/Matrix)

---

## Status & Maintenance

**Last Updated:** January 24, 2026
**Research Status:** ✅ Complete
**Configuration Status:** Ready for implementation
**Testing Status:** Recommended before deployment

**Next Review:** After Phase 2 (testing complete)

---

**Document created during comprehensive research of declarative disk management for NixOS systems. This analysis covers current state, migration path, and operational procedures.**

