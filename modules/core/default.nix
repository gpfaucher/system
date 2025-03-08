{ ... }:
{
  imports =
       [(import ./docker.nix)]
    ++ [(import ./hardware.nix)]
    ++ [(import ./xserver.nix)]
    ++ [(import ./networking.nix)]
    ++ [(import ./pipewire.nix)]
    ++ [(import ./program.nix)]
    ++ [(import ./security.nix)]
    ++ [(import ./system.nix)]
    ++ [(import ./user.nix)]
    ++ [(import ./bluetooth.nix)]
    ++ [(import ./steam.nix)];
}
