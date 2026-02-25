{ config, pkgs, ... }:

let
  # Helper script for bluetooth device name
  btDevice = pkgs.writeShellScript "bt-device" ''
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
    device=$(${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null | ${pkgs.coreutils}/bin/head -1 | ${pkgs.coreutils}/bin/cut -d' ' -f3-)
    if [ -n "$device" ]; then
      echo " 󰂯 $device "
    fi
  '';

  # Helper script for wifi via nmcli (more reliable than iw)
  wifiStatus = pkgs.writeShellScript "wifi-status" ''
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
    ssid=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi 2>/dev/null | ${pkgs.gnugrep}/bin/grep '^yes:' | ${pkgs.coreutils}/bin/cut -d: -f2)
    if [ -n "$ssid" ]; then
      echo " 󰤨 $ssid "
    else
      echo " 󰤭 "
    fi
  '';

  # Helper for volume via wpctl (PipeWire)
  volumeStatus = pkgs.writeShellScript "vol-status" ''
    export XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"
    vol=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | ${pkgs.gawk}/bin/awk '{printf "%.0f", $2 * 100}')
    mute=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c MUTED)
    if [ "$mute" = "1" ]; then
      echo " 󰝟 MUTE "
    elif [ -n "$vol" ]; then
      echo " 󰕾 ''${vol}% "
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
      { run_command,    "%s",                  "${btDevice}" },
      { run_command,    "%s",                  "${wifiStatus}" },
      { run_command,    "%s",                  "${volumeStatus}" },
      { battery_perc,   " 󰁹 %s%% ",         "BAT0" },
      { cpu_perc,       " 󰻠 %s%% ",         NULL },
      { ram_perc,       " 󰍛 %s%% ",         NULL },
      { datetime,       " 󰥔 %s ",           "%a %d %b  %H:%M" },
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
