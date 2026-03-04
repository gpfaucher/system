{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    protonvpn-gui
    proton-vpn-cli
  ];

  # ProtonVPN needs these kernel modules for WireGuard mode
  boot.kernelModules = [ "wireguard" ];

  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
}
