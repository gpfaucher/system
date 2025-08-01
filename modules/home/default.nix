{ pkgs, ... }:
{
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  imports =
    [ (import ./git.nix) ]
    ++ [ (import ./zathura.nix) ]
    ++ [ (import ./packages.nix) ]
    ++ [ (import ./fish.nix) ]
    ++ [ (import ./xserver.nix) ]
    ++ [ (import ./tmux.nix) ]
    ++ [ (import ./logitech.nix) ]
    ++ [ (import ./nvim) ]
    ++ [ (import ./scripts) ]
    ++ [ (import ./terminal.nix) ];
}
