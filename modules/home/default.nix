{ pkgs, ... }:
{
  imports = [
    ./displays.nix
    ./shell.nix
    ./git.nix
    ./packages.nix
    ./wayland.nix
    ./scripts/default.nix
    ./steam.nix
    ./terminal.nix
    ./zathura.nix
    ./nvim/default.nix
  ];
}
