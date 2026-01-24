# River WM Suspend/Resume Fix - Implementation Summary

**Date:** January 24, 2026  
**Status:** ✅ Implemented, Pending Testing  
**Priority:** P1 (Critical bug fix)  
**Related Issues:** system-eik, system-yoj

## Problem

Windows stop tiling after system suspend/resume. The wideriver layout manager loses its IPC connection to the River compositor after the system wakes from suspend, causing all windows to float instead of tile.

## Solution

Implemented a two-part systemd-based solution:

1. **User Service** (`river-resume-hook.service`) - Performs the actual layout restoration
2. **System Resume Hook** (`powerManagement.resumeCommands`) - Triggers the user service after resume

## Implementation Details

### Files Modified

#### 1. `modules/home/services.nix`

Added `systemd.user.services.river-resume-hook`:

- **Type:** oneshot service
- **Trigger:** Part of graphical-session.target, called by system resume hook
- **Actions:**
  1. Sleep 1.5s for GPU initialization
  2. Send notification ("Restoring tiling layout...")
  3. Reconnect wideriver: `riverctl default-layout wideriver`
  4. Reload Kanshi display profiles: `kanshictl reload`
  5. Trigger layout refresh by bouncing focus between outputs

#### 2. `modules/system/services.nix`

Added `powerManagement.resumeCommands`:

- Triggers the user service after system resume
- Uses `systemctl --user -M gabriel@ start river-resume-hook.service`
- Suppresses errors with `|| true` for robustness

## Technical Approach

### Why This Works

1. **GPU Initialization Delay:** The 1.5s sleep ensures the GPU is fully awake before attempting to reconnect
2. **IPC Reconnection:** `riverctl default-layout wideriver` forces River to re-establish its IPC connection with wideriver
3. **Display Configuration:** `kanshictl reload` ensures multi-monitor setups are properly restored
4. **Layout Refresh:** Focus bouncing triggers River to recalculate window layouts
5. **User Notification:** Low-priority notification informs user without interrupting workflow

### Architecture

```
System Resume
    ↓
powerManagement.resumeCommands (system-level)
    ↓
systemctl --user start river-resume-hook.service
    ↓
User Service Runs:
    - GPU initialization wait (1.5s)
    - Notification
    - riverctl default-layout wideriver
    - kanshictl reload
    - Focus output bounce
    ↓
River tiling restored ✓
```

## Testing Procedure

### Build and Apply

```bash
sudo nixos-rebuild switch --flake .#laptop
```

### Manual Service Test

```bash
# Check service exists
systemctl --user list-unit-files | grep river-resume-hook

# Manually trigger the service
systemctl --user start river-resume-hook.service

# Check for notification and verify tiling still works
```

### Suspend/Resume Test

```bash
# Suspend the system
systemctl suspend

# After waking:
# 1. Look for "Restoring tiling layout..." notification
# 2. Verify existing windows are still tiled
# 3. Open new windows: Super+Return (terminal)
# 4. Test layout switching: Super+T (tile), Super+M (monocle)
# 5. Test multi-monitor: Super+, and Super+. (switch outputs)

# View service logs
journalctl --user -u river-resume-hook -n 20
```

### Comprehensive Testing

Run the provided test script:

```bash
./test-river-resume.sh
```

Test scenarios:

- [ ] Single suspend/resume cycle
- [ ] Multiple suspend cycles (3-5 times)
- [ ] Suspend with multiple windows open
- [ ] Suspend with multi-monitor setup
- [ ] Suspend during window layout changes
- [ ] Long suspend (30+ minutes)

## Expected Behavior

### Before Fix

- Windows float after resume
- Layout commands (Super+T, Super+M) don't work
- Manual River restart required: `pkill river && exec river`
- Full session logout/login needed

### After Fix

- Windows remain tiled after resume
- Low-priority notification appears: "River - Restoring tiling layout..."
- All layout commands work immediately
- Multi-monitor configuration restored
- No manual intervention required

## Troubleshooting

### Service Not Running

```bash
# Check service status
systemctl --user status river-resume-hook

# View logs
journalctl --user -u river-resume-hook

# Manually enable if needed
systemctl --user enable river-resume-hook
```

### Layout Still Broken After Resume

```bash
# Check if wideriver is running
pgrep -a wideriver

# Manually trigger the fix
systemctl --user start river-resume-hook.service

# If still broken, check River/wideriver logs
journalctl --user -u river-session -n 50
```

### No Notification Appears

```bash
# Verify fnott notification daemon is running
pgrep -a fnott

# Test notifications
notify-send "Test" "This is a test"

# Check service logs for errors
journalctl --user -u river-resume-hook -n 20
```

## Future Improvements (Optional Phases)

### Phase 2: Health Monitor

Add a background process that monitors wideriver connectivity every 45 seconds and automatically restarts if crashed.

**Location:** `modules/home/river.nix` autostart section

### Phase 3: Manual Recovery Keybinding

Add emergency tiling refresh keybinding: `Super+Ctrl+Shift+R`

**Location:** `modules/home/river.nix` keybindings section

### Phase 4: GPU Wake-up Delay

Add small delay before River startup on cold boot.

**Location:** `modules/home/shell.nix` River startup section

### Phase 5: Fine-Grained NVIDIA Power Management

Enable better suspend/resume handling for NVIDIA GPUs.

**Location:** `modules/system/graphics.nix`

## Performance Impact

- **Resume delay:** +1.5 seconds (for GPU initialization)
- **CPU overhead:** Negligible (oneshot service)
- **Memory overhead:** None (no persistent process)
- **User experience:** Transparent (low-priority notification only)

## References

- Implementation Guide: `docs/research/RIVER-SUSPEND-IMPLEMENTATION-GUIDE.md`
- Executive Summary: `docs/research/RIVER-SUSPEND-EXECUTIVE-SUMMARY.md`
- Related Issues: system-eik (bug report), system-yoj (implementation task)
- River Documentation: https://codeberg.org/river/river
- wideriver Documentation: https://codeberg.org/novakane/wideriver
- NixOS systemd services: https://nixos.org/manual/nixos/unstable/#sec-systemd-user-services

## Rollback Instructions

If issues occur:

```bash
# Revert changes
git checkout modules/home/services.nix modules/system/services.nix

# Rebuild
sudo nixos-rebuild switch --flake .#laptop

# Restart River session (logout/login)
```

## Success Criteria

- ✅ Service builds without errors
- ✅ Service starts successfully
- ✅ Notification appears after manual trigger
- ⏳ Tiling works after suspend/resume (PENDING TEST)
- ⏳ Multi-monitor config restored after resume (PENDING TEST)
- ⏳ No errors in service logs (PENDING TEST)
- ⏳ Consistent behavior across multiple suspend cycles (PENDING TEST)

## Notes

- This implementation follows the NixOS declarative approach
- All package paths are properly referenced using `${pkgs.package}`
- Error suppression (`2>/dev/null || true`) prevents service failures from blocking resume
- The solution is non-invasive and can be easily disabled or removed
- No upstream River/wideriver changes required

---

**Implementation By:** nix-specialist agent  
**Based On:** Research by research agent (docs/research/RIVER-SUSPEND-\*.md)  
**Next Step:** User testing and validation
