{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ProtonVPN
  # Uses the official ProtonVPN CLI/GUI which wraps OpenVPN/WireGuard
  environment.systemPackages = with pkgs; [
    protonvpn-gui
    proton-vpn-cli
  ];

  # ProtonVPN needs these kernel modules for WireGuard mode
  boot.kernelModules = [ "wireguard" ];

  # Allow ProtonVPN to manage network connections
  # NetworkManager integration for seamless VPN management
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
}
