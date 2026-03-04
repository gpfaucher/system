{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.tailscale.enable = true;

  networking.firewall = {
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };
}
