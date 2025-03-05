{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    playerctl
    pulsemixer
    zoom-us
    lutris
    librewolf
  ];
}
