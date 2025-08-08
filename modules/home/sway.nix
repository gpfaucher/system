{ pkgs, ... }: {
  programs.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "wofi --show drun";
      bars = [];
      startup = [
        { command = "swaybg -i ~/.config/wallpaper"; }
        { command = "swayidle -w"; }
      ];
      keybindings = {
        "Mod4+Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
      };
    };
    extraConfig = ''
      include /etc/sway/config.d/*
    '';
  };
}
