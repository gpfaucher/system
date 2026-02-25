{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 350;
        height = 150;
        offset = "20x20";
        origin = "top-right";
        frame_width = 2;
        corner_radius = 8;
        font = "Monaspace Neon 11";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 30;
        icon_position = "left";
        max_icon_size = 48;
        mouse_left_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
    };
  };
}
