{ pkgs, ... }:
{
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  imports = [
    ./autorandr.nix
    ./default.desktop.nix
    ./fish.nix
    ./git.nix
    ./logitech.nix
    ./packages.nix
    ./scripts/default.nix
    ./statusbar.nix
    ./steam.nix
    ./terminal.nix
    ./tmux.nix
    ./xserver.nix
    ./zathura.nix

    ./nvim/default.nix
  ];
}
