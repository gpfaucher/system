# Impermanence Module - README

## Current Status

**PREPARED BUT NOT ENABLED**

The impermanence module has been added to this NixOS configuration, but it is currently **disabled**. The configuration is ready but commented out in `modules/system/impermanence.nix`.

## What is Impermanence?

Impermanence provides an ephemeral root filesystem where the root (`/`) is wiped on every boot, forcing you to explicitly declare what state should persist. This provides several benefits:

- **Declarative System State**: Only explicitly declared files/directories persist
- **No Accumulated Cruft**: System always boots to a clean state
- **Better Reproducibility**: Ensures your configuration fully describes your system
- **Security**: Temporary malware or state changes don't survive reboots

## What Will Persist vs. Be Ephemeral

### When Enabled, These Will Persist:

**System Directories:**

- `/var/log` - System logs
- `/var/lib/bluetooth` - Bluetooth pairings
- `/var/lib/docker` - Docker data (if using Docker)
- `/var/lib/NetworkManager` - Network connections
- `/var/lib/systemd` - Systemd state
- `/etc/NetworkManager/system-connections` - WiFi passwords
- `/etc/machine-id` - Machine identifier

**User Directories (for `gabriel`):**

- `.ssh` - SSH keys and config
- `.aws` - AWS credentials
- `.gnupg` - GPG keys
- `.local/share/fish` - Fish shell history
- `.local/share/atuin` - Atuin shell history
- `.local/share/zoxide` - Zoxide directory history
- `.config/github-copilot` - GitHub Copilot auth
- `projects` - Your code projects
- `notes` - Your notes
- `Documents` - Documents folder
- `Downloads` - Downloads folder
- `.mozilla` - Firefox profile
- `.tabby-client` - Tabby client data
- `.gitconfig` - Git configuration

### What Will Be Ephemeral (Wiped on Reboot):

- Everything else in `/` except `/nix`, `/boot`, and `/persist`
- Temporary files in `/tmp`
- Any downloaded files not explicitly persisted
- Application caches (unless persisted)
- System state not in the persist list

## Steps to Enable Impermanence

**⚠️ WARNING: This requires disk reconfiguration and will require reinstalling or migrating your system!**

### Option 1: Fresh Install (Recommended)

1. **Partition Setup with Btrfs:**

   ```bash
   # Create Btrfs filesystem
   mkfs.btrfs /dev/sdX
   mount /dev/sdX /mnt

   # Create subvolumes
   btrfs subvolume create /mnt/@root
   btrfs subvolume create /mnt/@persist
   btrfs subvolume create /mnt/@nix
   btrfs subvolume create /mnt/@home

   # Unmount and remount properly
   umount /mnt
   mount -o subvol=@root,compress=zstd,noatime /dev/sdX /mnt
   mkdir -p /mnt/{persist,nix,home,boot}
   mount -o subvol=@persist,compress=zstd,noatime /dev/sdX /mnt/persist
   mount -o subvol=@nix,compress=zstd,noatime /dev/sdX /mnt/nix
   mount -o subvol=@home,compress=zstd,noatime /dev/sdX /mnt/home
   ```

2. **Update `hardware.nix`:**
   Add the subvolume mounts to your hardware configuration:

   ```nix
   fileSystems."/" = {
     device = "/dev/disk/by-uuid/XXX";
     fsType = "btrfs";
     options = [ "subvol=@root" "compress=zstd" "noatime" ];
   };

   fileSystems."/persist" = {
     device = "/dev/disk/by-uuid/XXX";
     fsType = "btrfs";
     options = [ "subvol=@persist" "compress=zstd" "noatime" ];
     neededForBoot = true;
   };

   fileSystems."/nix" = {
     device = "/dev/disk/by-uuid/XXX";
     fsType = "btrfs";
     options = [ "subvol=@nix" "compress=zstd" "noatime" ];
   };

   fileSystems."/home" = {
     device = "/dev/disk/by-uuid/XXX";
     fsType = "btrfs";
     options = [ "subvol=@home" "compress=zstd" "noatime" ];
   };
   ```

3. **Enable the Impermanence Config:**
   In `modules/system/impermanence.nix`, change `lib.mkIf false` to `lib.mkIf true` (or remove the mkIf entirely).

4. **Rebuild and Test:**
   ```bash
   sudo nixos-rebuild boot
   sudo reboot
   ```

### Option 2: Migration from Existing System

This is more complex and risky. Consider:

1. Backup all important data
2. Boot from NixOS installer
3. Resize existing partitions
4. Create new Btrfs subvolumes
5. Copy data to `/persist` subvolume
6. Follow steps above

## Testing Before Committing

**Before enabling full impermanence**, you can test what would be lost:

1. Review the persistence configuration in `impermanence.nix`
2. Check what's currently in your home directory:
   ```bash
   ls -la ~
   find ~ -maxdepth 1 -type d
   ```
3. Identify any directories/files you need that aren't in the persist list
4. Add them to the configuration BEFORE enabling

## Rollback Plan

If impermanence causes issues:

1. Boot into previous generation from bootloader
2. Edit `impermanence.nix` to disable (set back to `lib.mkIf false`)
3. Rebuild: `sudo nixos-rebuild boot`
4. Reboot

## Additional Resources

- [Impermanence GitHub](https://github.com/nix-community/impermanence)
- [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings) - Original blog post
- [NixOS Wiki - Impermanence](https://nixos.wiki/wiki/Impermanence)

## Support

Before enabling impermanence:

1. Ensure you have backups of important data
2. Review the persist lists carefully
3. Consider what state you need preserved
4. Test in a VM if possible

The configuration is ready when you are, but take your time to plan the migration!
