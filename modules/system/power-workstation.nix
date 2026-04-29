# Workstation power configuration. No lid switch handling, no on-disk swap
# (zramSwap in hardware.nix already covers memory pressure).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # If you want a desktop to suspend when idle, configure it here. Default
  # is to never suspend automatically.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
