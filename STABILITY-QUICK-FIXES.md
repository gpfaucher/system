# System Stability - Quick Fixes (Priority Order)

## 🔴 CRITICAL - DO FIRST (1-2 hours)

### 1. Move Unmonitored Processes to Systemd Services
**Why:** These processes restart automatically if they crash

Move from `riverctl spawn` in river.nix to systemd services:
- [ ] fnott (notifications)
- [ ] wideriver (tiling layout)
- [ ] swaybg (wallpaper)
- [ ] cliphist watchers (clipboard)
- [ ] nm-applet (network UI)
- [ ] blueman-applet (bluetooth UI)
- [ ] polkit-gnome-agent (auth dialogs)

**File to modify:** `modules/home/services.nix`

**Impact:** Services auto-restart on crash instead of going silent

---

### 2. Add Restart Policy to Tabby Service
**File:** `modules/home/services.nix` (lines 5-17)

**Change:**
```nix
# FROM:
Restart = "always";

# TO:
Restart = "on-failure";
RestartSec = 5;
StartLimitInterval = 60;
StartLimitBurst = 3;
MemoryMax = "4G";
StandardOutput = "journal";
StandardError = "journal";
TimeoutStartSec = 30;
TimeoutStopSec = 10;
```

**Impact:** Prevents CUDA process orphaning, limits resource usage

---

### 3. Add Logging to River-Resume-Hook
**File:** `modules/home/services.nix` (lines 181-204)

**Add after Service block opening:**
```nix
StandardOutput = "journal";
StandardError = "journal";
SyslogIdentifier = "river-resume";
TimeoutStartSec = 15;
```

**Add prefix `-` to commands in ExecStartPost to make failures non-fatal:**
```nix
ExecStartPost = [
  "-${pkgs.river-classic}/bin/riverctl default-layout wideriver"
  "-${pkgs.kanshi}/bin/kanshictl reload"
  # ... rest
];
```

**Impact:** Visibility into resume failures, non-blocking recovery

---

### 4. Enable Kanshi Restart Policy
**File:** `modules/home/services.nix`

**Issue:** Kanshi is auto-configured but has no restart policy

**Add explicit service:**
```nix
systemd.user.services.kanshi-monitor = {
  Unit = {
    Description = "Kanshi Display Manager";
    After = [ "graphical-session.target" "dbus.service" ];
    Wants = [ "dbus.service" ];
  };
  Service = {
    Type = "simple";
    ExecStart = "${pkgs.kanshi}/bin/kanshi";
    Restart = "on-failure";
    RestartSec = 3;
    StartLimitInterval = 60;
    StartLimitBurst = 3;
    StandardOutput = "journal";
    StandardError = "journal";
    TimeoutStartSec = 10;
    TimeoutStopSec = 5;
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

**Impact:** Display config auto-recovers from crashes

---

### 5. Add Gammastep Restart Policy
**File:** `modules/home/services.nix`

**Issue:** Gammastep has no restart policy

**Add after services.gammastep block:**
```nix
systemd.user.services.gammastep-monitor = {
  Unit = {
    Description = "Gammastep Blue Light Filter";
    After = [ "graphical-session.target" ];
  };
  Service = {
    Type = "simple";
    ExecStart = "${pkgs.gammastep}/bin/gammastep -l 52.37:4.90 -t 6500:3500";
    Restart = "on-failure";
    RestartSec = 5;
    StartLimitInterval = 300;
    StartLimitBurst = 3;
    StandardOutput = "journal";
    StandardError = "journal";
    TimeoutStartSec = 10;
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

**Impact:** Blue light filter auto-recovers, no eye strain from crashes

---

## 🟡 IMPORTANT - DO NEXT (2-3 hours)

### 6. Implement Backup Strategy
**File:** `hosts/laptop/default.nix`

**Add after existing config:**
```nix
# Enable automatic snapshots
services.snapper.enable = true;
services.snapper.configs.home = {
  subvolume = "/home";
  extraConfig = {
    "TIMELINE_CREATE" = "yes";
    "TIMELINE_LIMIT_HOURLY" = "24";
    "TIMELINE_LIMIT_DAILY" = "7";
  };
};

# Add backup timer
systemd.timers.backup-home = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "daily";
    Unit = "backup-home.service";
  };
};

systemd.services.backup-home = {
  description = "Backup home directory";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = ''
      bash -c 'if [ -d /mnt/backup ]; then rsync -avz --delete /home/ /mnt/backup/; fi'
    '';
  };
};
```

**Impact:** Data protected against loss, hourly backups available

---

### 7. Add River Process Monitoring
**File:** `modules/home/services.nix`

**Add new service:**
```nix
systemd.user.services.river-watchdog = {
  Unit = {
    Description = "River WM Process Monitor";
    PartOf = [ "graphical-session.target" ];
    After = [ "graphical-session.target" ];
  };
  Service = {
    Type = "simple";
    ExecStart = ''
      ${pkgs.bash}/bin/bash -c '
      while true; do
        if ! pgrep -x river >/dev/null 2>&1; then
          notify-send -u critical "River" "WM crashed, restarting..." || true
          sleep 2
          exec river
        fi
        sleep 10
      done
      '
    '';
    Restart = "on-failure";
    RestartSec = 5;
    StandardOutput = "journal";
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

**Impact:** WM crash detected and restarted automatically

---

### 8. Enhanced Network Resilience
**File:** `modules/system/networking.nix`

**Add to networking block:**
```nix
networking = {
  networkmanager = {
    enable = true;
    settings = {
      connectivity = {
        enabled = true;
        check-unavailable-seconds = 30;
      };
    };
  };
  
  nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" ];
  fallbackNameservers = [ "8.8.8.8" ];
  
  firewall = {
    enable = true;
    # ... existing ports ...
    allowedUDPPorts = [ 1194 ];  # Add UDP
  };
};
```

**Impact:** Network auto-reconnects, DNS fallback, UDP support

---

## 🟢 NICE-TO-HAVE (Weekend Project)

### 9. Create Health Check Script
**File:** `~/.local/bin/check-services.sh`

```bash
#!/usr/bin/env bash
SERVICES=("fnott" "wideriver" "kanshi" "gammastep" "bluetooth-monitor")
for s in "''${SERVICES[@]}"; do
  systemctl --user is-active "$s" >/dev/null 2>&1 || \
    systemctl --user restart "$s" || \
    notify-send "Service $s failed to restart"
done
```

Then add timer:
```nix
systemd.user.timers.health-check = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnBootSec = "10min";
    OnUnitActiveSec = "30min";
    Unit = "health-check.service";
  };
};

systemd.user.services.health-check = {
  description = "Check critical services";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash ~/.local/bin/check-services.sh";
  };
};
```

---

### 10. Improve Journal Logging
**File:** `modules/system/services.nix`

**Add to services block:**
```nix
services.journald.extraConfig = ''
  Storage=persistent
  Compress=yes
  MaxRetentionSec=30day
  MaxFileSec=1week
  RateLimitIntervalSec=0
  RateLimitBurst=0
'';
```

**Impact:** Logs persist across reboots, better debugging

---

## Testing Checklist

After implementing fixes:

- [ ] Rebuild: `sudo nixos-rebuild switch --flake .#laptop`
- [ ] Test fnott restart: `systemctl --user kill fnott && sleep 2 && systemctl --user is-active fnott`
- [ ] Test suspend/resume: `systemctl suspend`
- [ ] Check logs: `journalctl --user -u fnott -n 20`
- [ ] Verify wideriver restart: `systemctl --user kill wideriver && systemctl --user is-active wideriver`
- [ ] Check kanshi logs: `journalctl --user -u kanshi-monitor -n 20`

---

## Expected Results

**Before:** Grade B+ (Good with gaps)
- Services can crash silently
- No data protection
- Limited visibility into failures

**After:** Grade A- (Very Stable)
- Services auto-restart on crash
- Automatic backups running
- Full audit trail via journald
- 95%+ uptime under normal use

**Time Investment:** ~5-8 hours total
**Benefit:** Dramatically more reliable system

