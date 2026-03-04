{ pkgs, ... }:

{
  # Flatpak for apps that fight with NixOS FHS paths
  services.flatpak = {
    enable = true;

    # Declarative package list (managed by nix-flatpak)
    packages = [
      "us.zoom.Zoom"
      "com.github.IsmaelMartinez.teams_for_linux"
    ];

    # Update on rebuild
    update.onActivation = true;

    # Weekly auto-update
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    # Remove Flatpaks not declared here
    uninstallUnmanaged = false;
  };
}
