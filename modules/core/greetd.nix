{
  pkgs,
  ...
}: {
  # greetd display manager with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd river";
        user = "greeter";
      };
      # NOTE: initial_session (auto-login) removed - it breaks waylock unlock
      # because greetd's auto-login doesn't set up PAM sessions properly
    };
  };

  # Suppress greetd errors on tty
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Disable conflicting display managers
  services.displayManager.sddm.enable = false;
  services.displayManager.gdm.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
}
