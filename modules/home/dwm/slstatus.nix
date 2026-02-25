{ config, pkgs, ... }:

let
  # Helper script for bluetooth device name
  btDevice = pkgs.writeShellScript "bt-device" ''
    connected=$(${pkgs.bluez}/bin/bluetoothctl info 2>/dev/null | ${pkgs.gnugrep}/bin/grep -m1 "Name:" | ${pkgs.coreutils}/bin/cut -d' ' -f2-)
    if [ -n "$connected" ]; then
      echo " $connected"
    fi
  '';

  # Helper script for wifi (interface name may vary)
  wifiStatus = pkgs.writeShellScript "wifi-status" ''
    iface=$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gnugrep}/bin/grep -m1 'wl' | ${pkgs.gawk}/bin/awk -F': ' '{print $2}')
    if [ -n "$iface" ]; then
      ssid=$(${pkgs.iw}/bin/iw dev "$iface" link 2>/dev/null | ${pkgs.gnugrep}/bin/grep -m1 "SSID:" | ${pkgs.gawk}/bin/awk '{print $2}')
      if [ -n "$ssid" ]; then
        echo " $ssid"
      else
        echo " disconnected"
      fi
    fi
  '';

  # Helper for volume via wpctl (PipeWire)
  volumeStatus = pkgs.writeShellScript "vol-status" ''
    vol=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | ${pkgs.gawk}/bin/awk '{printf "%.0f", $2 * 100}')
    mute=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c MUTED)
    if [ "$mute" = "1" ]; then
      echo " MUTE"
    elif [ -n "$vol" ]; then
      echo " ''${vol}%"
    fi
  '';

  slstatusConfig = pkgs.writeText "slstatus-config.h" ''
    /* See LICENSE file for copyright and license details. */

    /* interval between updates (in ms) */
    const unsigned int interval = 2000;

    /* text to show if no value can be retrieved */
    static const char unknown_str[] = "";

    /* maximum output string length */
    #define MAXLEN 2048

    static const struct arg args[] = {
      /* function       format          argument */
      { run_command,    "%s |",         "${btDevice}" },
      { run_command,    "%s |",         "${wifiStatus}" },
      { run_command,    "%s |",         "${volumeStatus}" },
      { battery_perc,   " BAT %s%% |", "BAT0" },
      { cpu_perc,       " CPU %s%% |", NULL },
      { ram_perc,       " MEM %s%% |", NULL },
      { datetime,       " %s ",        "%a %b %d %H:%M" },
    };
  '';

  customSlstatus = pkgs.slstatus.overrideAttrs (old: {
    postPatch = ''
      cp ${slstatusConfig} config.def.h
    '';
  });
in
{
  home.packages = [ customSlstatus ];
}
