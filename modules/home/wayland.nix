{
  lib,
  config,
  pkgs,
  ...
}:
{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      terminal = "foot";
      modifier = "Mod1";
      bars = [ ];
      startup = [
        {
          command = "kanshi";
          always = true;
        }
        {
          command = "dunst";
          always = true;
        }
      ];
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+o" = "exec dmenu_run";
          "${modifier}+l" = "exec waylock";
          "Print" = "exec grimshot copy area";
        };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  home.packages = with pkgs; [
    sway-contrib.grimshot
    waylock
    sway
    dmenu
    ghostty
  ];
}
