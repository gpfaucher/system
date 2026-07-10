{
  imports = [
    ./hardware.nix
    ../../modules/nixos/base
    ../../modules/nixos/roles/server.nix
    ../../modules/nixos/services/backups.nix
    ../../modules/nixos/services/tailscale.nix
    # Enable these after the first SSH/Tailscale-managed switch succeeds.
    # ../../modules/nixos/services/ingress.nix
    # ../../modules/nixos/services/k3s.nix
  ];

  networking.hostName = "server";

  system.stateVersion = "26.05";
}
