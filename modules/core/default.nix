{ pkgs, ... }: {
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  imports =
    [ (import ./docker.nix) ]
    ++ [ (import ./hardware.nix) ]
    ++ [ (import ./networking.nix) ]
    ++ [ (import ./pipewire.nix) ]
    ++ [ (import ./program.nix) ]
    ++ [ (import ./security.nix) ]
    ++ [ (import ./system.nix) ]
    ++ [ (import ./user.nix) ]
    ++ [ (import ./bluetooth.nix) ]
    ++ [ (import ./steam.nix) ];
}
