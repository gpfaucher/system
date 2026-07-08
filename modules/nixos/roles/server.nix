{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim
    tmux
    btop
    curl
    wget
    lsof
    pciutils
    usbutils
    dnsutils
  ];

  documentation.nixos.enable = false;
}
