{ lib, config, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      terminal = "ghostty";
      modifier = "Mod1";
      startup = [
        {
          command = "kanshi";
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
