# Workstation Install Guide

Target hardware: AMD Ryzen CPU + NVIDIA RTX 3070 Ti.

The flake exposes two hosts: `laptop` (existing) and `workstation` (this guide).
Shared modules (KDE, Steam, audio, Tailscale, VR, etc.) are inherited unchanged;
only the hardware-specific bits differ.

## What was added for the workstation

| File | Purpose |
| --- | --- |
| `hosts/workstation/default.nix` | Host entry point — hostname `workstation`, NVIDIA-only graphics, desktop power |
| `hosts/workstation/hardware.nix` | **Placeholder** hardware config — must be regenerated on the target machine |
| `modules/system/graphics-workstation.nix` | NVIDIA-only stack for RTX 3070 Ti (Ampere, open kernel modules), no PRIME |
| `modules/system/power-workstation.nix` | Desktop power profile (lid handlers ignored, no on-disk swap; zram covers it) |
| `flake.nix` | Extracted `mkHost`, exposes `nixosConfigurations.workstation` alongside `.laptop` |
| `scripts/rebuild.sh` | Auto-detects host from `hostname`; accepts `laptop` / `workstation` as arg |

## Install steps

### 1. Boot the NixOS installer

Use a current NixOS minimal ISO. Boot the workstation from USB.

### 2. Partition and mount

Match the existing btrfs layout used by the laptop (`@` for root, `@home` for
`/home`):

```bash
# Replace /dev/nvme0n1 with your actual disk
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 1GiB 100%

sudo mkfs.fat -F32 -n BOOT /dev/nvme0n1p1
sudo mkfs.btrfs -L nixos /dev/nvme0n1p2

# Create subvolumes
sudo mount /dev/nvme0n1p2 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo umount /mnt

# Mount with subvolumes
sudo mount -o subvol=@,compress=zstd /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/{boot,home}
sudo mount -o subvol=@home,compress=zstd /dev/nvme0n1p2 /mnt/home
sudo mount /dev/nvme0n1p1 /mnt/boot
```

### 3. Clone the flake

```bash
sudo nix-shell -p git --run 'git clone <your-repo-url> /mnt/etc/nixos'
cd /mnt/etc/nixos
```

### 4. Regenerate hardware config

The placeholder UUIDs in `hosts/workstation/hardware.nix` will not boot. Generate
the real hardware config from the running installer and merge it:

```bash
sudo nixos-generate-config --root /mnt --show-hardware-config \
  > hosts/workstation/hardware.nix
```

Then re-add the workstation-specific blocks to the bottom of that file (the
`nixos-generate-config` output omits them):

```nix
# Compressed RAM swap.
zramSwap = {
  enable = true;
  memoryPercent = 50;
  algorithm = "zstd";
};
```

Verify the generated file contains `"kvm-amd"` in `boot.kernelModules` (Ryzen)
and the correct `fileSystems."/"`, `fileSystems."/home"`, `fileSystems."/boot"`
UUIDs from `blkid`.

### 5. Install

```bash
sudo nixos-install --flake /mnt/etc/nixos#workstation
sudo reboot
```

### 6. First boot

Set the user password (`gabriel`) on first login, then verify the GPU is
recognized:

```bash
nvidia-smi
nvtop
```

## Day-to-day rebuilds

The rebuild script auto-detects the host from `hostname`:

```bash
./scripts/rebuild.sh                 # uses `hostname` to pick laptop/workstation
./scripts/rebuild.sh workstation     # explicit
sudo nixos-rebuild switch --flake .#workstation   # equivalent
```

## Notes & tweaks

- **NVIDIA driver**: `hardware.nvidia.open = true` is correct for Ampere
  (RTX 30-series). If you hit stability issues, flip to `false` in
  `modules/system/graphics-workstation.nix` to use the proprietary modules.
- **CPU**: `boot.kernelModules = [ "kvm-amd" ]` is kept for the Ryzen CPU;
  `hardware.cpu.amd.updateMicrocode` is enabled.
- **Swap**: zram only — no on-disk swapfile (the laptop has one for memory
  pressure headroom; the workstation should have enough RAM that zram suffices).
  Add a swapfile in `hardware.nix` if you need hibernation.
- **Dual-boot**: the workstation config has no Windows EFI mount. If you
  dual-boot, copy the `fileSystems."/boot/efi-windows"` block from
  `hosts/laptop/hardware.nix` and adjust the UUID.
