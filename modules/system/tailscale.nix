{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Tailscale mesh VPN
  services.tailscale.enable = true;

  # Allow Tailscale's UDP port through the firewall
  networking.firewall = {
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };
}
