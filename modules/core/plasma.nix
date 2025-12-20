{pkgs, ...}: {
  # Enable X server (needed by some apps even under Wayland)
  services.xserver.enable = true;

  # Enable Plasma 6
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # XDG Portal for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
  };

  # Exclude bloat
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa # Music player
    konsole # We use kitty/foot
    oxygen # Old theme
  ];

  # Useful KDE packages
  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm # SDDM config module
    kdePackages.kwalletmanager # Wallet management
    kdePackages.partitionmanager # Disk management
  ];
}
