{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        margin-top = 6;
        margin-left = 8;
        margin-right = 8;
        output = "*";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "wireplumber"
          "battery"
          "cpu"
          "memory"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          all-outputs = false;
          show-special = false;
          sort-by-number = true;
        };

        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };

        bluetooth = {
          format = "󰂯 {device_alias}";
          format-disabled = "";
          format-off = "";
          format-no-controller = "";
          format-connected = "󰂯 {device_alias}";
          format-connected-battery = "󰂯 {device_alias} {device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = "󰤭 Off";
          on-click = "nm-connection-editor";
        };

        wireplumber = {
          format = "󰕾 {volume}%";
          format-muted = "󰝟 MUTE";
          on-click = "pavucontrol";
        };

        battery = {
          interval = 10;
          states = {
            warning = 30;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        };

        cpu = {
          interval = 2;
          format = "󰻠 {usage}%";
        };

        memory = {
          interval = 2;
          format = "󰍛 {percentage}%";
        };

        clock = {
          interval = 1;
          format = "󰥔 {:%a %d %b  %H:%M}";
        };
      };
    };

    style = ''
      * {
        font-family: "Monaspace Neon", "Symbols Nerd Font", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, 0.92);
        border-radius: 12px;
        border: 2px solid #${colors.base02};
        padding: 0 12px;
      }

      /* ── Workspaces ── */
      #workspaces button {
        min-width: 24px;
        min-height: 24px;
        border-radius: 8px;
        color: #${colors.base04};
        padding: 0 4px;
        transition: all 150ms ease;
      }

      #workspaces button:hover {
        background: #${colors.base02};
        color: #${colors.base05};
      }

      #workspaces button.active {
        background: #${colors.base08};
        color: #${colors.base00};
        font-weight: bold;
      }

      #workspaces button.occupied {
        color: #${colors.base05};
      }

      /* ── Window title ── */
      #window {
        color: #${colors.base05};
        padding: 0 16px;
      }

      /* ── Modules ── */
      #tray,
      #bluetooth,
      #network,
      #wireplumber,
      #battery,
      #cpu,
      #memory,
      #clock {
        padding: 0 8px;
        color: #${colors.base05};
        border-radius: 8px;
        transition: all 150ms ease;
      }

      #tray:hover,
      #bluetooth:hover,
      #network:hover,
      #wireplumber:hover,
      #battery:hover,
      #cpu:hover,
      #memory:hover,
      #clock:hover {
        background: #${colors.base02};
      }

      /* Module-specific icon colors via font color */
      #network { color: #${colors.base0D}; }
      #bluetooth { color: #${colors.base0D}; }
      #wireplumber { color: #${colors.base0A}; }
      #battery { color: #${colors.base0B}; }
      #cpu { color: #${colors.base09}; }
      #memory { color: #${colors.base0E}; }
      #clock { color: #${colors.base0C}; }
      #tray { padding: 0 4px; }

      /* Battery states */
      #battery.warning { color: #${colors.base0A}; }
      #battery.critical { color: #${colors.base08}; }
    '';
  };
}
