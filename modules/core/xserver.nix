{pkgs, ...}: {
  # X server for legacy app compatibility
  services.xserver.enable = true;

  # XDG Portal configuration is handled in river.nix
}
