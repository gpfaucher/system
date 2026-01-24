{ config, lib, pkgs, ... }:

{
  # Tabby AI coding assistant service
  systemd.user.services.tabby = {
    Unit = {
      Description = "Tabby AI coding assistant";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.tabby}/bin/tabby serve --model StarCoder-1B --device cuda";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Kanshi display configuration service
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
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
    RestartSec = lib.mkForce 5;  # 5 seconds
  };

  # River WM Resume Hook - Reconnect layout manager after suspend
  systemd.user.services.river-resume-hook = {
    Unit = {
      Description = "River WM Resume Hook";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1.5";
      ExecStart = "${pkgs.libnotify}/bin/notify-send -u low 'River' 'Restoring tiling layout...'";
      ExecStartPost = [
        "${pkgs.river-classic}/bin/riverctl default-layout wideriver"
        "${pkgs.kanshi}/bin/kanshictl reload"
        "${pkgs.coreutils}/bin/sleep 0.2"
        "${pkgs.river-classic}/bin/riverctl focus-output next"
        "${pkgs.coreutils}/bin/sleep 0.1"
        "${pkgs.river-classic}/bin/riverctl focus-output previous"
      ];
      RemainAfterExit = false;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
