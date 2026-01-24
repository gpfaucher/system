# NixOS Impermanence/Ephemeral Root Analysis
## Professional System Configuration Report

**System:** Gabriel's NixOS Laptop  
**Date:** January 24, 2026  
**Status:** Current system does NOT use impermanence

---

## EXECUTIVE SUMMARY

This system is an excellent candidate for ephemeral root filesystem with persistent /nix and /persist. Current configuration:

- ✅ Already uses Btrfs with subvolumes (@, @home)
- ✅ Stateless boot chain (systemd-boot)
- ✅ NixOS handles most /etc via configuration
- ✅ Single user workstation (simpler state management)
- ⚠️ Has significant application state in /home (15GB+ of caches, configs, secrets)
- ⚠️ /var/lib has stateful data (docker, systemd, NetworkManager, bluetooth)
- ⚠️ /var/log grows over time (185MB currently)

**Recommendation:** IMPLEMENT ephemeral root. Benefits outweigh complexity for this professional development system.

---

## CURRENT FILESYSTEM LAYOUT

### Btrfs Subvolume Structure
```
Physical device: /dev/nvme0n1p2 (931GB total)
├── @ (subvolid=256)
│   └── Mounted at: / (rw, ssd, discard=async, space_cache=v2)
│
├── @home (subvolid=257)
│   └── Mounted at: /home (same physical device, separate subvolume)
│
└── [no other subvolumes detected]

Boot: /dev/nvme0n1p1 (EFI, vfat, 512MB)
```

### Current Mounts
- `/` = btrfs subvol @ (root filesystem, includes /etc, /var, /nix, /usr)
- `/home` = btrfs subvol @home (user home directory)
- `/boot` = vfat (EFI partition)
- `/nix/store` = readonly bind mount of @
- tmpfs for /run, /dev/shm, /tmp
- zram swap (50% RAM, zstd compression)

### Disk Usage
- Total: 931GB
- Used: 55GB (6%)
- Free: 875GB (94%)

---

## WHAT CURRENTLY NEEDS PERSISTENCE

### /var/lib (Essential State)
| Directory | Size | Persistence Need | Type |
|-----------|------|------------------|------|
| systemd | 596KB | **MUST** | systemd journal metadata, user runtime dirs |
| NetworkManager | 32KB | **MUST** | WiFi credentials, VPN configs, connection history |
| nixos | 20KB | **MUST** | NixOS generation metadata |
| lastlog | 16KB | **SHOULD** | Login records (user preference) |
| logrotate.status | 4KB | **SHOULD** | Log rotation state |
| docker | 0KB* | **MUST** | Docker images, volumes, container state |
| bluetooth | 0KB* | **MUST** | Paired device info, Bluetooth settings |

*Currently empty but will grow with use

### /var/log (Log Files)
- **Size:** 185MB
- **Persistence:** **SHOULD** - useful for debugging but not critical
- **Option:** Keep last 14 days via journald + logrotate
- **Alternative:** Discard on reboot and rely on systemd journal

### /home/gabriel (User State)
| Directory | Size | Persistence | Notes |
|-----------|------|-------------|-------|
| .ssh | 32KB | **MUST** | SSH keys for git/servers |
| .aws | 4KB | **MUST** | AWS credentials |
| .config | 883MB | **SHOULD** | App configs (River, neovim, etc) |
| .local | 4.7GB | **MIXED** | See breakdown below |
| .cache | 5.1GB | **NO** | Can safely delete on reboot |
| .mozilla | 518MB | **SHOULD** | Firefox profiles, history, bookmarks |
| .npm | 290MB | **NO** | Package cache, regenerate on npm install |
| .tabby | 1.4GB | **NO** | Tabby AI cache, regenerate on demand |
| .claude | 83MB | **SHOULD** | Claude CLI caches/configs |

### /home/gabriel/.local (4.7GB breakdown)
```
~/.local/
├── bin/          (44KB) - Scripts → MUST
├── share/        (250MB) - Themes, icons, app data
│   ├── fonts → NO (in nix)
│   ├── icons → NO (in nix)
│   ├── applications → NO (in nix)
│   └── app-specific → MIXED
└── state/        (varies) - Application state
    ├── neovim → SHOULD (plugins, undo history)
    ├── river → SHOULD (layout state)
    └── other apps → MIXED
```

### /etc (System Config)
- **Status:** Mostly symlinked to /etc/static (NixOS-managed)
- **Persistence Need:** Already handled by NixOS config
- **Exception:** 
  - `/etc/adjtime` - hardware clock time zone (4 bytes) - **MUST**
  - `/etc/group`, `/etc/passwd` - **NO** (managed by NixOS)

### /nix (Nix Store)
- **Size:** 55GB (6% of disk)
- **Persistence:** **MUST** - entire /nix/store must persist
- **Why:** Contains all built packages, generations, GC roots
- **Mount:** Currently read-only bind mount of @ (good!)

---

## IMPERMANENCE IMPLEMENTATION STRATEGY

### Recommended Architecture: tmpfs / Root + Btrfs Persistence

```
tmpfs (ephemeral root)
└── / (2GB or RAM/3, refreshes on boot)
    ├── /etc → symlinks to NixOS config ✓
    ├── /var → tmpfs, cleared on boot
    │   ├── /var/lib → bind mount from /persist/var/lib
    │   ├── /var/log → tmpfs (journald handles)
    │   └── /var/cache → tmpfs
    ├── /home → separate Btrfs @home subvolume ✓
    └── /usr → symlinks to /nix/store ✓

/persist (Btrfs subvolume, persistent)
├── var/lib/
│   ├── systemd/        (journal metadata, user runtime)
│   ├── NetworkManager/ (WiFi creds, VPN configs)
│   ├── nixos/          (generation metadata)
│   ├── docker/         (containers, images, volumes)
│   ├── bluetooth/      (paired devices)
│   └── logrotate.status
├── etc/
│   ├── adjtime         (hardware clock)
│   ├── ssh/            (host SSH keys, if needed)
│   └── machine-id      (systemd machine identifier)
└── home/.../
    ├── .ssh/           (user SSH keys)
    ├── .aws/           (AWS credentials)
    ├── .config/        (app configs)
    ├── .local/bin/     (user scripts)
    └── .local/state/   (application state)

/nix (Btrfs subvolume, persistent)
└── store/             (package store, generations)
```

### Btrfs Subvolume Changes Needed

**NEW SUBVOLUMES TO CREATE:**
```bash
# Creates for persistence
btrfs subvolume create /@persist
btrfs subvolume create /@nix          (optional: separate /nix, currently @ is used)

# Updates to hardware.nix
# Current setup mixes everything in @, good for simple case
# For impermanence, recommend separating:
```

---

## DIRECTORIES THAT MUST PERSIST

### Critical (system will not boot/function without):
1. `/persist/var/lib/nixos/` - NixOS metadata
2. `/nix/store` - All packages and generations
3. `/home/gabriel/.ssh/` - SSH keys (git access)
4. `/home/gabriel/.aws/` - AWS credentials
5. `/var/lib/systemd/` - Systemd journal database
6. `/var/lib/machine-id` - System identifier

### Important (system boots but loses functionality):
7. `/var/lib/NetworkManager/` - WiFi/VPN configs
8. `/var/lib/docker/` - Docker containers, volumes, images
9. `/var/lib/bluetooth/` - Paired devices
10. `/home/gabriel/.config/` - River, neovim, other app configs
11. `/etc/machine-id` - System identifier

### Optional (convenient but not critical):
12. `/var/log/` - System logs (keep last 7-14 days)
13. `/home/gabriel/.mozilla/` - Firefox history/bookmarks
14. `/home/gabriel/.claude/` - Claude CLI state
15. `/home/gabriel/.local/state/` - App state databases
16. `/home/gabriel/.local/bin/` - User scripts

### Safe to Discard (regenerated automatically):
- `/home/gabriel/.cache/` - All caches (5.1GB)
- `/home/gabriel/.npm/` - npm cache (290MB)
- `/home/gabriel/.tabby/` - Tabby AI cache (1.4GB)
- `/home/gabriel/.local/share/` - Most app data
- `/var/tmp/`, `/tmp/` - Temporary files
- `/var/cache/` - Package caches

---

## BENEFITS OF EPHEMERAL ROOT

### System Reliability
1. **No Corruption on Crash** - tmpfs root can't be corrupted by unexpected shutdown
2. **Predictable State** - Every boot starts clean
3. **Fast Recovery** - No fsck needed on boot
4. **Atomic Boot** - Configuration always matches actual state

### Maintenance
1. **Reduced Disk I/O** - tmpfs much faster than disk for /var/run, /var/tmp
2. **Faster Boot** - Skip /var cleanup, fsck, journal replay
3. **Easier Debugging** - Know exactly what state is persistent vs transient
4. **Clear Persistence Model** - Forces explicit decisions about what to save

### Security
1. **No Secrets in RAM** - `/persist/` can be encrypted separately
2. **Audit Trail** - Changes to /persist are explicit
3. **Clear Trust Boundary** - All persistent state is centralized

### Space Efficiency
1. **Cleaner Disk Usage** - Old logs automatically cleared
2. **No Orphaned Files** - Old configs from uninstalls removed
3. **Smaller Backups** - Only /persist and /home need backing up

---

## COSTS & COMPLEXITY

### Implementation Effort
- **Moderate:** ~2-4 hours for initial setup
- **Main work:** 
  - Create /persist subvolume
  - Write home-manager persistence module
  - Test boot sequence thoroughly
  - Document what needs persistence

### Runtime Overhead
- **Minimal:** tmpfs for /var/run, /var/tmp is actually FASTER
- **No degradation** in application performance

### Maintenance Burden
- **Low:** NixOS handles most of the rebuild
- **Periodic:** Review what's being persisted, clean up stale configs
- **Backup:** Must include /persist in backup strategy

### Potential Issues
1. **Application Breakage:**
   - Apps that write to /var expecting persistence may fail
   - Some services need /var/log persistence
   - Fix: Bind mount from /persist

2. **First Boot Complexity:**
   - Missing /etc/machine-id can cause issues
   - Docker needs proper state directory setup
   - Fix: Pre-create with correct permissions

3. **Debugging Difficulty:**
   - No logs after reboot make troubleshooting harder
   - Solution: Keep journald logs persistent (in /persist/var/log/journal)

4. **Secrets Management:**
   - SSH keys, credentials MUST be in /persist
   - Solution: Use agenix or sops-nix for secrets

---

## MIGRATION STRATEGY

### Phase 1: Preparation (1 hour)
```bash
# 1. Take full system backup
sudo btrfs subvolume snapshot /home@home /home@home-backup

# 2. Document current critical paths
find /var/lib -type f -atime -7 | sort > /tmp/var_lib_current.txt
find /home/gabriel -maxdepth 2 -type f -newer /var/log/last_backup | sort > /tmp/home_current.txt

# 3. Create new persistence subvolume
sudo btrfs subvolume create /persist

# 4. Create directory structure
sudo mkdir -p /persist/{var/lib,etc,home/gabriel/.{ssh,.aws,.config,.local/{bin,state}}}
```

### Phase 2: Copy Current State (30 minutes)
```bash
# Copy critical var/lib
sudo cp -r /var/lib/{systemd,NetworkManager,docker,bluetooth,nixos} /persist/var/lib/

# Copy home user state
cp -r ~/.ssh ~/.aws ~/.config ~/.local/bin /persist/home/gabriel/
cp -r ~/.local/state /persist/home/gabriel/.local/ 2>/dev/null || true

# Copy system identifiers
sudo cp /etc/machine-id /persist/etc/

# Set permissions
sudo chown -R root:root /persist/var/lib
sudo chown -R gabriel:users /persist/home/gabriel
```

### Phase 3: NixOS Configuration (45 minutes)

1. **Add impermanence input to flake.nix:**
```nix
impermanence = {
  url = "github:nix-community/impermanence";
};
```

2. **Create persistent module (modules/system/impermanence.nix):**
```nix
{ config, lib, pkgs, ... }:
let
  persistDir = "/persist";
in
{
  # Mount tmpfs as root with large size
  fileSystems."/" = lib.mkForce {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=2G" "mode=0755" ];
    neededForBoot = true;
  };

  # Keep /nix persistent
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/...";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  # Keep /persist persistent
  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/...";
    fsType = "btrfs";
    options = [ "subvol=@persist" ];
  };

  # Bind mount critical var/lib directories
  systemd.tmpfiles.rules = [
    "L+ /var/lib/systemd - - - - /persist/var/lib/systemd"
    "L+ /var/lib/NetworkManager - - - - /persist/var/lib/NetworkManager"
    "L+ /var/lib/docker - - - - /persist/var/lib/docker"
    "L+ /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L+ /etc/machine-id - - - - /persist/etc/machine-id"
  ];

  # Keep /var/log temporary (journald only)
  services.journald.extraConfig = ''
    Storage=persistent
    RuntimePersistentStorage=yes
    Compress=yes
    MaxDiskSize=1G
  '';
}
```

3. **Create home-manager persistence module:**
```nix
# modules/home/persistence.nix
{ lib, config, ... }:
{
  home.persistence."/persist/home/gabriel" = {
    allowOther = true;
    directories = [
      ".ssh"
      ".aws"
      ".config/river"
      ".config/nvim"
      ".local/bin"
      ".local/state/nvim"
      ".local/share/nvim"
      ".mozilla"
    ];
    files = [
      ".bash_history"
      ".fish_history"
    ];
  };
}
```

### Phase 4: Testing (1 hour)
```bash
# 1. Build new configuration
sudo nixos-rebuild switch --flake /path/to/flake#laptop

# 2. Verify binds are in place
mount | grep persist

# 3. Check critical paths exist
test -d /var/lib/systemd/journal && echo "Journald mounted" || echo "ERROR"

# 4. Reboot and verify persistence
sudo reboot

# 5. After reboot, verify:
- Network still works (NM config persisted)
- Bluetooth devices still paired
- SSH keys still accessible
- Docker containers/images still present

# 6. Create temporary file, reboot, verify it's gone
touch /tmp/test_ephemeral
sudo reboot
test -f /tmp/test_ephemeral && echo "ERROR: tmpfs not ephemeral" || echo "OK"
```

### Phase 5: Cleanup & Documentation (30 minutes)
```bash
# Remove old backup after 1 week of testing
btrfs subvolume delete /home@home-backup

# Document custom persistence requirements discovered during testing
# Update PERSISTENCE.md with any app-specific needs

# Set up monitoring for /persist disk usage
```

---

## APPLICATION-SPECIFIC PERSISTENCE NOTES

### Docker
- **Location:** `/var/lib/docker/`
- **Size:** ~GB per container image
- **Persistence:** MUST
- **Setup:** Ensure mount exists before docker service starts

### Bluetooth
- **Location:** `/var/lib/bluetooth/`
- **Content:** Paired device MAC addresses, keys, names
- **Persistence:** MUST (convenience - rebind otherwise)
- **Note:** Already enabled in hardware.bluetooth.enable

### NetworkManager
- **Location:** `/var/lib/NetworkManager/`
- **Content:** Saved WiFi networks, VPN configs, secrets
- **Persistence:** MUST (necessary for network to work)
- **Files:** system-connections/*.nmconnection

### Systemd/Journal
- **Location:** `/var/lib/systemd/`
- **Content:** User runtime directories, journal database
- **Persistence:** MUST for user services, SHOULD for logs
- **Config:** services.journald.extraConfig in system config

### Neovim & River
- **Location:** `~/.config/nvim/`, `~/.local/state/nvim/`, `~/.config/river/`
- **Content:** Config, plugins, colorscheme, undo history
- **Persistence:** SHOULD
- **Note:** Managed by home-manager already

### Firefox
- **Location:** `~/.mozilla/firefox/`
- **Content:** Profiles, history, bookmarks, extensions
- **Persistence:** SHOULD (or accept losing browsing history)

### SSH & AWS
- **Location:** `~/.ssh/`, `~/.aws/`
- **Content:** Private keys, credentials
- **Persistence:** MUST
- **Security:** Consider agenix for key management

---

## IS IMPERMANENCE RIGHT FOR THIS SYSTEM?

### ✅ YES BECAUSE:
1. **Laptop/Single User:** Simple use case, not a multi-user server
2. **Btrfs Ready:** Already using Btrfs subvolumes, can add @persist
3. **Development Focus:** Benefits from clean /var state (Docker, npm caches)
4. **Good Disk Space:** 875GB free provides room for /persist
5. **NixOS Well-Suited:** NixOS shines with stateless systems
6. **Simple Boot Chain:** systemd-boot is stateless
7. **No Complex Persistence Needs:** Most state is explicitly managed

### ⚠️ CAUTION ABOUT:
1. **SSH/AWS Secrets:** Must ensure proper handling and backup
2. **Bluetooth Pairing:** Will lose paired devices if /persist not backed up
3. **Docker State:** Container state/volumes must persist
4. **Backup Complexity:** Must include /persist in backups, not just /home
5. **Debugging:** Rebooting clears logs, slower debugging

### ❌ MIGHT NOT BE WORTH IT IF:
1. You need persistent syslog for compliance (keep journald instead)
2. You frequently manually edit /etc files outside NixOS config
3. You need /var/log history across boots for troubleshooting
4. You have complex stateful services beyond Docker/Bluetooth

---

## RECOMMENDATION

**IMPLEMENT ephemeral root filesystem for this system.**

Justification:
- Setup effort is modest (2-4 hours)
- Benefits are significant (cleaner state, fewer boot issues)
- Risks are manageable (backup /persist, test thoroughly)
- Aligns with NixOS philosophy of reproducibility
- Professional development workflow actually benefits

Start with Phase 1-2 (preparation), carefully test in Phase 4, then gradually move optional directories to persistence as needed.

---

## REFERENCES & RESOURCES

### Community Impermanence Implementations
- [github.com/nix-community/impermanence](https://github.com/nix-community/impermanence)
- [NixOS wiki - Impermanence](https://wiki.nixos.org/wiki/Impermanence)
- [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings/) (excellent writeup)

### Related Technologies
- home-manager persistence options
- tmpfs mount options and sizing
- Btrfs subvolume management
- systemd-tmpfiles for bind mount setup
- journald persistent storage

### Future Enhancements
1. Encrypted /persist with LUKS
2. Automated /persist backups
3. agenix or sops-nix for secrets
4. Remote journal logging to remote syslog
5. Automatic old-config cleanup

