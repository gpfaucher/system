{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/bootloader.nix
    ../../modules/system/graphics.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/services.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Enable Nix flakes and experimental features
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # User configuration
  users.users.gabriel = {
    isNormalUser = true;
    home = "/home/gabriel";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" ];
  };

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # NixOS state version - do not change after initial install
  system.stateVersion = "24.11";
}
