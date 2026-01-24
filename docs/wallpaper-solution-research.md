# Wallpaper Solutions for Multi-Monitor Wayland Setup - Research Report

**Research Date**: January 24, 2026  
**Target Setup**:
- Laptop only: 3840x2400 (high-DPI, scaled 2x)
- Single ultrawide: 3440x1440 (21:9 aspect)
- Ultrawide + vertical: 3440x1440 + 2560x1440 rotated 90°
- Window Manager: River WM (Wayland, wlroots-based)
- Display Manager: Kanshi (display profile switching)

---

## 1. WALLPAPER DAEMON COMPARISON

### Overview Matrix

| Daemon | Per-Output | Animated | Transitions | Runtime Control | River Compatible | Setup Complexity |
|--------|-----------|----------|-------------|-----------------|------------------|------------------|
| **swaybg** | ❌ Single only | ❌ No | ❌ No | ❌ No | ✅ Yes | ⭐ Minimal |
| **swww** | ✅ Yes | ✅ Yes (GIF) | ✅ 12+ types | ✅ IPC | ✅ Yes | ⭐⭐⭐ Medium |
| **wpaperd** | ✅ Yes | ✅ Yes | ✅ 50+ types | ✅ IPC/CLI | ✅ Yes | ⭐⭐⭐ Medium |
| **hyprpaper** | ✅ Yes | ❌ No | ❌ No | ✅ IPC | ⚠️ Works* | ⭐⭐ Simple |

### Detailed Analysis

#### **swaybg** (Current setup)
**Status**: Actively maintained (last release Apr 2024)  
**Architecture**: Simple, single-process, no daemon mode  
**Pros**:
- Extremely lightweight (pure C, minimal dependencies)
- Stable and proven in River ecosystem (you're already using it)
- Works universally on wlroots compositors
- Zero CPU usage when idle

**Cons**:
- ❌ Cannot set different wallpapers per monitor (only solid color or single image)
- ❌ No animated wallpaper support
- ❌ Cannot change wallpaper at runtime without restarting
- ❌ No integration with display profile changes

**Current Usage**: `riverctl spawn "swaybg -c '#282828'"` (solid color only)

#### **swww** (Now archived as "awww")
**Status**: Archived Oct 2025, moved to `awww` on Codeberg as LGFae/awww  
**Architecture**: Daemon + client (Rust)  
**Pros**:
- ✅ Per-output wallpaper support
- ✅ Smooth animated transitions (12+ types)
- ✅ Runtime wallpaper changes via IPC
- ✅ Works on River (wlroots-based)
- ✅ Lower CPU/memory than `oguri`
- GPU-accelerated transitions

**Cons**:
- Project archived (though still functional)
- Requires daemon management
- More complex configuration
- Less active development

**Recommendation**: Not ideal for long-term use due to archive status.

#### **wpaperd** ⭐ **RECOMMENDED**
**Status**: Actively maintained (last release May 2025)  
**Architecture**: Daemon + CLI tool (Rust)  
**Pros**:
- ✅ **Per-output wallpapers** (different image per monitor)
- ✅ **Hot config reloading** (no restart needed)
- ✅ **Directory-based wallpaper cycling** (random/ascending/descending)
- ✅ **Smooth GPU-accelerated transitions** (50+ transition types)
- ✅ **Flexible TOML config** (regex pattern matching for outputs)
- ✅ **IPC + CLI control** (`wpaperctl`)
- ✅ **Exec hooks** (run scripts on wallpaper change)
- ✅ Works flawlessly on River
- Low resource usage (OpenGL ES rendering)
- Excellent for multi-monitor setups with different aspect ratios

**Cons**:
- Requires Mesa/OpenGL ES
- Slightly more complex TOML config
- Less feature-rich than swww but more stable

**Configuration Approach**:
```toml
[default]
duration = "30m"
mode = "cover"
transition-time = 500

[any]
path = "/home/gabriel/Wallpapers/default.png"

# Ultrawide monitor (21:9 aspect ratio)
["HDMI-A-1"]
path = "/home/gabriel/Wallpapers/ultrawide"
duration = "5m"
sorting = "random"
mode = "cover"

# Vertical monitor (portrait, 9:16 aspect)
["DP-2"]
path = "/home/gabriel/Wallpapers/portrait"
duration = "5m"
mode = "center"  # Better for portrait mode
sorting = "random"

# Laptop display (high DPI, 16:10 aspect)
["eDP-1"]
path = "/home/gabriel/Wallpapers/laptop"
mode = "cover"
```

#### **hyprpaper**
**Status**: Actively maintained (Hyprland-specific, last release Jan 2026)  
**Architecture**: Daemon (C++)  
**Pros**:
- ✅ Per-output support
- ✅ IPC control
- Modern codebase

**Cons**:
- ⚠️ **Designed for Hyprland** (may have River compatibility issues)
- No animations
- Less flexible configuration
- Overkill for River

**Verdict**: Not recommended for River setup.

---

## 2. RECOMMENDED SOLUTION: wpaperd

### Why wpaperd for Your Setup

1. **Multi-Monitor Excellence**: Each output gets its own config section
   - Ultrawide: Use high-resolution images, `cover` mode
   - Vertical: Use portrait-oriented images, `center` mode
   - Laptop: Use full-screen images with 2x scaling

2. **Aspect Ratio Handling**:
   - `cover` mode: Scales to cover entire display (good for ultrawide)
   - `center` mode: Centers image without stretching (good for portrait)
   - `fit` mode: Maintains aspect ratio with letterboxing
   - `stretch` mode: Fills entire display (distorts aspect ratio)

3. **Display Profile Integration**:
   - Use kanshi's `exec` hook to reload wpaperd config
   - Different wallpaper sets per profile
   - Smooth transitions between profiles

4. **Scalability**:
   - 50+ transition types (more than swww's 12+)
   - Recursive directory scanning
   - Group-based sharing for synchronized random cycling

---

## 3. KANSHI + WPAPERD INTEGRATION

### Display Profile Switching Workflow

When you change display profiles (laptop → ultrawide → dual), you want wallpapers to update automatically.

**Current kanshi setup** (in `/modules/home/services.nix`):
- `dual-portrait-ultrawide`: HDMI-A-1 (3440x1440) + DP-2 (2560x1440 rotated)
- `docked-dp`: DP-2 only (3440x1440)
- `docked-hdmi`: HDMI-A-1 only (3440x1440)
- `laptop`: eDP-1 only (3840x2400)

### Integration Strategy

**Option A: Single wpaperd config with all output patterns**

```toml
# ~/.config/wpaperd/config.toml
[default]
duration = "30m"
sorting = "random"
mode = "cover"
transition-time = 500

# When both monitors present
["HDMI-A-1"]
path = "/home/gabriel/Wallpapers/ultrawide"

["DP-2"]
path = "/home/gabriel/Wallpapers/portrait"

# When single ultrawide
# (HDMI-A-1 config above applies)

# When laptop only
["eDP-1"]
path = "/home/gabriel/Wallpapers/laptop"
mode = "cover"
```

wpaperd automatically adapts to connected outputs—no restart needed!

**Option B: Profile-specific configs with kanshi exec hooks**

```nix
# In kanshi profile exec:
profile.exec = [
  "${pkgs.libnotify}/bin/notify-send 'Display changed'"
  "wpaperctl resume"  # Resume cycling if paused
];
```

### Kanshi Configuration Update

Add to `/modules/home/services.nix` kanshi profiles:

```nix
{
  profile.name = "dual-portrait-ultrawide";
  profile.outputs = [ /* existing config */ ];
  profile.exec = [
    "${pkgs.libnotify}/bin/notify-send 'Wallpapers' 'Ultrawide + Portrait'"
    # wpaperd automatically detects output changes
  ];
}
```

---

## 4. NIXER/HOME-MANAGER INTEGRATION

### Installation

```nix
# modules/home/wallpaper.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    wpaperd
  ];

  systemd.user.services.wpaperd = {
    Unit = {
      Description = "Wallpaper daemon for Wayland";
      After = [ "graphical-session-target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wpaperd}/bin/wpaperd";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."wpaperd/config.toml".text = ''
    [default]
    duration = "30m"
    sorting = "random"
    mode = "cover"
    transition-time = 500

    [any]
    path = "${config.home.homeDirectory}/Wallpapers/default.png"

    ["HDMI-A-1"]
    path = "${config.home.homeDirectory}/Wallpapers/ultrawide"
    duration = "5m"

    ["DP-2"]
    path = "${config.home.homeDirectory}/Wallpapers/portrait"
    mode = "center"
    duration = "5m"

    ["eDP-1"]
    path = "${config.home.homeDirectory}/Wallpapers/laptop"
  '';
}
```

### Enable in home-manager config

```nix
# Include new module in modules/home/default.nix
imports = [
  ./wallpaper.nix
  ./river.nix
  ./services.nix
  # ... other modules
];
```

### Update river.nix

Replace `swaybg` line:

```nix
# OLD (line 203-204):
# riverctl spawn "swaybg -c '#282828'"

# NEW: Let wpaperd handle wallpapers
# (wpaperd is started via systemd service above)
```

Also update river package list:

```nix
home.packages = with pkgs; [
  river-classic
  wideriver
  # Remove: swaybg # (now managed by wpaperd)
  # Add:
  wpaperd
  # ... rest of packages
];
```

---

## 5. ULTRAWIDE + VERTICAL MONITOR CONSIDERATIONS

### Aspect Ratio Handling

#### Ultrawide (3440x1440 = 21:9)
- **Recommended mode**: `cover` (fills display, may crop image)
- **Image type**: Ultrawide-native images (21:9 aspect)
- **Alternative sources**:
  - Unsplash: Filter by ultrawide resolution
  - WallpaperEngine: Ultrawide collections
  - Custom tiling of 16:9 images

#### Vertical Portrait (2560x1440 rotated = 9:16 after rotation)
- **Recommended mode**: `center` (keeps aspect, black bars acceptable)
- **Image type**: Portrait-oriented (9:16 aspect)
- **Alternative sources**:
  - Rotate standard images 90°
  - Smartphone wallpaper collections (native 9:16)
  - Custom portrait art

#### Laptop (3840x2400 = 8:5 @ 2x scale)
- **Recommended mode**: `cover`
- **Image type**: Square-ish or 16:10 aspect (native to laptop)
- **Note**: 2x scaling = 1920x1200 effective resolution

### Directory Structure Recommendation

```bash
~/Wallpapers/
├── ultrawide/          # 3440x1440 images (21:9 aspect)
│   ├── space_01.png
│   ├── space_02.png
│   └── ...
├── portrait/           # 1440x2560 images (9:16 rotated)
│   ├── art_01.png
│   └── ...
├── laptop/             # 1920x1200 images (16:10 aspect)
│   ├── bg_01.png
│   └── ...
└── default.png         # Fallback image
```

### Spanning vs. Per-Monitor

**Current Recommendation**: **Per-monitor wallpapers** (what wpaperd excels at)

**Why not spanning**:
- 21:9 ultrawide + 9:16 portrait cannot create meaningful continuous image
- Different aspect ratios make spanning impractical
- Independent wallpapers better utilize monitor real estate
- Easier to find quality images individually

---

## 6. TRANSITION EFFECTS FOR WPAPERD

### Best Transitions by Mode

**For cycles (changing wallpapers every 5-30 min)**:
- `fade` (300ms) - Smooth, subtle
- `dissolve` (1000ms) - Slightly more interesting
- `directional` (1000ms) - Wipe direction

**For profile changes (when monitors change)**:
- `simple-zoom` (1500ms) - Nice when reconfiguring
- `circle-crop` (3000ms) - Professional-looking

**Example config**:

```toml
[default.transition.fade]
# Default settings, 300ms

["HDMI-A-1".transition.directional]
# 1000ms directional wipe

["DP-2".transition.fade]
# Subtle fade for portrait
```

---

## 7. CURRENT SETUP MIGRATION PLAN

### Step-by-Step

1. **Create wallpaper directories**:
   ```bash
   mkdir -p ~/Wallpapers/{ultrawide,portrait,laptop}
   ```

2. **Add sample wallpapers** (find 21:9, portrait, 16:10 images)

3. **Create `/modules/home/wallpaper.nix`** (Nix config above)

4. **Update `/modules/home/default.nix`** to import wallpaper module

5. **Remove swaybg from river.nix** line 203-204

6. **Update river.nix packages** to include wpaperd and remove swaybg

7. **Rebuild**:
   ```bash
   home-manager switch
   systemctl --user restart wpaperd
   ```

8. **Verify**:
   ```bash
   wpaperctl query                 # Check status
   wpaperctl next                  # Test wallpaper cycling
   ```

---

## 8. RUNTIME CONTROL

### wpaperd CLI (wpaperctl)

```bash
# Query current wallpapers
wpaperctl query

# Cycle to next wallpaper
wpaperctl next

# Cycle to previous
wpaperctl previous

# Pause/resume auto-switching
wpaperctl pause
wpaperctl resume
wpaperctl toggle-pause

# Set specific output wallpaper (if needed)
wpaperctl next -o HDMI-A-1

# Restart daemon
systemctl --user restart wpaperd
```

### Kanshi Integration

Optionally add kanshi profile-change hook:

```bash
# When display profile changes, wpaperd automatically adapts
# No additional configuration needed!
```

---

## 9. COMPARISON: WHY NOT OTHER OPTIONS

### Why not swaybg (current)?
- Single wallpaper only (cannot differentiate per-monitor)
- No cycling/animation support
- Static setup (changes require restart)
- Limited for advanced multi-monitor scenarios

### Why not swww?
- Project archived (risky long-term)
- Migration plan would be complex
- wpaperd has more transition types anyway

### Why not hyprpaper?
- Hyprland-specific design
- No animations
- Less flexible than wpaperd
- Over-engineered for River use case

### Why not custom scripts?
- Reinventing the wheel (buggy, unmaintained)
- More complex than using battle-tested daemon
- Performance overhead
- Difficult to integrate with Kanshi

---

## 10. CONCLUSION & RECOMMENDATIONS

### **Verdict: Use wpaperd**

**Primary Recommendation**:
1. ✅ Replace swaybg with wpaperd
2. ✅ Create per-output wallpaper directories
3. ✅ Configure via TOML (flexible, hot-reloadable)
4. ✅ Leverage kanshi for automatic profile detection
5. ✅ Manage via systemd user service

**Benefits for Your Setup**:
- Different wallpapers for ultrawide vs. portrait vs. laptop
- Smart aspect ratio handling per monitor
- Smooth 50+ transition effects
- Runtime control (change at any time)
- Automatic display profile adaptation
- Low CPU/memory footprint
- Active development & stable
- NixOS/home-manager friendly

**Timeline**:
- Setup: ~30 minutes
- Testing: ~10 minutes
- Integration: ~5 minutes
- **Total**: ~45 minutes

**Files to Modify**:
1. Create: `/modules/home/wallpaper.nix`
2. Update: `/modules/home/default.nix` (add import)
3. Update: `/modules/home/river.nix` (remove swaybg line 203-204)
4. Create: `~/Wallpapers/{ultrawide,portrait,laptop}/` directories
5. Add sample wallpapers to directories

**Next Steps**:
1. Research and collect wallpapers (21:9 ultrawide, portrait, etc.)
2. Implement Nix configuration
3. Test with current display setup
4. Test with different kanshi profiles (laptop → dual → single)
5. Fine-tune transition timings and cycling durations
