{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    playerctl
    pulsemixer
    zoom-us
    fzf
    nerd-fonts.jetbrains-mono
    hsetroot
  ];
}
