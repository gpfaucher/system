{ pkgs, ... }:
{
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  imports = [
    ./bluetooth.nix
    ./docker.nix
    ./greetd.nix
    ./networking.nix
    ./pipewire.nix
    ./program.nix
    ./security.nix
    ./steam.nix
    ./system.nix
    ./user.nix
    ./xserver.nix
  ];
}
