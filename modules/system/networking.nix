{ config, lib, pkgs, ... }:

{
  # NetworkManager for network management
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Common development ports
    allowedTCPPorts = [
      22    # SSH
      80    # HTTP
      443   # HTTPS
      3000  # Node.js/React dev server
      4000  # Phoenix/Elixir
      5000  # Flask/generic
      5173  # Vite dev server
      8000  # Django/Python
      8080  # Alternative HTTP / Tabby
      8888  # Jupyter
    ];
  };
}
