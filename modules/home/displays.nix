{ pkgs, ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "pc";
        profile.outputs = [
          {
            criteria = "Microstep MSI MAG342CQR DB6H261C02187";
            mode = "3440x1440@144.00";
          }
        ];
      }
      {
        profile.name = "work_1";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
          }
          {
            criteria = "AOC CU34V5C 1UJQBHA000782";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "work_2";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "AOC U34V5C 1QDQ6HA000288";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "work_3";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "AOC CU34V5C 1UJQBHA000972";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "wfh";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Microstep MSI MAG342CQR DB6H261C02187";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 2.00;
          }
        ];
      }
      {
        profile.name = "default";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "single_dp";
        profile.outputs = [
          {
            criteria = "DP-1";
            status = "enable";
            mode = "3440x1440@100.00";
          }
        ];
      }
      {
        profile.name = "single_edp";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
          }
        ];
      }
    ];
  };

  # Add display auto-detection script
  systemd.user.services.display-autoconfig = {
    Unit = {
      Description = "Auto-configure displays on connection";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "display-autoconfig" ''
        #!/bin/sh
        # Auto-configure displays when they're connected
        while true; do
          sleep 5
          # Check if external displays are connected
          EXTERNAL_CONNECTED=$(wlr-randr | grep -c "DP-1.*enabled")
          INTERNAL_STATUS=$(wlr-randr | grep "eDP-1" | grep -c "enabled")
          
          # If external display is connected but internal is enabled, disable internal
          if [ $EXTERNAL_CONNECTED -gt 0 ] && [ $INTERNAL_STATUS -gt 0 ]; then
            wlr-randr --output eDP-1 --off
          # If external display is not connected but internal is disabled, enable internal
          elif [ $EXTERNAL_CONNECTED -eq 0 ] && [ $INTERNAL_STATUS -eq 0 ]; then
            wlr-randr --output eDP-1 --on --scale 1.0
          fi
          
          # Apply reasonable scaling for large displays
          for display in $(wlr-randr | grep "Connector" | awk '{print $2}'); do
            RESOLUTION=$(wlr-randr --output $display | grep "current" | awk '{print $2}')
            if [ "$RESOLUTION" != "None" ]; then
              WIDTH=$(echo $RESOLUTION | cut -d'x' -f1)
              if [ $WIDTH -gt 2560 ] && [ "$display" != "eDP-1" ]; then
                # Large external display, apply scaling
                wlr-randr --output $display --scale 1.5
              fi
            fi
          done
        done
      ''}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
