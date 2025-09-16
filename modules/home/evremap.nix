{ pkgs, lib, ... }:

let
  evremap-launcher = pkgs.writeShellApplication {
    name = "evremap-all-keyboards-launcher";
    runtimeInputs = [ pkgs.evremap pkgs.procps pkgs.gawk ]; # Added gawk for robust parsing

    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # Kill any old evremap instances to prevent duplicates when the script re-runs.
      pkill -f "evremap remap" || true

      # This is the TOML configuration content for your dual-role key.
      # We define it once and reuse it for each keyboard.
      CONFIG_TEMPLATE='[[dual_role]]
      input = "KEY_CAPSLOCK"
      hold = ["KEY_LEFTCTRL"]
      tap = ["KEY_ESC"]'

      echo "Searching for keyboard devices..."

      # A more robust way to find and parse device names.
      # This handles names with spaces or special characters correctly.
      ${pkgs.evremap}/bin/evremap list-devices | ${pkgs.gawk}/bin/awk -F'"' '/keyboard/ {print $2}' | while IFS= read -r device_name; do
        if [ -n "$device_name" ]; then
          echo "Applying evremap configuration to: \"$device_name\""

          # Use printf to construct the full config and pipe it to evremap.
          # This avoids the problematic '<<' syntax.
          printf "device_name = \"%s\"\n%s" "$device_name" "$CONFIG_TEMPLATE" | ${pkgs.evremap}/bin/evremap remap &
        fi
      done

      echo "evremap configured for all found keyboards."
      # Wait for background processes to start
      wait
    '';
  };

in
{
  home.packages = with pkgs; [
    evremap
  ];

  systemd.user.services.evremap-dynamic = {
    Unit = {
      Description = "Evremap dynamic keyboard launcher";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${evremap-launcher}/bin/evremap-all-keyboards-launcher";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Make sure your old service is removed or disabled
  # systemd.user.services.evremap = lib.mkForce null;
}
