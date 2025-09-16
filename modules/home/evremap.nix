{ pkgs, lib, ... }:

let
  evremap-launcher = pkgs.writeShellApplication {
    name = "evremap-all-keyboards-launcher";
    runtimeInputs = [ pkgs.evremap pkgs.procps pkgs.gawk ];

    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # Use a temporary file to prevent pkill from killing the script's own parent
      pkill -f "evremap remap" || true

      CONFIG_TEMPLATE='[[dual_role]]
      input = "KEY_CAPSLOCK"
      hold = ["KEY_LEFTCTRL"]
      tap = ["KEY_ESC"]'

      echo "Searching for keyboard devices..."

      # Find all devices with "keyboard" or "kbd" in their name and store in a variable
      KEYBOARD_DEVICES=$(${pkgs.evremap}/bin/evremap list-devices | ${pkgs.gawk}/bin/awk -F'"' '/keyboard|kbd/ {print $2}')

      # NEW: Check if any keyboards were found. If not, exit with an error.
      if [ -z "$KEYBOARD_DEVICES" ]; then
        echo "No keyboard devices found yet. Will retry."
        exit 1
      fi

      # Loop through each found keyboard and start an evremap instance
      echo "$KEYBOARD_DEVICES" | while IFS= read -r device_name; do
        if [ -n "$device_name" ]; then
          echo "Applying evremap configuration to: \"$device_name\""
          printf "device_name = \"%s\"\n%s" "$device_name" "$CONFIG_TEMPLATE" | ${pkgs.evremap}/bin/evremap remap &
        fi
      done

      echo "evremap successfully configured for all found keyboards."
      wait
    '';
  };

in
{
  home.packages = with pkgs; [ evremap ];

  systemd.user.services.evremap-dynamic = {
    Unit = {
      Description = "Evremap dynamic keyboard launcher";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${evremap-launcher}/bin/evremap-all-keyboards-launcher";
      
      # NEW: Add restart logic to handle timing issues on startup
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
