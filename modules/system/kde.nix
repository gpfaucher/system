{ pkgs, ... }:

{
  # KDE Plasma 6 Wayland
  services.desktopManager.plasma6.enable = true;

  # SDDM display manager (KDE's native DM)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # X server needed for XWayland
  services.xserver.enable = true;

  # Wayland environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Polonium tiling extension
  environment.systemPackages = with pkgs; [
    polonium
  ];

  # Exclude unnecessary KDE apps (we use our own tools)
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole # using Ghostty
    kate # using Neovim
    elisa # not needed
    gwenview # using imv
    okular # using zathura
    plasma-browser-integration # not needed
  ];
}
