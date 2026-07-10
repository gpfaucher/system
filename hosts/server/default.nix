{
  imports = [
    ./hardware.nix
    ../../modules/nixos/base
    ../../modules/nixos/roles/server.nix
    ../../modules/nixos/services/backups.nix
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/cert_manager.nix
    ../../modules/nixos/services/ingress.nix
    ../../modules/nixos/services/k3s.nix
  ];

  networking.hostName = "server";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
