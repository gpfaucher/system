{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Btrfs swap subvolume for hibernate
  # One-time setup required — see comment at bottom of file
  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/388ac5b1-433c-46d2-8c1f-88cfdfae5297";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  # Resume from hibernate
  boot.resumeDevice = "/dev/disk/by-uuid/388ac5b1-433c-46d2-8c1f-88cfdfae5297";

  # Hibernate on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  # One-time setup:
  #
  # 1. Create @swap subvolume:
  #    sudo mount /dev/disk/by-uuid/388ac5b1-433c-46d2-8c1f-88cfdfae5297 /mnt
  #    sudo btrfs subvolume create /mnt/@swap
  #    sudo umount /mnt
  #
  # 2. Mount it and create swap file:
  #    sudo mkdir -p /swap
  #    sudo mount -o subvol=@swap /dev/disk/by-uuid/388ac5b1-433c-46d2-8c1f-88cfdfae5297 /swap
  #    sudo chattr +C /swap
  #    sudo dd if=/dev/zero of=/swap/swapfile bs=1M count=65536 status=progress
  #    sudo chmod 600 /swap/swapfile
  #    sudo mkswap /swap/swapfile
  #
  # 3. Get resume offset and add to boot.kernelParams in bootloader.nix:
  #    sudo btrfs inspect-internal map-swapfile /swap/swapfile
  #    → Add "resume_offset=<number>" to boot.kernelParams
  #
  # 4. Rebuild: sudo nixos-rebuild switch --flake .
}
