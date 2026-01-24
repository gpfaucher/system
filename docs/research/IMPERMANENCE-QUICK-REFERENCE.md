# Impermanence Quick Reference

## What to Persist vs Discard

### 🔴 MUST PERSIST (Critical)
```
/persist/var/lib/
  ├── nixos/              # NixOS metadata
  ├── systemd/            # Journal database
  ├── docker/             # Containers, images, volumes
  ├── NetworkManager/     # WiFi/VPN configs
  └── bluetooth/          # Paired devices

/persist/etc/
  ├── machine-id          # System identifier
  └── adjtime             # Hardware clock

/persist/home/gabriel/
  ├── .ssh/               # SSH keys (critical!)
  ├── .aws/               # AWS credentials (critical!)
  └── .config/            # App configs
```

### 🟡 SHOULD PERSIST (Important)
```
~/.config/               # River, neovim configs
~/.local/state/          # App state databases
~/.mozilla/              # Firefox history/bookmarks
~/.local/bin/            # User scripts
~/.claude/               # Claude CLI state
```

### 🟢 SAFE TO DISCARD (Regenerated)
```
~/.cache/                (5.1GB - regenerated)
~/.npm/                  (290MB - regenerated)
~/.tabby/                (1.4GB - regenerated)
/var/log/                (185MB - journald keeps essentials)
/tmp/, /var/tmp/         (temp files)
```

## System Breakdown

**Total /home size:** ~15GB
- **Keep:** ~3GB (configs, state, credentials)
- **Can delete:** ~12GB (caches, regenerated)

**Total /var size:** ~185MB
- **Keep:** ~30MB (metadata, configs)
- **Can discard:** ~155MB (logs, can use journald)

## Implementation Impact

| Aspect | Impact |
|--------|--------|
| Boot speed | ⬆️ Faster (skip fsck, cleanup) |
| Runtime performance | ➡️ Same or slightly faster |
| Disk I/O | ⬇️ Less (tmpfs for /var/run) |
| First boot setup | ⬆️ Slightly slower (copy state) |
| Maintenance | ⬇️ Easier (clean state) |
| Debugging | ⬇️ Harder (logs cleared on reboot) |
| Backup complexity | ⬆️ Need to include /persist |

## Why This System is Perfect for Impermanence

✅ Already using Btrfs subvolumes  
✅ Single user (simpler state management)  
✅ Excellent disk space (875GB free)  
✅ NixOS philosophy aligns with stateless  
✅ Development workflow benefits from clean /var  
✅ Docker/Bluetooth state is well-defined  

## Quick Start (after reading full analysis)

```bash
# 1. Backup current state
sudo btrfs subvolume snapshot @ @-backup

# 2. Create persistence subvolume
sudo btrfs subvolume create /@persist

# 3. Copy current state
sudo cp -r /var/lib/{systemd,NetworkManager,docker,bluetooth,nixos} /persist/var/lib/
cp -r ~/.ssh ~/.aws ~/.config ~/.local/bin /persist/home/gabriel/

# 4. Add to flake inputs + create persistence module
# (See full analysis for exact Nix code)

# 5. Test thoroughly before committing to tmpfs root
```

## Gotchas to Avoid

1. **Don't forget SSH keys** - /persist/home/gabriel/.ssh/ MUST persist
2. **AWS credentials too** - /persist/home/gabriel/.aws/ MUST persist
3. **Docker setup** - Ensure /var/lib/docker mounted before docker.service starts
4. **Journald config** - Enable persistent journald: `services.journald.extraConfig`
5. **Permissions** - Keep var/lib as root:root, home as gabriel:users
6. **Backups** - Include /persist in backup strategy!
7. **First boot** - Pre-create /etc/machine-id with correct value
8. **NetworkManager** - Need /var/lib/NetworkManager for network to work

## Testing After Implementation

```bash
# Verify ephemeral root
touch /tmp/test_file
sudo reboot
test -f /tmp/test_file && echo "FAILED: Not ephemeral!" || echo "OK"

# Verify persistence
test -d /persist/var/lib/docker && echo "Docker config persisted" || echo "ERROR"

# Verify network
nmcli device show | grep "IP4.DHCP"  # Should show DHCP info

# Verify Bluetooth
sudo systemctl status bluetooth

# Check mount points
mount | grep persist  # Should show binds to /var/lib
```

