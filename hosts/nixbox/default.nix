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

  # Enable Nix flakes and experimental features
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;

      # Parallel build optimization
      max-jobs = "auto";
      cores = 0;

      # Download optimization
      http-connections = 25;

      # Build caching optimization
      keep-outputs = true;
      keep-derivations = true;

      # Tarball caching
      tarball-ttl = 300;

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # User configuration - same as laptop
  users.users.gabriel = {
    isNormalUser = true;
    home = "/home/gabriel";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "render" # For GPU access (Jellyfin transcoding)
      "input"
      "docker"
    ];
  };

  # Enable fish shell system-wide
  programs.fish.enable = true;

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
