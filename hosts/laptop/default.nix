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
    ../../modules/system/graphics.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/services.nix
    ../../modules/system/bluetooth-monitor.nix
    ../../modules/system/hardening.nix
    ../../modules/system/impermanence.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Enable Nix flakes and experimental features
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;

      # Parallel build optimization
      max-jobs = "auto"; # Use all available CPU cores for parallel builds
      cores = 0; # Use all cores per individual build job

      # Download optimization
      http-connections = 25; # Parallel download connections (default is 25)

      # Build caching optimization
      keep-outputs = true; # Keep build outputs for faster rebuilds
      keep-derivations = true; # Keep .drv files for better caching

      # Tarball caching
      tarball-ttl = 300; # Cache downloaded tarballs for 5 minutes

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://ghostty.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d"; # Extended retention for safer rollbacks
    };
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # User configuration
  users.users.gabriel = {
    isNormalUser = true;
    home = "/home/gabriel";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "input"
    ];
  };

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # NixOS state version - do not change after initial install
  system.stateVersion = "24.11";
}
