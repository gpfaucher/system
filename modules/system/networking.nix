{
  config,
  lib,
  pkgs,
  ...
}:

{
  # NetworkManager for wireless management (integrates with KDE Plasma)
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  # ModemManager grabs the HFP Bluetooth profile on D-Bus, preventing
  # PipeWire's native backend from registering HFP for headset microphones.
  # Disable it since we don't use cellular modems.
  systemd.services.ModemManager.enable = false;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Common development ports
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
      3000 # Node.js/React dev server
      4000 # Phoenix/Elixir
      5000 # Flask/generic
      5173 # Vite dev server
      5432 # PostgreSQL (for Docker → host tunnel)

      8000 # Django/Python
      8080 # Alternative HTTP / Tabby
      8888 # Jupyter
    ];
  };
}
