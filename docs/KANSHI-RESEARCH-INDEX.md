# Kanshi Configuration Research - Index & Navigation

**Research Completed**: January 24, 2026  
**Investigation Status**: ✅ COMPLETE  
**Documentation**: Ready for use and implementation

---

## Quick Navigation

### 📋 For Quick Reference
- **File**: This document (you are here)
- **Best for**: Quick lookup, command reference, understanding what was found

### 📚 For Comprehensive Details
- **File**: `kanshi-configuration-research.md`
- **Size**: 377 lines, 9.9KB
- **Best for**: Complete understanding, detailed configuration format, all profiles

### 🎯 For Implementation
- **File**: `kanshi-configuration-research.md` - Section 8
- **Content**: Step-by-step process to update the configuration

---

## Investigation Summary

### All 6 Tasks Completed ✓

#### Task 1: Configuration File Location ✓
**Answer**: Home-manager managed Nix configuration with generated kanshi config
- Primary file: `~/.config/kanshi/config` (symlink)
- Source code: `/home/gabriel/projects/system/modules/home/services.nix` (lines 19-160)
- Type: Declarative Nix that generates kanshi config

#### Task 2: Profile/Layout Structure ✓
**Answer**: 7 profile-based configurations, auto-selected by connected outputs
- Architecture: Profile-based (not per-monitor layouts)
- Profiles: 7 different configurations covering all scenarios
- Selection: Automatic matching when outputs connect/disconnect
- Default: dual-portrait-ultrawide (current)

#### Task 3: Monitor Detection Methods ✓
**Answer**: Two primary tools available
- `wlr-randr`: Full hardware detection (modes, resolutions, refresh rates)
- `kanshictl status`: Current profile and settings (JSON)
- `kanshictl reload`: Hot-reload configuration without restart

#### Task 4: Current Monitors ✓
**Answer**: Two external monitors + disabled laptop display
```
HDMI-A-1  : Microstep MSI MAG342CQR (3440x1440@100Hz ultrawide)
DP-2      : Microstep G272QPF E2 (2560x1440@60Hz rotated 90°)
eDP-1     : BOE 0x0B22 (disabled - laptop display)
```
**Active Profile**: `dual-portrait-ultrawide` (the "home monitor setup")

#### Task 5: Configuration Format ✓
**Answer**: Nix home-manager format (source) → kanshi config format (generated)

**Nix Format** (source of truth):
```nix
services.kanshi = {
  settings = [
    {
      profile.name = "name";
      profile.outputs = [ { criteria = "OUTPUT"; status = "enable"; ... } ];
      profile.exec = [ "command" ];
    }
  ];
};
```

**Kanshi Format** (generated):
```
profile name {
  output OUTPUT enable mode 3440x1440@100Hz position 0,0 scale 1.0
}
```

#### Task 6: Helper Tools ✓
**Answer**: Multiple tools for detection, control, and management
- `kanshi`: Main daemon process
- `kanshictl`: Control utility (status/reload/switch)
- `wlr-randr`: Monitor hardware detection
- River WM binding: Super+Ctrl+M mapped to kanshictl reload

---

## Current Setup: dual-portrait-ultrawide

### Hardware Configuration
```
HDMI-A-1 (enabled)
├── Manufacturer: Microstep
├── Model: MSI MAG342CQR
├── Serial: DB6H261C02187
├── Mode: 3440x1440@100Hz
├── Position: (0, 0)
├── Scale: 1.0
└── Transform: normal

DP-2 (enabled)
├── Manufacturer: Microstep
├── Model: G272QPF E2
├── Serial: 0x01010101
├── Mode: 2560x1440@60Hz
├── Position: (3440, 0)
├── Scale: 1.0
└── Transform: 90° (portrait)

eDP-1 (disabled)
├── Manufacturer: BOE
├── Model: 0x0B22
└── Status: DISABLED
```

### Visual Layout
```
┌─────────────────────────────────┐┌──────────┐
│     HDMI-A-1                    ││   DP-2   │
│   3440x1440@100Hz               ││ Rotated  │
│   at (0,0)                      ││ 90°      │
│                                 ││          │
│  ========= 3440 px ===========  ││ 2560 px  │
│                                 ││          │
└─────────────────────────────────┘└──────────┘
         1440 px height                1440px
```

---

## All Available Profiles

1. **dual-portrait-ultrawide** ← CURRENT
   - HDMI ultrawide (3440x1440) + DP portrait (2560x1440@90°)
   - Laptop disabled
   - Use case: Primary home desk setup

2. **laptop**
   - Laptop display only (3840x2400@60Hz)
   - Use case: Mobile/unplugged work

3. **docked-dp**
   - DP ultrawide only (3440x1440@100Hz)
   - Use case: Connected to DP dock, laptop closed

4. **docked-hdmi**
   - HDMI ultrawide only (3440x1440@100Hz)
   - Use case: Connected to HDMI dock, laptop closed

5. **docked-dual**
   - DP ultrawide + laptop display
   - Use case: Laptop visible alongside external monitor

6. **presentation-hdmi**
   - Laptop (3840x2400) + any HDMI display
   - Use case: Presentations with external projector/monitor

7. **presentation-dp**
   - Laptop (3840x2400) + any DP display
   - Use case: Presentations with external projector/monitor

---

## How to Update Configuration

### Option A: Permanent (Home Manager) ← RECOMMENDED

```bash
# 1. Edit home-manager config
nano /home/gabriel/projects/system/modules/home/services.nix

# 2. Modify services.kanshi.settings array (lines 23-159)
# 3. Save file

# 4. Rebuild and apply
cd /home/gabriel/projects/system
home-manager switch

# 5. Verify
kanshictl status
wlr-randr
```

### Option B: Temporary (Direct Config)

```bash
# 1. Edit config directly (for testing only)
nano ~/.config/kanshi/config

# 2. Reload without restart
kanshictl reload

# 3. Test the changes
wlr-randr

# ⚠️ WARNING: Changes will be overwritten by next home-manager rebuild
```

---

## Command Reference

### Detection
```bash
wlr-randr                          # See all monitors and modes
```

### Status
```bash
kanshictl status                   # Current profile (JSON)
cat ~/.config/kanshi/config        # All profiles
```

### Control
```bash
kanshictl reload                   # Hot-reload config
kanshictl switch <profile>         # Switch to profile
```

### Management
```bash
systemctl restart --user kanshi    # Restart kanshi daemon
journalctl --user -u kanshi -f     # View logs
```

---

## Configuration File Format Details

### Output Criteria (how to identify a monitor)

**By Name** (depends on kernel probe order):
```
HDMI-A-1
DP-2
eDP-1
```

**By Description** (recommended for stability):
```
"Microstep MSI MAG342CQR DB6H261C02187"
"Microstep G272QPF E2 0x01010101"
```

**By Wildcard** (for variable connections):
```
HDMI-A-*    # Any HDMI connector
DP-*        # Any DisplayPort
*           # Any single output
```

### Output Directives (how to configure a monitor)

```
enable                              # Turn on output
disable                             # Turn off output

mode 3440x1440@100Hz               # Resolution and refresh rate
mode 2560x1440                     # Resolution only (preferred frequency)
mode --custom 1920x1440@60Hz       # Custom mode (if needed)

position 0,0                        # X,Y coordinates
position 3440,0                     # Place to right of previous monitor

scale 1.0                           # 100% scaling (1.0)
scale 2.0                           # 200% scaling for HiDPI

transform 90                        # Rotate 90° clockwise
transform 180                       # Rotate 180°
transform 270                       # Rotate 270° clockwise
transform flipped                   # Flip horizontally
transform flipped-90                # Flip + rotate
transform normal                    # No transform

adaptive_sync on|off                # Variable refresh rate (G-Sync, FreeSync)
```

---

## Position Calculation Guide

### Global Coordinate System
- Origin (0,0) is top-left
- X increases to the right
- Y increases downward
- All positions in pixels

### Side-by-Side Layout
```
Monitor 2 position X = Monitor 1 X + Monitor 1 Width

Example:
  Monitor 1 (HDMI): position 0,0, width 3440
  Monitor 2 (DP):   position 0+3440,0 = (3440,0)
```

### Stacked Layout
```
Monitor 2 position Y = Monitor 1 Y + Monitor 1 Height

Example:
  Monitor 1 (Top):    position 0,0, height 1440
  Monitor 2 (Bottom): position 0,0+1440 = (0,1440)
```

---

## Documentation Structure

### File: kanshi-configuration-research.md

#### Section 1: Configuration File Locations
- Where kanshi config is stored
- Home-manager source code location
- Systemd service files

#### Section 2: Current Monitor Setup
- Active profile details
- Connected hardware specifications
- Monitor identification methods

#### Section 3: Configuration File Format
- File location and structure
- Output criteria options
- Output directives syntax

#### Section 4: Current Kanshi Profiles
- All 7 profiles documented
- Each profile's exact configuration
- Use cases for each profile

#### Section 5: How Kanshi Works
- Profile activation logic
- Matching rules and order
- Wildcard behavior

#### Section 6: Monitor Detection Tools
- wlr-randr command and output
- kanshictl commands and options
- Manual configuration inspection

#### Section 7: How to Update Kanshi
- Home Manager method (permanent)
- Direct config method (temporary)
- Build and switch commands

#### Section 8: Step-by-Step Process
- Prerequisites and verification
- Creating a new profile
- Testing and applying changes

#### Section 9: Helper Tools
- Available commands
- Integration with River WM
- Systemd integration

#### Section 10: Quick Reference Commands
- All common commands listed
- Usage examples for each

#### Section 11: Key Takeaways
- Summary of important concepts
- Configuration best practices

---

## Implementation Checklist

- [ ] Read this document for overview
- [ ] Review `kanshi-configuration-research.md` for details
- [ ] Run `wlr-randr` to check current monitors
- [ ] Run `kanshictl status` to verify active profile
- [ ] Identify desired monitor configuration
- [ ] Edit `/home/gabriel/projects/system/modules/home/services.nix`
- [ ] Add new profile or modify existing one
- [ ] Run `home-manager switch` to apply
- [ ] Verify with `kanshictl status` and `wlr-randr`
- [ ] Test all available profiles with `kanshictl switch <name>`

---

## Troubleshooting

### Profile doesn't activate automatically
- Check with `wlr-randr` that all outputs in profile are connected
- Remember: ALL outputs in profile must be connected for activation
- Check profile order (first match wins)

### Position incorrect after setting
- Verify with `wlr-randr` - actual position may differ from config due to transforms
- Rotation applied AFTER position set
- Position is in pixel coordinates of unrotated display

### Changes not applying after edit
- Use `kanshictl reload` instead of restarting
- For home-manager changes: run `home-manager switch`
- Check logs: `journalctl --user -u kanshi -f`

### Output name changes between boots
- Use output description instead of name
- Format: "Manufacturer Model Serial"
- More stable across reboots

---

## Contact & References

- **Configuration Source**: `/home/gabriel/projects/system/modules/home/services.nix`
- **Service File**: `~/.config/systemd/user/kanshi.service`
- **Active Config**: `~/.config/kanshi/config`
- **Research Docs**: `/home/gabriel/projects/system/docs/kanshi-configuration-research.md`

---

**Research Quality**: ✅ Complete
**Documentation**: ✅ Comprehensive
**Ready for**: Implementation and configuration updates
