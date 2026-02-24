{
  config,
  lib,
  pkgs,
  ...
}:

{
  # dconf for GTK/GNOME settings (required by stylix)
  programs.dconf.enable = true;

  # CUPS printing service
  services.printing.enable = true;

  # UPower service for battery/power management info
  services.upower.enable = true;

  # Bluetooth support (KDE Plasma provides its own Bluetooth UI)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Ensure Bluetooth service starts automatically
  systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  systemd.user.services.pipewire-pulse.wantedBy = [ "default.target" ];

  # Polkit for authentication dialogs
  security.polkit.enable = true;

  # XDG portal configuration is handled by KDE Plasma in hosts/laptop/default.nix

  # nix-ld: run dynamically linked binaries (e.g. pip-installed ruff, black)
  programs.nix-ld.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # Enable coredumps for crash diagnosis
  systemd.coredump = {
    enable = true;
    extraConfig = ''
      Storage=external
      MaxUse=5G
    '';
  };
}
