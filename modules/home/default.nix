{ pkgs, ... }:
{
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  imports = [
    ./default.desktop.nix
    ./zsh.nix
    ./git.nix
    ./logitech.nix
    ./packages.nix
    ./scripts/default.nix
    ./statusbar.nix
    ./steam.nix
    ./terminal.nix
    ./tmux.nix
    ./sway.nix
    ./kanshi.nix
    ./zathura.nix

    ./nvim/default.nix
  ];
}
