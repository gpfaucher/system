{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Swap (kept for general memory pressure, hibernate disabled)
  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/388ac5b1-433c-46d2-8c1f-88cfdfae5297";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  # Suspend on lid close (hibernate disabled — causes workspace loss on resume)
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
