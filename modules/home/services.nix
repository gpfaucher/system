{
  lib,
  pkgs,
  ...
}:

let
  # Commands for swayidle actions
  lockCmd = "${pkgs.waylock}/bin/waylock";
  # Screen brightness dimming via brightnessctl (reduce to 10%)
  dimCmd = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
  undimCmd = "${pkgs.brightnessctl}/bin/brightnessctl -r";
  # DPMS control for River WM via wlopm
  dpmsOffCmd = "${pkgs.wlopm}/bin/wlopm --off '*'";
  dpmsOnCmd = "${pkgs.wlopm}/bin/wlopm --on '*'";
in
{
  # Kanshi display configuration service
  services.kanshi = {
    enable = true;
    systemdTarget = "default.target";
    settings = [
      # Dual external monitors: Portrait + Ultrawide (laptop disabled)
      {
        profile.name = "dual-portrait-ultrawide";
        profile.outputs = [
          {
            criteria = "DP-2";
            mode = "2560x1440@60Hz";
            position = "0,0";
            scale = 1.0;
            transform = "90";
            status = "enable";
          }
          {
            criteria = "HDMI-A-1";
            mode = "3440x1440@100Hz";
            position = "1440,0";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
        profile.exec = [
          "${pkgs.libnotify}/bin/notify-send 'Display Profile' 'Dual monitor: Portrait + Ultrawide'"
          "$HOME/.local/bin/workspace-dual-monitor"
        ];
      }
      # Laptop only (no external monitors)
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
            status = "enable";
          }
        ];
        profile.exec = [
          "${pkgs.libnotify}/bin/notify-send 'Display Profile' 'Laptop only'"
          "$HOME/.local/bin/workspace-laptop-only"
        ];
      }
      # External ultrawide only via DP (laptop closed/disabled)
      {
        profile.name = "docked-dp";
        profile.outputs = [
          {
            criteria = "DP-2";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
        profile.exec = [
          "${pkgs.libnotify}/bin/notify-send 'Display Profile' 'Docked DP ultrawide'"
          "$HOME/.local/bin/workspace-ultrawide-only"
        ];
      }
      # External display via HDMI only (laptop disabled)
      {
        profile.name = "docked-hdmi";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
        profile.exec = [
          "${pkgs.libnotify}/bin/notify-send 'Display Profile' 'Docked HDMI ultrawide'"
          "$HOME/.local/bin/workspace-ultrawide-only"
        ];
      }
      # Both displays (laptop + external ultrawide)
      {
        profile.name = "docked-dual";
        profile.outputs = [
          {
            criteria = "DP-2";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "eDP-1";
            mode = "3840x2400@60Hz";
            position = "3440,0";
            scale = 2.0;
            status = "enable";
          }
        ];
      }
      # Presentation: Laptop + any HDMI display
      {
        profile.name = "presentation-hdmi";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
            status = "enable";
          }
          {
            criteria = "HDMI-A-*";
            position = "1920,0";
            scale = 1.0;
            status = "enable";
          }
        ];
        profile.exec = [ "${pkgs.libnotify}/bin/notify-send 'Presentation Mode' 'HDMI display connected'" ];
      }
      # Presentation: Laptop + any DP display
      {
        profile.name = "presentation-dp";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2400@60Hz";
            position = "0,0";
            scale = 2.0;
            status = "enable";
          }
          {
            criteria = "DP-*";
            position = "1920,0";
            scale = 1.0;
            status = "enable";
          }
        ];
        profile.exec = [ "${pkgs.libnotify}/bin/notify-send 'Presentation Mode' 'DP display connected'" ];
      }
    ];
  };

  # Gammastep blue light filter service
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 52.37;
    longitude = 4.90;
    temperature = {
      day = 6500;
      night = 3500;
    };
    settings = {
      general = {
        adjustment-method = "wayland";
        fade = 1;
      };
    };
  };

  # Override gammastep systemd service to add restart policy and multi-monitor support
  # Must use lib.mkForce to override the home-manager module's generated service
  systemd.user.services.gammastep.Service = {
    # Restart on failure (handles Wayland disconnections)
    Restart = lib.mkForce "on-failure";
    RestartSec = lib.mkForce 5; # 5 seconds
    
    # Security hardening (basic - needs Wayland display access)
    PrivateTmp = true;
    NoNewPrivileges = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
  };

  # Override kanshi systemd service to survive suspend/resume and fix startup race condition
  systemd.user.services.kanshi = {
    Unit = {
      # Remove PartOf to prevent stopping on suspend
      PartOf = lib.mkForce [ ];
      # Disable restart rate limiting
      StartLimitIntervalSec = lib.mkForce 0;
      # Remove WAYLAND_DISPLAY condition - River starts us after Wayland is ready
      ConditionEnvironment = lib.mkForce [ ];
    };
    Service = {
      # Add delay between restart attempts to avoid rapid failures during startup
      # This helps when WAYLAND_DISPLAY isn't immediately available
      RestartSec = lib.mkForce 2;
    };
  };

  # Wideriver layout generator for River WM
  # Managed as a systemd service to enable proper restart after suspend/resume
  systemd.user.services.wideriver = {
    Unit = {
      Description = "Wideriver layout generator for River WM";
      After = [ "graphical-session.target" ];
      # Disable restart rate limiting - wideriver may restart many times during suspend/resume
      StartLimitIntervalSec = 0;
    };
    Service = {
      ExecStart = "${pkgs.wideriver}/bin/wideriver --layout left --stack dwindle --count-master 1 --ratio-master 0.55 --border-width 2 --border-width-monocle 0 --inner-gap 0 --outer-gap 0";
      # Always restart when wideriver dies (including after suspend/resume when River drops the connection)
      Restart = "always";
      RestartSec = "2s";
      
      # Security hardening
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Swayidle idle management service
  # Configures automatic screen dimming, locking, and display power-off
  services.swayidle = {
    enable = true;
    # Wait for idle command to finish before continuing to process events (-w flag)
    extraArgs = [ "-w" ];
    systemdTarget = "graphical-session.target";

    # Timeouts: dim at 5m, lock at 10m, display off at 15m
    timeouts = [
      # Dim screen after 5 minutes (300 seconds)
      {
        timeout = 300;
        command = dimCmd;
        resumeCommand = undimCmd;
      }
      # Lock screen after 10 minutes (600 seconds)
      {
        timeout = 600;
        command = lockCmd;
      }
      # Turn off display after 15 minutes (900 seconds)
      {
        timeout = 900;
        command = dpmsOffCmd;
        resumeCommand = dpmsOnCmd;
      }
    ];

    # Events: handle sleep/resume and manual lock/unlock
    # Note: Uses attrset syntax (home-manager 24.11+)
    events = {
      # Lock screen before system sleeps
      before-sleep = "${lockCmd}; ${dpmsOffCmd}";
      # Restore display after resume
      after-resume = dpmsOnCmd;
      # Handle explicit lock request (loginctl lock-session)
      lock = lockCmd;
    };
  };

  # Override swayidle systemd service for security hardening and restart behavior
  systemd.user.services.swayidle = {
    Unit = {
      # Disable restart rate limiting for suspend/resume cycles
      StartLimitIntervalSec = lib.mkForce 0;
    };
    Service = {
      # Restart on failure (handles Wayland disconnections)
      Restart = lib.mkForce "on-failure";
      RestartSec = lib.mkForce 2;

      # Security hardening (needs Wayland display access)
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
    };
  };
}
