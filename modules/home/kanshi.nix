{pkgs, ...}: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      # Laptop only (no external monitors)
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor eDP-1,3840x2400@60,0x0,2"
          "hyprctl dispatch moveworkspacetomonitor 1 eDP-1"
          "hyprctl dispatch moveworkspacetomonitor 2 eDP-1"
        ];
      }

      # External ultrawide only via DP (laptop closed/disabled)
      {
        profile.name = "docked-dp";
        profile.outputs = [
          {
            criteria = "DP-2";
            status = "enable";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor DP-2,3440x1440@100,0x0,1"
          "hyprctl keyword monitor eDP-1,disable"
          "hyprctl dispatch moveworkspacetomonitor 1 DP-2"
          "hyprctl dispatch moveworkspacetomonitor 2 DP-2"
        ];
      }

      # External display via HDMI only (laptop disabled)
      {
        profile.name = "docked-hdmi";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            status = "enable";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor HDMI-A-1,3440x1440@100,0x0,1"
          "hyprctl keyword monitor eDP-1,disable"
          "hyprctl dispatch moveworkspacetomonitor 1 HDMI-A-1"
          "hyprctl dispatch moveworkspacetomonitor 2 HDMI-A-1"
        ];
      }

      # Both displays (laptop + external ultrawide)
      {
        profile.name = "docked-dual";
        profile.outputs = [
          {
            criteria = "DP-2";
            status = "enable";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "3840x2400@60Hz";
            position = "3440,0";
            scale = 2.0;
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor DP-2,3440x1440@100,0x0,1"
          "hyprctl keyword monitor eDP-1,3840x2400@60,3440x0,2"
        ];
      }

      # Presentation: Laptop + any HDMI display (conference rooms, projectors)
      # Uses wildcard * to match any unknown HDMI display
      {
        profile.name = "presentation-hdmi";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
          }
          {
            criteria = "HDMI-A-*";
            status = "enable";
            position = "1920,0";
            scale = 1.0;
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor eDP-1,3840x2400@60,0x0,2"
          "hyprctl keyword monitor HDMI-A-1,preferred,1920x0,1"
        ];
      }

      # Presentation: Laptop + any DP display (USB-C docks, adapters)
      {
        profile.name = "presentation-dp";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
          }
          {
            criteria = "DP-*";
            status = "enable";
            position = "1920,0";
            scale = 1.0;
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor eDP-1,3840x2400@60,0x0,2"
          "hyprctl keyword monitor DP-1,preferred,1920x0,1"
        ];
      }

      # Fallback: Any unknown external display extended to the right
      # Catches displays not matched by specific profiles above
      {
        profile.name = "external-fallback";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
          }
          {
            criteria = "*";
            status = "enable";
            position = "1920,0";
            scale = 1.0;
          }
        ];
        profile.exec = [
          "hyprctl keyword monitor eDP-1,3840x2400@60,0x0,2"
          "notify-send 'Display Connected' 'Using fallback profile. Use wdisplays to adjust.'"
        ];
      }
    ];
  };
}
