{
  pkgs,
  ...
}:
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.mullvad-vpn.enable = true;

  services.hyprpaper.enable = true;

  home.packages = with pkgs; [
    # Wayland-specific utilities
    grimblast
    waylock
    playerctl
    adwaita-icon-theme
  ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };
}
