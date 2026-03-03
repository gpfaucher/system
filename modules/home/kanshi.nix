{ config, pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "3840x2400@60Hz";
            scale = 2.0;
          }
        ];
      };

      # AOC ultrawide at desk
      desk = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "AOC CU34V5C 1UJQBHA000955";
            mode = "3440x1440@100Hz";
          }
        ];
      };

      # MSI G272QPF E2
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Microstep G272QPF E2 0x01010101";
            mode = "2560x1440@143.91Hz";
          }
        ];
      };
    };
  };
}
