{ lib, config, pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      terminal = "ghostty";
      modifier = "Mod1";
      bars = [];
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
        };
    };
  };
}
