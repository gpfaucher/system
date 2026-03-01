{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../modules/system/common.nix
    ../../modules/system/bootloader.nix
    ../../modules/system/nvidia-desktop.nix
    ../../modules/system/networking-wired.nix
    ../../modules/system/audio.nix
    ../../modules/system/services.nix
    ../../modules/system/jellyfin.nix
    ../../modules/system/kubernetes.nix
  ];

  # Hostname
  networking.hostName = "nixbox";

  # Server-specific: render group for GPU transcoding
  users.users.gabriel.extraGroups = [ "render" ];

  # SSH server for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Firewall - server ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      80    # HTTP
      443   # HTTPS
      8096  # Jellyfin HTTP
      8920  # Jellyfin HTTPS
      6443  # Kubernetes API
    ];
  };

  # NixOS state version
  system.stateVersion = "24.11";
}
