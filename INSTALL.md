# Arch Linux Installation Guide

Dual-drive setup: Arch on Drive 1, Windows on Drive 2.

## Pre-Install

### On Windows
1. Back up important data
2. Note your WiFi password
3. Export browser bookmarks/passwords
4. Download [Arch ISO](https://archlinux.org/download/)
5. Create bootable USB with [Rufus](https://rufus.ie/) or [Ventoy](https://ventoy.net/)

### Identify Drives
Boot into Windows, open Disk Management:
- Note which drive is Windows (keep this one)
- Note which drive will be Arch (will be wiped)

Usually:
- `nvme0n1` = First NVMe (check which has Windows)
- `nvme1n1` = Second NVMe

## Boot Arch ISO

1. Insert USB, reboot
2. Enter BIOS (F2/F12/Del on Lenovo)
3. Disable Secure Boot (temporarily)
4. Boot from USB

## Connect to WiFi

```bash
iwctl
> device list
> station wlan0 scan
> station wlan0 get-networks
> station wlan0 connect "Your-SSID"
> exit

# Verify
ping -c 3 archlinux.org
```

## Identify Your Drives

```bash
lsblk -f
```

Example output:
```
nvme0n1          # 1TB - This will be Arch
├─nvme0n1p1      # (empty or old)
└─nvme0n1p2

nvme1n1          # 1TB - Windows (DO NOT TOUCH)
├─nvme1n1p1 vfat # Windows EFI
├─nvme1n1p2      # Windows Reserved
├─nvme1n1p3 ntfs # Windows C:
└─nvme1n1p4 ntfs # Windows Recovery
```

**CRITICAL**: Identify which drive has Windows and DO NOT touch it.

Set your Arch drive (adjust if different):
```bash
ARCH_DRIVE=/dev/nvme0n1
```

## Partition Arch Drive

```bash
# Wipe the Arch drive
wipefs -a $ARCH_DRIVE

# Create partitions
parted $ARCH_DRIVE --script \
    mklabel gpt \
    mkpart ESP fat32 1MiB 1GiB \
    set 1 esp on \
    mkpart root 1GiB 101GiB \
    mkpart home 101GiB 100%

# Verify
lsblk $ARCH_DRIVE
```

Should show:
- `nvme0n1p1` - 1GB EFI
- `nvme0n1p2` - 100GB Root
- `nvme0n1p3` - ~900GB Home

## Format Partitions

### Option A: ext4 (Simple)
```bash
mkfs.fat -F32 ${ARCH_DRIVE}p1
mkfs.ext4 ${ARCH_DRIVE}p2
mkfs.ext4 ${ARCH_DRIVE}p3
```

### Option B: Btrfs (Snapshots)
```bash
mkfs.fat -F32 ${ARCH_DRIVE}p1
mkfs.btrfs ${ARCH_DRIVE}p2
mkfs.btrfs ${ARCH_DRIVE}p3

# Create subvolumes for root
mount ${ARCH_DRIVE}p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@snapshots
umount /mnt
```

## Mount Partitions

### ext4:
```bash
mount ${ARCH_DRIVE}p2 /mnt
mkdir -p /mnt/boot /mnt/home
mount ${ARCH_DRIVE}p1 /mnt/boot
mount ${ARCH_DRIVE}p3 /mnt/home
```

### Btrfs:
```bash
mount -o subvol=@,compress=zstd ${ARCH_DRIVE}p2 /mnt
mkdir -p /mnt/boot /mnt/home /mnt/.snapshots
mount ${ARCH_DRIVE}p1 /mnt/boot
mount ${ARCH_DRIVE}p3 /mnt/home
mount -o subvol=@snapshots,compress=zstd ${ARCH_DRIVE}p2 /mnt/.snapshots
```

## Install Base System

```bash
pacstrap -K /mnt base linux linux-firmware \
    intel-ucode amd-ucode \
    networkmanager iwd \
    neovim git sudo zsh

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt
```

## Configure System

```bash
# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "archbox" > /etc/hostname

# Hosts
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archbox.localdomain archbox
EOF

# Root password
passwd

# Create user
useradd -m -G wheel -s /bin/zsh gabriel
passwd gabriel

# Sudo
EDITOR=nvim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

## Install Bootloader (systemd-boot)

```bash
bootctl install

# Create loader config
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

# Create Arch entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value ${ARCH_DRIVE}p2) rw
EOF

# For Btrfs, add rootflags:
# options root=PARTUUID=... rootflags=subvol=@ rw
```

## Add Windows to Boot Menu

```bash
# Find Windows EFI partition (on the OTHER drive)
lsblk -f | grep -i vfat

# Mount Windows EFI (adjust device)
mkdir -p /mnt/windows-efi
mount /dev/nvme1n1p1 /mnt/windows-efi

# Check Windows bootloader exists
ls /mnt/windows-efi/EFI/Microsoft/Boot/bootmgfw.efi

# Create Windows entry
cat > /boot/loader/entries/windows.conf << EOF
title   Windows
efi     /EFI/Microsoft/Boot/bootmgfw.efi
EOF

# Copy Windows EFI files to Arch EFI
cp -r /mnt/windows-efi/EFI/Microsoft /boot/EFI/

umount /mnt/windows-efi
```

## Install NVIDIA Drivers

```bash
pacman -S nvidia nvidia-utils nvidia-settings

# For hybrid graphics, add kernel parameters
# Edit /boot/loader/entries/arch.conf, add to options line:
# nvidia_drm.modeset=1
```

## Enable Services

```bash
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer
```

## Exit and Reboot

```bash
exit
umount -R /mnt
reboot
```

Remove USB when system restarts.

## Post-Install (After First Boot)

Login as your user, then:

```bash
# Connect to WiFi
nmcli device wifi connect "Your-SSID" password "your-password"

# Clone dotfiles
git clone https://github.com/YOUR_USER/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap
./install.sh

# Reboot
sudo reboot
```

## Set NVIDIA Mode

After reboot:

```bash
# Check current mode
envycontrol --status

# Set hybrid mode (recommended)
envycontrol -s hybrid

# Reboot
sudo reboot

# Verify NVIDIA works
nvidia-smi
```

## Boot Menu

At startup, you'll see:
- **Arch Linux** (default)
- **Windows**

Press arrow keys to select, Enter to boot.

## Troubleshooting

### Can't see Windows in boot menu
```bash
# Verify Windows EFI was copied
ls /boot/EFI/Microsoft/Boot/bootmgfw.efi

# If missing, mount Windows EFI and copy again
sudo mount /dev/nvme1n1p1 /mnt
sudo cp -r /mnt/EFI/Microsoft /boot/EFI/
sudo umount /mnt
```

### WiFi not working
```bash
# Use iwd directly
iwctl station wlan0 connect "SSID"

# Or check NetworkManager
nmcli device status
nmcli radio wifi on
```

### NVIDIA issues
```bash
# Check if module loaded
lsmod | grep nvidia

# Check Xorg log
cat /var/log/Xorg.0.log | grep -i nvidia

# Try integrated mode first
envycontrol -s integrated
sudo reboot
```

### River doesn't start
```bash
# Check if River is installed
which river

# Start manually to see errors
river

# Check logs
journalctl --user -xe
```
