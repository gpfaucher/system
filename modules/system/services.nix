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

  # Bluetooth support (blueman-applet provides UI in DWM systray)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Polkit for authentication dialogs
  security.polkit.enable = true;

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
