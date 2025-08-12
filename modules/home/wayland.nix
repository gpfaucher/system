{ lib, config, pkgs, ... }:

let
  ayu = {
    dark = {
      bg = "0F1419";
      fg = "BFBDB6";
      black = "01060E";
      red = "F07178";
      green = "A6CC70";
      yellow = "E6B450";
      blue = "59C2FF";
      magenta = "D2A6FF";
      cyan = "95E6CB";
      white = "FFFFFF";
    };
    mirage = {
      bg = "212733";
      fg = "BFBDB6";
      black = "171B24";
      red = "F28779";
      green = "B8CC52";
      yellow = "E6B450";
      blue = "59C2FF";
      magenta = "D2A6FF";
      cyan = "95E6CB";
      white = "FFFFFF";
    };
    light = {
      bg = "FAFAFA";
      fg = "5C6773";
      black = "F0F0F0";
      red = "F07178";
      green = "78B34D";
      yellow = "E6B450";
      blue = "36A3D9";
      magenta = "A37ACC";
      cyan = "3D978D";
      white = "000000";
    };
  };
  theme = ayu.mirage;
in
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

          programs.waybar = {
    enable = true;
    settings = [{
      layer = "bottom";
      spacing = 0;
      "margin-bottom" = 0;
      "margin-top" = 8;
      position = "top";
      "margin-right" = 15;
      "margin-left" = 15;
      "modules-left" = [
        "custom/pacman"
        "sway/workspaces"
      ];
      "modules-center" = [
        "sway/window"
      ];
      "modules-right" = [
        "pulseaudio"
        "bluetooth"
        "battery"
        "network"
        "clock"
      ];
      "custom/pacman" = {
        format = "{}  ";
        interval = 3600;
        exec = "(checkupdates;pacman -Qm | aur vercmp) | wc -l";
        "exec-if" = "exit 0";
        "on-click" = "kitty sh -c 'yay; echo Done - Press enter to exit; read'; pkill -SIGRTMIN+8 waybar";
        signal = 8;
        tooltip = false;
      };
      "sway/workspaces" = {
        "all-outputs" = true;
        "disable-scroll" = true;
        tooltip = false;
        format = " {value} ";
        "format-window-separator" = " | ";
        "persistent-workspaces" = {
          "⛩️" = [];
          " " = [];
          " " = [];
          "️" = [];
          "" = [];
        };
      };
      "sway/window" = {
        format = "{app_id} | {title}";
        "max-length" = 40;
        tooltip = false;
        icon = true;
        "icon-size" = 14;
      };
      bluetooth = {
        format = " {status}";
        "format-connected" = " {device_alias}";
        "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
        "on-click" = "blueman-manager";
        tooltip = false;
      };
      clock = {
        format = "  {:%I:%M %p}";
        tooltip = false;
      };
      network = {
        "format-wifi" = "{essid}   {bandwidthDownBits}";
        "format-ethernet" = "  {bandwidthDownBits}";
        "format-disconnected" = "No Network  ";
        interval = 1;
        tooltip = false;
        "on-click" = "kitty --class nmwui nmtui";
      };
      pulseaudio = {
        tooltip = false;
        format = "{icon} {volume}%";
        "format-bluetooth" = "{icon}  {volume}%";
        "format-bluetooth-muted" = " {icon} ";
        "format-muted" = "婢";
        "format-icons" = {
          headphone = "";
          headset = "";
          default = [
            "奄"
            "奔"
            "墳"
          ];
        };
        "on-click" = "pavucontrol";
        "min-length" = 3;
      };
      battery = {
        tooltip = false;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        "format-charging" = " {capacity}%";
        "format-plugged" = " {capacity}%";
        "format-alt" = "{icon} {time}";
        "format-full" = " {capacity}%";
        "format-icons" = [
          ""
          ""
          ""
        ];
      };
    }];
    style = builtins.readFile ./waybar.css;
  };
}