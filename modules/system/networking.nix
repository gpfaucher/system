{
  config,
  lib,
  pkgs,
  ...
}:

{
  # iwd for wireless management (replaces NetworkManager)
  networking.wireless.iwd = {
    enable = true;
    settings = {
      # General settings
       General = {
         EnableNetworkConfiguration = true;
       };
       # Driver quirks for wireless devices
       DriverQuirks = {
         DefaultInterface = true;
       };
      # Network configuration
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      # Scanning settings for better performance
      Scan = {
        DisablePeriodicScan = false;
      };
    };
  };

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
