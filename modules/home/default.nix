{ pkgs, ... }:
{
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  imports = [
    ./displays.nix
    ./fish.nix
    ./git.nix
    ./packages.nix
    ./scripts/default.nix
    ./statusbar.nix
    ./steam.nix
    ./terminal.nix
    ./zathura.nix
    ./nvim/default.nix
  ];
}
