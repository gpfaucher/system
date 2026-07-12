{ config, pkgs, ... }:

# Enable the Tailscale daemon.  The actual auth key and settings are
# injected via host‑specific configuration (e.g., `hosts/server/default.nix`).
{
  services.tailscale.enable = true;
}
