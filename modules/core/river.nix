{pkgs, ...}: {
  # Enable River compositor
  programs.river-classic.enable = true;

  # XWayland for X11 app compatibility
  programs.xwayland.enable = true;

  # XDG Portals for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = ["wlr" "gtk"];
  };

  # PAM configuration for waylock
  security.pam.services.waylock = {};

  # Polkit for privilege escalation dialogs
  security.polkit.enable = true;

  # Enable dconf for GTK apps settings
  programs.dconf.enable = true;
}
