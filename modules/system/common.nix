{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  # ── Nix daemon settings ──
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

      # Binary caches (shared across all hosts)
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

  # ── Fonts ──
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # ── User ──
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "docker"
    ];
  };

  # Fish shell system-wide (required for user shell)
  programs.fish.enable = true;

  # XDG portal paths (required when Home Manager uses useUserPackages)
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # Stylix NixOS-level config (must match Home Manager theme in modules/home/theme.nix)
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
}
