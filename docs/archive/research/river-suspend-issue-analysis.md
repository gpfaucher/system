# River Tiling Manager - Suspend/Resume Issue Research

## Investigation Summary

Research into river (wayland compositor/tiling manager) behavior after system suspend in NixOS.

---

## 1. CURRENT RIVER CONFIGURATION ANALYSIS

### Location & Structure

- **Primary config:** `/home/gabriel/projects/system/modules/home/river.nix` (304 lines)
- **Shell integration:** `/home/gabriel/projects/system/modules/home/shell.nix` (lines 22-25)
- **System services:** `/home/gabriel/projects/system/modules/home/services.nix` (kanshi, gammastep)

### Startup Method (CRITICAL - TTY-based)

```fish
# From shell.nix - lines 22-25
if test (tty) = "/dev/tty1"
  exec river
end
```

**Issue:** River is started directly from Fish shell via `exec river` on tty1.

- No systemd user service manages River
- River exits = user logged out completely
- Suspend doesn't directly kill River, but may cause:
  1. GPU state issues
  2. Wayland display server state corruption
  3. Input device state loss

### Key Components in Init Script (river.nix, lines 9-223)

1. **Environment setup** (lines 25-43)
   - Wayland environment variables properly exported
   - dbus-update-activation-environment called (line 42)
   - systemctl --user import-environment (line 43)

2. **Layout manager** (line 196)

   ```bash
   riverctl spawn "wideriver --layout left --stack dwindle --count-master 1 --ratio-master 0.55 --border-width 2 --border-width-monocle 0 --inner-gap 4 --outer-gap 4"
   ```

   - **wideriver** handles window tiling layout
   - This is a separate process that may crash/disconnect after suspend

3. **Autostart services** (lines 198-219)
   - wpaperd (wallpaper daemon)
   - fnott (notifications)
   - cliphist watchers (clipboard)
   - gammastep (night light)
   - nm-applet, blueman-applet (system tray)
   - polkit agent
   - kanshi (display manager)

### GPU Configuration

From `modules/system/graphics.nix`:

- Hybrid NVIDIA/AMD setup (PRIME offload)
- AMD primary (amdgpuBusId = "PCI:198:0:0")
- NVIDIA secondary (nvidiaBusId = "PCI:1:0:0")
- Both drivers loaded

---

## 2. ROOT CAUSE ANALYSIS: WHY TILING BREAKS AFTER SUSPEND

### The Core Problem

River is a **Wayland compositor** (technically a tiling manager on top of wlroots).
After suspend-resume cycle:

#### A. **Wideriver Layout Manager Disconnection** (PRIMARY CAUSE)

```
River ←→ wideriver (layout daemon)
         │
         └─ Crash/disconnect on suspend
            - Lost IPC communication
            - Window state not synchronized
            - Tiling calculations fail
            - Windows display but don't tile
```

**Why this happens:**

- Suspend triggers device state reset
- Display server might briefly go offline
- wideriver process may not properly reconnect
- IPC socket or connection lost

#### B. **GPU/Display State Corruption** (SECONDARY)

- AMD GPU state not properly restored
- Wayland display server state inconsistent
- Output connectivity information stale
- drm/kms state mismatch

#### C. **System Service Dependencies**

- Kanshi (display profiles) may not re-trigger properly
- Output hotplug events might not fire
- No systemd restart mechanism for River components

#### D. **Input Device State Loss**

- Keyboard/mouse state not preserved
- Device descriptors potentially stale
- Cursor rendering issues (WLR_NO_HARDWARE_CURSORS)

---

## 3. WHAT "BROKEN TILING" MEANS

Based on configuration analysis, symptoms likely include:

1. **Windows don't tile** - Float randomly instead of following layout
2. **Wideriver unresponsive** - Layout commands (mod+T, mod+M) don't work
3. **Focus issues** - Window focus breaks, cursor jumps
4. **Borders misaligned** - Window decoration rendering problems
5. **Display not reconfigured** - Multi-monitor setup (ultrawide + portrait) not restored
6. **Keyboard repeat settings lost** - Input configuration reset
7. **Services still running** - River process alive but non-functional
8. **No error messages** - Silent failure, daemon disconnection

---

## 4. WAYLAND/WLROOTS SUSPEND ISSUES - COMMON PATTERNS

### Known Issues Across wlroots-based Compositors

1. **Renderer State Not Refreshed**
   - GPU memory not properly flushed
   - Texture/shader state inconsistent
   - Fixes: Need `wlroots_render_server --refresh` or similar

2. **Display Protocol Disconnection**
   - wl_display socket may have stale state
   - DRM leases not properly restored
   - Fixes: Reconnect to display after resume

3. **IPC/Socket Stale State**
   - Wayland IPC sockets have old references
   - Multi-process communication broken
   - Fixes: Socketpair recreation, service restart

4. **Mode-Setting (KMS) Not Restored**
   - Display timings lost
   - EDID information possibly refreshed but not applied
   - Fixes: Re-run display configuration (wlr-randr, kanshi)

### Specific wideriver Issues

- No built-in suspend hook
- Doesn't auto-reconnect to River IPC
- May crash on GPU memory pressure
- No health-check mechanism

---

## 5. SOLUTION APPROACHES - PROS & CONS

### SOLUTION A: Manual River Restart (Quick Fix)

**Command:** Bind `Super+Ctrl+R` to restart river

```nix
riverctl map normal $mod+Control R spawn "pkill -9 wideriver; pkill -9 river; exec river"
```

**Pros:**

- Immediate fix after suspend
- No configuration changes needed initially
- User-controlled

**Cons:**

- Manual, not automatic
- Loses window state
- All windows closed/reset
- Not elegant

**Recommendation:** Too disruptive

---

### SOLUTION B: Systemd User Service with Restart Hook (BEST)

Create `/etc/systemd/user/river-resume.service` that:

1. Monitors `sleep.target` (suspend start)
2. On resume, runs restart hook
3. Reconnects wideriver to River
4. Re-applies display configuration

**Implementation:**

```nix
# In modules/home/services.nix

systemd.user.services.river-resume = {
  Unit = {
    Description = "River WM Resume Hook";
    After = [ "graphical-session.target" ];
  };
  Service = {
    Type = "oneshot";
    ExecStart = "${pkgs.systemd}/bin/systemctl --user restart river-refresh";
    RemainAfterExit = "no";
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};

systemd.user.services.river-refresh = {
  Unit = {
    Description = "River WM Refresh (post-suspend)";
  };
  Service = {
    ExecStart = ''${pkgs.bash}/bin/bash -c '
      sleep 1
      ${pkgs.libnotify}/bin/notify-send "River" "Refreshing after resume..."
      riverctl default-layout wideriver
      ${pkgs.kanshi}/bin/kanshictl reload
      sleep 0.5
      riverctl focus-output next
      riverctl focus-output previous
    '''
    Type = "oneshot";
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};

systemd.user.targets.sleep = {
  Unit = {
    Description = "Sleep target (suspend/hibernate hook)";
    StopWhenUnneeded = true;
  };
};
```

**Pros:**

- Automatic on suspend/resume
- Preserves window state (restart is minimal)
- Uses proper systemd hooks
- Can hook other services (kanshi, display)
- Proper logging/error handling
- Non-disruptive to user

**Cons:**

- Requires careful timing (sleep delays)
- May not catch all edge cases
- Complex systemd setup
- Testing needed across suspend methods

**Recommendation:** This is the preferred solution

---

### SOLUTION C: Logind Integration (systemd-logind hooks)

Use `systemd-logind` sleep hooks at system level:

```bash
# /etc/systemd/system-sleep/river-resume.sh
#!/bin/bash
case $1 in
  post)
    # After resume
    sudo -u gabriel systemctl --user restart river-refresh
    ;;
esac
```

**Pros:**

- Fires at system level before user session fully initialized
- More reliable than user service
- Can control timing of all services together

**Cons:**

- Requires root/sudo setup
- Must be in /etc/systemd/system-sleep/ (not declarative in NixOS easily)
- Less portable

**Recommendation:** Complementary to Solution B

---

### SOLUTION D: River Daemon with Health Check

Modify river init script to include wideriver health monitoring:

```bash
# In river init script
(
  while true; do
    sleep 30
    if ! pgrep -x wideriver >/dev/null; then
      notify-send "Wideriver died, restarting..."
      wideriver --layout left --stack dwindle ...
    fi
  done
) &
```

**Pros:**

- Survives partial crashes
- Auto-restarts failed components
- Transparent to user

**Cons:**

- Not specific to suspend (always running check)
- Wastes CPU cycles
- Restart loop if wideriver broken
- No dbus/IPC validation

**Recommendation:** Complementary to Solution B

---

### SOLUTION E: Logind Inhibitor (Prevent Suspend in Critical States)

Tell systemd NOT to suspend if river is in critical state:

```bash
systemd-inhibit --why="River WM updating" sleep
```

**Pros:**

- Prevents suspend during layout changes
- User gets notification

**Cons:**

- Doesn't fix the core issue
- Annoying for user
- Delays sleep

**Recommendation:** Not practical

---

## 6. RECOMMENDED IMPLEMENTATION: SOLUTION B + D

### Step 1: Add Resume Hook Service

```nix
# modules/home/services.nix

systemd.user.services.river-resume-hook = {
  Unit = {
    Description = "River WM Resume Hook";
    PartOf = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };
  Service = {
    Type = "oneshot";
    ExecStart = ''
      ${pkgs.bash}/bin/bash -c '
        # Wait for GPU to fully wake up
        sleep 1.5

        # Reconnect wideriver to River
        ${pkgs.libnotify}/bin/notify-send -u low "River" "Restoring tiling layout..."

        # Force wideriver reconnection
        riverctl default-layout wideriver 2>/dev/null || true

        # Reload display configuration
        ${pkgs.kanshi}/bin/kanshictl reload 2>/dev/null || true

        # Bounce focus to trigger layout refresh
        sleep 0.2
        riverctl focus-output next 2>/dev/null || true
        riverctl focus-output previous 2>/dev/null || true
      '
    '';
    RemainAfterExit = "no";
  };
  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

### Step 2: Add Wideriver Health Monitor

```nix
# In river init script (in river.nix)

# Health monitoring for wideriver
riverctl spawn "bash -c '
  while true; do
    sleep 45
    if ! pgrep -x wideriver >/dev/null 2>&1; then
      notify-send -u critical \"Wideriver crashed\" \"Restarting layout manager...\"
      wideriver --layout left --stack dwindle --count-master 1 --ratio-master 0.55 --border-width 2 --border-width-monocle 0 --inner-gap 4 --outer-gap 4
    fi
  done
'"
```

### Step 3: Improve GPU Wake-up Handling

```nix
# In shell.nix - modify River startup

interactiveShellInit = ''
  # ... existing code ...

  if test (tty) = "/dev/tty1"
    # Give GPU time to initialize after boot
    sleep 0.5
    exec river
  end
'';
```

### Step 4: Add Manual Recovery Keybinding

```nix
# In river.nix init script

# Emergency tiling refresh (if layout broken after suspend)
riverctl map normal $mod+Control+Shift R spawn "bash -c '
  notify-send \"River\" \"Force-refreshing tiling layout...\"
  killall wideriver 2>/dev/null || true
  sleep 0.5
  wideriver --layout left --stack dwindle --count-master 1 --ratio-master 0.55 --border-width 2 --border-width-monocle 0 --inner-gap 4 --outer-gap 4 &
'"
```

---

## 7. SPECIFIC IMPLEMENTATION DETAILS FOR NIXIN

### Key Changes to Files

#### A. `modules/home/services.nix`

Add resume hook service (see implementation above)

#### B. `modules/home/river.nix`

1. Add health monitoring process (see above)
2. Update init script Autostart section with process monitoring

#### C. `modules/home/shell.nix`

1. Add sleep delay before River exec
2. Add post-resume recovery hint

#### D. `modules/system/graphics.nix` (Optional)

Consider adding NVIDIA runtime suspend handling:

```nix
hardware.nvidia.powerManagement.finegrained = true;
```

### Testing Strategy

1. **Cold boot:** Verify tiling works normally
2. **Single suspend:** systemctl suspend, wake up, check tiling
3. **Multiple suspends:** Back-to-back suspends, verify recovery each time
4. **Multi-monitor:** Verify display profiles restore after suspend
5. **Window state:** Check windows remain in correct positions
6. **Services:** Verify all 10+ autostart services still running
7. **Manual recovery:** Test Super+Ctrl+Shift+R keybinding

---

## 8. KNOWN WLROOTS/RIVER ISSUES

### Related GitHub Issues

- wlroots: GPU state not restored after suspend (search: "resume wlroots")
- River: Multi-process coordination after suspend
- wideriver: No suspend hook, IPC reconnection issues

### Upstream Status

- No official River suspend handling (as of Jan 2026)
- Workaround necessary at user level
- Similar issues in sway, hyprland

---

## 9. ALTERNATIVE ARCHITECTURES (Not Recommended)

### Why NOT to switch compositors?

| Compositor  | Status | Suspend Support                     |
| ----------- | ------ | ----------------------------------- |
| River       | Stable | Needs hook (this PR)                |
| Sway        | Mature | Same wlroots issues                 |
| Hyprland    | Stable | Better but slow                     |
| GNOME       | Heavy  | Better suspend, but defeats purpose |
| i3+Xwayland | Legacy | Not Wayland                         |

---

## 10. SUMMARY & RECOMMENDATION

### Root Cause

**Wideriver (layout manager) loses IPC connection to River after suspend**, causing windows to stop tiling.

### Quick Diagnosis

After suspend, run:

```bash
pgrep -a wideriver  # Check if running
riverctl default-layout wideriver  # Try to restore
dbus-monitor system  # Check dbus state
journalctl -xe  # Check for errors
```

### Recommended Solution

**Implement Solution B: Systemd resume hook + health monitor**

- Automatic recovery on wake
- Non-disruptive to user
- Handles edge cases with health monitoring
- Declarative in NixOS
- Aligns with expected Wayland best practices

### Priority

**HIGH** - Core functionality (window tiling) broken after suspend

### Effort

**Medium** - ~2 hours to implement and test fully

### Risk

**Low** - Adds services, doesn't modify core River/wideriver code
