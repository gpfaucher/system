{ config, lib, pkgs, ... }:

let
  # Bluetooth monitor script for automatic multipoint device management
  bluetooth-monitor = pkgs.writeShellScript "bluetooth-monitor.sh" ''
    #!/usr/bin/env bash
    
    # Bluetooth Multipoint Call Monitor
    # Handles device suspension/reconnection during VoIP calls
    
    set -euo pipefail
    
    # Configuration
    FALLBACK_TIMEOUT=5  # Seconds before falling back to laptop audio
    RECONNECT_DELAY=2   # Seconds to wait before reconnecting other devices
    
    # Logging
    log() {
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | ${pkgs.systemd}/bin/systemd-cat -t bluetooth-monitor
    }
    
    # Notification helper
    notify() {
      local title="$1"
      local message="$2"
      ${pkgs.libnotify}/bin/notify-send -u normal -t 3000 "$title" "$message"
    }
    
    # Get currently connected Bluetooth audio devices
    get_connected_audio_devices() {
      ${pkgs.bluez}/bin/bluetoothctl devices Connected | \
        grep -E "(Headphone|Headset|Speaker)" || true
    }
    
    # Get device MAC address from device info line
    get_device_mac() {
      echo "$1" | awk '{print $2}'
    }
    
    # Get device name from device info line
    get_device_name() {
      echo "$1" | cut -d' ' -f3-
    }
    
    # Check if device is using HSP/HFP profile (headset mode)
    is_using_headset_profile() {
      local mac="$1"
      ${pkgs.wireplumber}/bin/wpctl status | \
        grep -A5 "$mac" | \
        grep -q "headset-head-unit" || \
        grep -q "headset_head_unit"
    }
    
    # Get primary audio sink (active device)
    get_active_sink() {
      ${pkgs.wireplumber}/bin/wpctl status | \
        grep -A20 "Audio" | \
        grep "*" | \
        head -n1 || true
    }
    
    # Track suspended devices for reconnection
    declare -A suspended_devices
    
    # Main monitoring loop
    log "Bluetooth monitor started"
    notify "Bluetooth Monitor" "Multipoint call handling active"
    
    # Monitor PipeWire/WirePlumber events via wpctl
    ${pkgs.wireplumber}/bin/wpctl status --monitor | while read -r line; do
      # Get all connected audio devices
      devices=$(get_connected_audio_devices)
      
      if [ -z "$devices" ]; then
        continue
      fi
      
      # Check each connected device
      while IFS= read -r device; do
        mac=$(get_device_mac "$device")
        name=$(get_device_name "$device")
        
        # Check if device switched to headset profile (call started)
        if is_using_headset_profile "$mac"; then
          log "Headset profile detected on $name ($mac) - call started"
          
          # Find other connected audio devices
          other_devices=$(echo "$devices" | grep -v "$mac" || true)
          
          if [ -n "$other_devices" ]; then
            # Suspend other devices to prevent conflicts
            while IFS= read -r other; do
              other_mac=$(get_device_mac "$other")
              other_name=$(get_device_name "$other")
              
              log "Suspending $other_name ($other_mac) during call"
              notify "Call Mode Active" "Suspending $other_name for call quality"
              
              # Disconnect the other device
              echo "disconnect $other_mac" | ${pkgs.bluez}/bin/bluetoothctl >/dev/null 2>&1 || true
              
              # Track for reconnection
              suspended_devices["$other_mac"]="$other_name"
            done <<< "$other_devices"
          fi
          
          # Monitor for buzzing/issues - fallback to laptop audio if needed
          sleep "$FALLBACK_TIMEOUT"
          
          # Check if audio sink is still active
          active_sink=$(get_active_sink)
          if [ -z "$active_sink" ] || ! echo "$active_sink" | grep -q "$mac"; then
            log "Audio issue detected, falling back to laptop audio"
            notify "Audio Fallback" "Switching to laptop speakers/mic due to connection issue"
            
            # Switch to laptop audio (first available non-Bluetooth sink)
            laptop_sink=$(${pkgs.wireplumber}/bin/wpctl status | \
              grep -v "bluez" | \
              grep "sink" | \
              head -n1 | \
              awk '{print $2}' | \
              tr -d '*.' || true)
            
            if [ -n "$laptop_sink" ]; then
              ${pkgs.wireplumber}/bin/wpctl set-default "$laptop_sink" || true
            fi
          fi
        else
          # Check if we're back to A2DP (call ended)
          active_sink=$(get_active_sink)
          if echo "$active_sink" | grep -q "$mac" && ! is_using_headset_profile "$mac"; then
            # Call ended, reconnect suspended devices
            if [ ''${#suspended_devices[@]} -gt 0 ]; then
              log "Call ended, waiting $RECONNECT_DELAY seconds before reconnecting devices"
              sleep "$RECONNECT_DELAY"
              
              for suspended_mac in "''${!suspended_devices[@]}"; do
                suspended_name="''${suspended_devices[$suspended_mac]}"
                log "Reconnecting $suspended_name ($suspended_mac)"
                notify "Reconnecting Device" "Restoring connection to $suspended_name"
                
                echo "connect $suspended_mac" | ${pkgs.bluez}/bin/bluetoothctl >/dev/null 2>&1 || true
              done
              
              # Clear suspended devices
              unset suspended_devices
              declare -A suspended_devices
            fi
          fi
        fi
      done <<< "$devices"
    done
  '';
in
{
  # Systemd user service for Bluetooth monitor
  systemd.user.services.bluetooth-monitor = {
    description = "Bluetooth Multipoint Call Monitor";
    documentation = [ "Handles automatic device switching during VoIP calls" ];
    
    after = [ "pipewire.service" "wireplumber.service" "bluetooth.service" ];
    requires = [ "pipewire.service" "wireplumber.service" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${bluetooth-monitor}";
      Restart = "on-failure";
      RestartSec = 5;
      
      # Security hardening
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
    };
  };
  
  # Required packages for the monitor script
  environment.systemPackages = with pkgs; [
    bluez           # bluetoothctl
    wireplumber     # wpctl
    libnotify       # notify-send
  ];
}
