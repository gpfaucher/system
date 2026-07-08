{
  imports = [
    ./hardware.nix
    ../../modules/nixos/base
    ../../modules/nixos/roles/server.nix
    ../../modules/nixos/services/backups.nix
    ../../modules/nixos/services/ingress.nix
    ../../modules/nixos/services/k3s.nix
    ../../modules/nixos/services/tailscale.nix
  ];

  networking.hostName = "server";

  system.stateVersion = "24.11";
}
