{
  config,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 3;
      };

      background = lib.mkForce [
        {
          monitor = "";
          color = "rgb(${colors.base00})";
          blur_passes = 2;
          blur_size = 4;
        }
      ];

      input-field = lib.mkForce [
        {
          monitor = "";
          size = "300, 50";
          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.3;
          dots_center = true;
          outer_color = "rgb(${colors.base02})";
          inner_color = "rgb(${colors.base01})";
          font_color = "rgb(${colors.base05})";
          fade_on_empty = false;
          placeholder_text = "Password...";
          hide_input = false;
          check_color = "rgb(${colors.base0A})";
          fail_color = "rgb(${colors.base08})";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];

      label = lib.mkForce [
        {
          monitor = "";
          text = "$TIME";
          color = "rgb(${colors.base05})";
          font_size = 72;
          font_family = "Monaspace Neon";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date '+%A, %B %d'";
          color = "rgb(${colors.base04})";
          font_size = 18;
          font_family = "Monaspace Neon";
          position = "0, 50";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
