{ pkgs, ... }: {
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "docked-work";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.75; # Keep the scale increase
            # Position the laptop below the external monitor and centered
            # The Y position is the height of the external monitor (1440)
            # The X position is half the difference between the external monitor width (3440) and laptop width (1920)
            position = "760,1440"; # (3440 - 1920) / 2 = 760
          }
          {
            criteria = "DP-1";
            mode = "3440x1440@100";
            # Keep the external monitor at the top-left
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "docked-home";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
            # Position the laptop below the external monitor and centered
            # The Y position is the height of the external monitor (1440)
            # The X position is half the difference between the external monitor width (3440) and laptop width (1920)
          }
          {
            criteria = "HDMI-A-1";
            mode = "3440x1440@100";
            # Keep the external monitor at the top-left
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2400";
            scale = 1.666667; # Keep the scale increase
            # Position the laptop below the external monitor and centered
            # The Y position is the height of the external monitor (1440)
            # The X position is half the difference between the external monitor width (3440) and laptop width (1920)
          }
        ];
      }
    ];
  };
}
