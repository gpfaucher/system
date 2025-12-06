{ pkgs, ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      # Laptop only (no external monitors)
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080@60Hz";  # Adjust to actual laptop resolution
            position = "0,0";
            scale = 1.0;
          }
        ];
      }
      # External ultrawide only (laptop closed/disabled)
      {
        profile.name = "docked-single";
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
      # Both displays (laptop + external)
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
            position = "3440,0";  # Right of ultrawide
            scale = 1.0;
          }
        ];
      }
    ];
  };
}