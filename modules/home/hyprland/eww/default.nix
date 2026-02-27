{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;

  # ── Helper scripts ──

  workspaces = pkgs.writeShellScript "eww-workspaces" ''
    active_ws() {
      ${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq '.id'
    }

    occupied_ws() {
      ${pkgs.hyprland}/bin/hyprctl workspaces -j | ${pkgs.jq}/bin/jq '[.[].id] | sort'
    }

    generate() {
      active=$(active_ws)
      occupied=$(occupied_ws)
      result="["
      for i in $(seq 1 9); do
        is_active=$([ "$i" = "$active" ] && echo "true" || echo "false")
        is_occupied=$(echo "$occupied" | ${pkgs.jq}/bin/jq "any(. == $i)")
        [ "$i" -gt 1 ] && result="$result,"
        result="$result{\"id\":$i,\"active\":$is_active,\"occupied\":$is_occupied}"
      done
      result="$result]"
      echo "$result"
    }

    generate

    ${pkgs.socat}/bin/socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while IFS= read -r line; do
      case "$line" in
        workspace*|focusedmon*|createworkspace*|destroyworkspace*|moveworkspace*)
          generate
          ;;
      esac
    done
  '';

  activeWindow = pkgs.writeShellScript "eww-active-window" ''
    ${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.title // ""' | ${pkgs.coreutils}/bin/cut -c1-80

    ${pkgs.socat}/bin/socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while IFS= read -r line; do
      case "$line" in
        activewindow\>*|activewindowv2*)
          ${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.title // ""' | ${pkgs.coreutils}/bin/cut -c1-80
          ;;
      esac
    done
  '';

  volumeStatus = pkgs.writeShellScript "eww-volume" ''
    export XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"
    vol=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | ${pkgs.gawk}/bin/awk '{printf "%.0f", $2 * 100}')
    mute=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c MUTED)
    if [ "$mute" = "1" ]; then
      echo '{"icon":"󰝟","value":0,"text":"MUTE"}'
    elif [ -n "$vol" ]; then
      echo "{\"icon\":\"󰕾\",\"value\":$vol,\"text\":\"''${vol}%\"}"
    else
      echo '{"icon":"󰕾","value":0,"text":"--"}'
    fi
  '';

  wifiStatus = pkgs.writeShellScript "eww-wifi" ''
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
    ssid=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi 2>/dev/null | ${pkgs.gnugrep}/bin/grep '^yes:' | ${pkgs.coreutils}/bin/cut -d: -f2)
    if [ -n "$ssid" ]; then
      echo "{\"icon\":\"󰤨\",\"text\":\"$ssid\"}"
    else
      echo '{"icon":"󰤭","text":"Off"}'
    fi
  '';

  btStatus = pkgs.writeShellScript "eww-bluetooth" ''
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
    device=$(${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null | ${pkgs.coreutils}/bin/head -1 | ${pkgs.coreutils}/bin/cut -d' ' -f3-)
    if [ -n "$device" ]; then
      echo "{\"icon\":\"󰂯\",\"text\":\"$device\"}"
    else
      echo '{"icon":"","text":""}'
    fi
  '';

  batteryStatus = pkgs.writeShellScript "eww-battery" ''
    capacity=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
    status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
    if [ "$status" = "Charging" ]; then
      icon="󰂄"
    elif [ "$capacity" -le 10 ]; then
      icon="󰁺"
    elif [ "$capacity" -le 30 ]; then
      icon="󰁼"
    elif [ "$capacity" -le 60 ]; then
      icon="󰁾"
    else
      icon="󰁹"
    fi
    echo "{\"icon\":\"$icon\",\"value\":$capacity,\"text\":\"''${capacity}%\"}"
  '';

  cpuUsage = pkgs.writeShellScript "eww-cpu" ''
    read -r cpu user nice system idle iowait irq softirq steal _ < /proc/stat
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle1=$idle
    sleep 1
    read -r cpu user nice system idle iowait irq softirq steal _ < /proc/stat
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle2=$idle
    usage=$(( (100 * ( (total2 - total1) - (idle2 - idle1) )) / (total2 - total1) ))
    echo "$usage"
  '';

  ramUsage = pkgs.writeShellScript "eww-ram" ''
    ${pkgs.gawk}/bin/awk '/MemTotal/{total=$2} /MemAvailable/{available=$2} END{printf "%.0f", (total-available)/total*100}' /proc/meminfo
  '';

  # ── SCSS with inlined Gruvbox colors ──
  ewwScss = ''
    // Gruvbox Material Dark Hard
    $base00: #${colors.base00};
    $base01: #${colors.base01};
    $base02: #${colors.base02};
    $base03: #${colors.base03};
    $base04: #${colors.base04};
    $base05: #${colors.base05};
    $base08: #${colors.base08};
    $base09: #${colors.base09};
    $base0A: #${colors.base0A};
    $base0B: #${colors.base0B};
    $base0C: #${colors.base0C};
    $base0D: #${colors.base0D};
    $base0E: #${colors.base0E};

    * {
      all: unset;
      font-family: "Monaspace Neon", "Symbols Nerd Font", sans-serif;
      font-size: 13px;
    }

    .bar-content {
      background: rgba($base01, 0.92);
      border-radius: 12px;
      border: 2px solid $base02;
      padding: 0 12px;
    }

    .workspaces { padding: 0 4px; }

    .ws-btn {
      min-width: 24px;
      min-height: 24px;
      border-radius: 8px;
      color: $base04;
      padding: 0 4px;
      transition: all 150ms ease;
      &:hover { background: $base02; color: $base05; }
      &.occupied { color: $base05; }
      &.active { background: $base08; color: $base00; font-weight: bold; }
    }

    .window-title { color: $base05; padding: 0 16px; }
    .right-modules { padding: 0 4px; }

    .module {
      padding: 0 8px;
      color: $base05;
      border-radius: 8px;
      transition: all 150ms ease;
      &:hover { background: $base02; }
    }

    .module-icon { color: $base08; font-size: 14px; }
    .module-text { color: $base05; }

    .wifi .module-icon { color: $base0D; }
    .bluetooth .module-icon { color: $base0D; }
    .volume .module-icon { color: $base0A; }
    .battery .module-icon { color: $base0B; }
    .cpu .module-icon { color: $base09; }
    .ram .module-icon { color: $base0E; }
    .clock .module-icon { color: $base0C; }

    .systray { padding: 0 4px; }
  '';

  # ── Yuck config ──
  ewwYuck = builtins.readFile ./config/eww.yuck;
in
{
  programs.eww = {
    enable = true;
  };

  # Manage all eww config files via xdg.configFile
  xdg.configFile."eww/eww.yuck".text = ewwYuck;
  xdg.configFile."eww/eww.scss".text = ewwScss;
  xdg.configFile."eww/scripts/workspaces".source = workspaces;
  xdg.configFile."eww/scripts/active-window".source = activeWindow;
  xdg.configFile."eww/scripts/volume".source = volumeStatus;
  xdg.configFile."eww/scripts/wifi".source = wifiStatus;
  xdg.configFile."eww/scripts/bluetooth".source = btStatus;
  xdg.configFile."eww/scripts/battery".source = batteryStatus;
  xdg.configFile."eww/scripts/cpu".source = cpuUsage;
  xdg.configFile."eww/scripts/ram".source = ramUsage;
}
