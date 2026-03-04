{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.xserver.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  environment.systemPackages = with pkgs; [
    polonium
  ];

  # Exclude default KDE apps
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole # using Ghostty
    kate # using Neovim
    elisa # not needed
    gwenview # using imv
    okular # using zathura
    plasma-browser-integration # not needed
  ];
}
