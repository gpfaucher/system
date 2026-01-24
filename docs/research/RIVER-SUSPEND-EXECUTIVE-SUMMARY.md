# River WM Suspend/Resume Issue - Executive Summary

## Problem Statement

**Windows stop tiling after system suspend/resume** - Layout manager (wideriver) loses connection to River compositor.

## Root Cause

The **wideriver daemon** (responsible for window tiling) disconnects from River's IPC socket after suspend-resume cycle due to GPU/display state corruption. River process remains alive but becomes non-functional.

## Symptoms

- Windows float instead of tile
- Layout commands (Super+T, Super+M) don't work
- Multi-monitor configuration not restored
- Wideriver health check shows running but unresponsive
- Services still active but broken state

## Current Configuration Issues

1. **No systemd suspend hook** - River components not restarted automatically
2. **No health monitoring** - Wideriver crash/disconnect not detected
3. **No recovery mechanism** - Manual restart required
4. **TTY-based startup** - River not managed as service, exits = logout

## Configuration Locations

| File                                                        | Lines  | Purpose                      |
| ----------------------------------------------------------- | ------ | ---------------------------- |
| `/home/gabriel/projects/system/modules/home/river.nix`      | 9-223  | River init + wideriver spawn |
| `/home/gabriel/projects/system/modules/home/shell.nix`      | 22-25  | River startup on tty1        |
| `/home/gabriel/projects/system/modules/home/services.nix`   | 20-160 | Kanshi, display profiles     |
| `/home/gabriel/projects/system/modules/system/graphics.nix` | 1-43   | Hybrid GPU config            |

## Technical Deep Dive

### How Suspend Breaks Things

```
Pre-Suspend State:
  River ←—IPC—→ wideriver
         ↓
         GPU (AMD) / NVIDIA
         ↓
         Displays (ultrawide + portrait)

Suspend:
  System pauses, GPU clock-gated, display off-line

Resume:
  GPU wakes up, display re-initializes
  BUT: Wayland sockets may have stale state
       wideriver's file descriptors invalid
       IPC connection broken

Post-Resume State:
  River still running ←✗→ wideriver (disconnected)
        ↓ (zombie communication)
        GPU (state unclear)
        ↓
        Displays (not reconfigured)
```

### Why This Matters

- Wideriver is a **separate process** communicating via Wayland protocols
- Suspend interrupts all process I/O
- Wayland protocol state not properly reconstructed
- No built-in reconnection logic in River/wideriver

## Recommended Solution: Systemd Resume Hook

### What We'll Add

1. **Resume hook service** - Fires when system wakes from suspend
2. **Health monitor** - Checks wideriver connectivity every 45 seconds
3. **Manual recovery key** - Super+Ctrl+Shift+R to force refresh
4. **Display reload** - Re-apply Kanshi profiles after resume

### Benefits

✅ Automatic recovery (no manual restart needed)  
✅ Preserves window state (not full logout)  
✅ Handles edge cases (health monitor)  
✅ Declarative configuration (NixOS)  
✅ Non-disruptive (user sees notification only)

### Implementation Priority

- **Phase 1 (Quick):** Add resume hook to services.nix
- **Phase 2 (Robust):** Add health monitor to river.nix init script
- **Phase 3 (Polish):** Add manual recovery keybinding
- **Phase 4 (Testing):** Validate across suspend scenarios

## Code Changes Overview

### File 1: `modules/home/services.nix`

Add 15-20 lines: Resume hook service that runs `riverctl default-layout wideriver` after suspend.

### File 2: `modules/home/river.nix`

Add 5-10 lines: Health monitoring loop in autostart section (check wideriver every 45s).

### File 3: `modules/home/river.nix`

Add 3-4 lines: Manual recovery keybinding (Super+Ctrl+Shift+R).

### File 4: `modules/home/shell.nix`

Add 1 line: Sleep 0.5s before River startup (GPU initialization).

### File 5: `modules/system/graphics.nix` (Optional)

Add 1 line: Fine-grained NVIDIA power management.

**Total Changes:** ~40 lines across 4-5 files

## Testing Checklist

- [ ] Cold boot - verify tiling works normally
- [ ] Single suspend - wake up and check windows still tiled
- [ ] Multiple suspends - repeat 5x, verify recovery each time
- [ ] Multi-monitor - ultrawide + portrait layout preserved
- [ ] Manual key - Super+Ctrl+Shift+R forces refresh
- [ ] Services - all 10+ autostart services still running
- [ ] Display - display configuration properly restored
- [ ] Edge cases - suspend during layout changes, window moves, etc.

## Timeline & Effort

- **Analysis:** Done ✓
- **Implementation:** 1-2 hours
- **Testing:** 30 minutes
- **Documentation:** 15 minutes
- **Total:** ~2-3 hours

## Risk Assessment

| Risk                  | Likelihood | Impact | Mitigation                     |
| --------------------- | ---------- | ------ | ------------------------------ |
| Timing issues in hook | Medium     | Low    | Test delays, add logging       |
| GPU still not ready   | Low        | Low    | Increase sleep delay           |
| Services still broken | Low        | Low    | Add fallback health check      |
| User interruption     | Low        | Low    | Use low priority notifications |

## Next Steps

1. Create issue in beads task tracker
2. Implement Phase 1 (resume hook)
3. Test on current system
4. Add Phases 2-3
5. Document user recovery procedures
6. Consider upstream PR to River/wideriver

## References

- River documentation: https://codeberg.org/river/river
- wideriver: https://codeberg.org/novakane/wideriver
- wlroots suspend issues: Common pattern across all wlroots compositors
- NixOS systemd services: nixos.org/manual/nixos/unstable/#sec-systemd-user-services

---

**Research Date:** January 24, 2026  
**Analyzed By:** Research Agent  
**Status:** Ready for implementation
