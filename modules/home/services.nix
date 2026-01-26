{
  lib,
  pkgs,
  ...
}:

{
  # Tabby AI coding assistant service
  systemd.user.services.tabby = {
    Unit = {
      Description = "Tabby AI coding assistant";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.tabby}/bin/tabby serve --model Qwen2.5-Coder-3B --device cuda";
      Restart = "always";
      
      # Security hardening
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "tmpfs";
      BindPaths = [ "%h/.tabby" ]; # Bind-mount ~/.tabby directory for read-write access
      BindReadOnlyPaths = [ "%h/projects" ]; # Allow read access to repos for indexing
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      # Note: MemoryDenyWriteExecute not set - may conflict with CUDA/GPU
      # Note: DeviceAllow needed for GPU access is handled by default in user services
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

  # Wideriver layout generator for River WM
  # Managed as a systemd service to enable proper restart after suspend/resume
  systemd.user.services.wideriver = {
    Unit = {
      Description = "Wideriver layout generator for River WM";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
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
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
