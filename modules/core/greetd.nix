{pkgs, username, ...}: {
  # Enable GDM (GNOME's display manager)
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable power-profiles-daemon (conflicts with auto-cpufreq)
  services.power-profiles-daemon.enable = false;

  # Auto-login for faster boot
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  # Workaround for GNOME autologin
  # https://github.com/NixOS/nixpkgs/issues/103746
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Exclude GNOME bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    epiphany
    geary
    totem
  ];
}
