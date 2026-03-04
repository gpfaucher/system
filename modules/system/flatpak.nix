{ pkgs, ... }:

{
  # Flatpak for apps that fight with NixOS FHS paths
  services.flatpak = {
    enable = true;

    packages = [
      "us.zoom.Zoom"
      "com.github.IsmaelMartinez.teams_for_linux"
    ];

    update.onActivation = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    uninstallUnmanaged = false;
  };
}
