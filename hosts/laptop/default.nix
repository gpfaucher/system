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
    ../../modules/system/graphics.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/services.nix
    ../../modules/system/hardening.nix
    ../../modules/system/vr.nix
    ../../modules/system/kde.nix
    ../../modules/system/power.nix
    ../../modules/system/maintenance.nix
    ../../modules/system/vpn.nix
    ../../modules/system/tailscale.nix
    ../../modules/system/flatpak.nix
    ../../modules/system/logitech.nix
  ];

  networking.hostName = "laptop";

  nix.settings = {
    substituters = [
      "https://ghostty.cachix.org"
    ];
    trusted-public-keys = [
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
    ];
  };

  users.users.gabriel.extraGroups = [ "networkmanager" ];

  # Virtual camera for OBS background effects in Teams/Zoomw
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
  '';

  services.xserver.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope.enable = true;

  programs.gamemode.enable = true;

  # Do not change after initial install
  system.stateVersion = "24.11";
}
