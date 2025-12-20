{pkgs, ...}: {
  services.kanshi = {
    enable = true;
    systemdTarget = "river-session.target";
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
      }

      # Presentation: Laptop + any HDMI display (conference rooms, projectors)
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
          "${pkgs.libnotify}/bin/notify-send 'Presentation Mode' 'HDMI display connected'"
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
          "${pkgs.libnotify}/bin/notify-send 'Presentation Mode' 'DP display connected'"
        ];
      }

      # Fallback: Any unknown external display extended to the right
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
          "${pkgs.libnotify}/bin/notify-send 'Display Connected' 'Using fallback profile. Use wdisplays to adjust.'"
        ];
      }
    ];
  };
}
