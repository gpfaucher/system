{pkgs, ...}: {
  # Wayland session variable (also set in river.nix extraSessionVariables)
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Cursor is handled by Stylix

  # Additional Wayland utilities (some duplicated in river.nix for completeness)
  home.packages = with pkgs; [
    adwaita-icon-theme
  ];
}
