{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;
in
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = "(300, 400)";
        height = 200;
        offset = "24x24";
        origin = "top-right";
        frame_width = 2;
        corner_radius = 12;
        gap_size = 8;
        font = lib.mkForce "Monaspace Neon 12";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 30;
        icon_position = "left";
        max_icon_size = 64;
        padding = 16;
        horizontal_padding = 20;
        mouse_left_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = lib.mkForce "#${colors.base01}";
        foreground = lib.mkForce "#${colors.base04}";
        frame_color = lib.mkForce "#${colors.base02}";
        timeout = 5;
      };

      urgency_normal = {
        background = lib.mkForce "#${colors.base01}";
        foreground = lib.mkForce "#${colors.base05}";
        frame_color = lib.mkForce "#${colors.base0B}";
        timeout = 10;
      };

      urgency_critical = {
        background = lib.mkForce "#${colors.base01}";
        foreground = lib.mkForce "#${colors.base05}";
        frame_color = lib.mkForce "#${colors.base08}";
        timeout = 0;
      };
    };
  };
}
