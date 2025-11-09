{
  pkgs,
  ...
}:
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.mullvad-vpn.enable = true;

  services.hyprpaper.enable = true;

  home.packages = with pkgs; [
    grimblast
    waylock
    dmenu
    dunst
    foot
    light
    brightnessctl
    wofi
    playerctl
    adwaita-icon-theme
  ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };
}
