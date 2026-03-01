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
    # GPU: offload mode (AMD primary, NVIDIA on-demand)
    ../../modules/system/graphics.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/services.nix
    ../../modules/system/hardening.nix
    ../../modules/system/vr.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/power.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Laptop-specific: extra binary cache for Ghostty
  nix.settings = {
    substituters = [
      "https://ghostty.cachix.org"
    ];
    trusted-public-keys = [
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
    ];
  };

  # Laptop-specific: NetworkManager group
  users.users.gabriel.extraGroups = [ "networkmanager" ];

  # X server (needed for XWayland + GPU drivers)
  services.xserver.enable = true;

  # Steam gaming platform
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope.enable = true;

  # Gamemode for performance optimization while gaming
  programs.gamemode.enable = true;

  # NixOS state version - do not change after initial install
  system.stateVersion = "24.11";
}
