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

  # Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Ensure Bluetooth service starts automatically
  systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  systemd.user.services.pipewire-pulse.wantedBy = [ "default.target" ];

  # Polkit for authentication dialogs
  security.polkit.enable = true;

  # PAM service for waylock screen locker
  security.pam.services.waylock = { };

  # XDG portal configuration for Wayland/wlroots
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config = {
      common = {
        default = [ "wlr" ];
      };
      river = {
        default = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  # Rootless Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true; # Sets DOCKER_HOST for the user
    };
  };

  # River WM suspend/resume fix - Trigger layout restoration after resume
  powerManagement.resumeCommands = ''
    # Trigger the user service to restore River tiling layout
    ${pkgs.systemd}/bin/systemctl --user -M gabriel@ start river-resume-hook.service 2>/dev/null || true
  '';
}
