{ pkgs
, lib
, config
, ...
}:
let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in
with lib; {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        margin = "0";
        layer = "top";
        position = "top";
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "hyprland/window"
          "pulseaudio"
          "cpu"
          "memory"
        ];
        modules-right = [
          "custom/notification"
          "custom/exit"
          "battery"
          "tray"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format = ''{:L%H:%M}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = " {free}";
          tooltip = true;
        };
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = " {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = false;
        };
        "tray" = {
          spacing = 12;
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = false;
        };
      }
    ];
    style = concatStrings [
      ''
        * {
          font-family: JetBrainsMono Nerd Font Mono;
          font-size: 16px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
        }
        window#waybar {
          background: rgba(0,0,0,0);
        }
        #workspaces {
          color: #${config.lib.stylix.colors.base00};
          background: #${config.lib.stylix.colors.base01};
          margin: 4px 2px;
          padding: 5px 5px;
          border-radius: 16px;
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.5;
          transition: ${betterTransition};
        }
        #workspaces button.active {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          transition: ${betterTransition};
          opacity: 1.0;
          min-width: 40px;
        }
        #workspaces button:hover {
          font-weight: bold;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base00};
          background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
          opacity: 0.8;
          transition: ${betterTransition};
        }
        tooltip {
          background: #${config.lib.stylix.colors.base00};
          border: 1px solid #${config.lib.stylix.colors.base08};
          border-radius: 12px;
        }
        tooltip label {
          color: #${config.lib.stylix.colors.base08};
        }
        #window, #pulseaudio, #cpu, #memory {
          font-weight: bold;
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 18px;
          background: #${config.lib.stylix.colors.base04};
          color: #${config.lib.stylix.colors.base00};
          border-radius: 16px;
        }
         #tray, #custom-exit {
          font-weight: bold;
          background: #${config.lib.stylix.colors.base0F};
          color: #${config.lib.stylix.colors.base00};
          margin: 4px 0px;
          margin-right: 7px;
          border-radius: 16px;
          padding: 0px 18px;
        }
        #clock {
          font-weight: bold;
          color: #0D0E15;
          background: linear-gradient(90deg, #${config.lib.stylix.colors.base0E}, #${config.lib.stylix.colors.base0C});
          margin: 4px 7px 4px 0px;
          padding: 0px 18px;
          border-radius: 16px;
        }
      ''
    ];
  };
}
