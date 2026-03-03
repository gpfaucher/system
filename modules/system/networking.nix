{
  config,
  lib,
  pkgs,
  ...
}:

{
  # NetworkManager for WiFi + wired management
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  # ModemManager grabs the HFP Bluetooth profile on D-Bus, preventing
  # PipeWire's native backend from registering HFP for headset microphones.
  # Disable it since we don't use cellular modems.
  systemd.services.ModemManager.enable = false;

  # Firewall configuration
  # Dev servers bind to localhost by default - no need to open ports for them.
  # Only open ports that genuinely need incoming connections from other devices.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
    ];
    # Trust the Docker bridge so containers can reach host-bound services
    # (e.g. SSH tunnels on 0.0.0.0:5432).
    trustedInterfaces = [ "docker0" "br-+" ];
  };
}
