# Blue Light Filter Quick Reference

## TL;DR

**Current Setup**: ✅ Optimal  
**Tool**: Gammastep (Wayland-native fork of Redshift)  
**Location**: Amsterdam (52.37, 4.90)  
**Day Temp**: 6500K | **Night Temp**: 3500K  
**Status**: Production-ready, no changes needed

---

## Current Configuration

### Services (modules/home/services.nix lines 162-178)

```nix
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
```

### River Integration (river.nix line 209)

```bash
riverctl spawn gammastep
```

### Packages (river.nix line 281)

```nix
gammastep
```

---

## Common Commands

```bash
# Check status
systemctl --user status gammastep

# Manually set temperature
gammastep -O 3500  # Night mode (warm)
gammastep -O 6500  # Day mode (cool)

# Reset to normal
gammastep -x

# View current settings
gammastep -p

# Verbose output
gammastep -t 6500:3500 -l manual 52.37:4.90 -v

# Restart service
systemctl --user restart gammastep

# View logs
journalctl --user -u gammastep -f
```

---

## Why Gammastep Over Alternatives

| Feature           | Gammastep | wlsunset    | wl-gammarelay | Redshift      |
| ----------------- | --------- | ----------- | ------------- | ------------- |
| **Wayland**       | ✅ Native | ✅ Native   | ✅ Native     | ❌ NO         |
| **Maintained**    | ✅ Active | ⚠️ Archived | ✅ Active     | ✅ Active     |
| **Auto-location** | ✅ Yes    | ❌ No       | ❌ No         | ✅ Yes        |
| **For River**     | ✅ Best   | ⚠️ Minimal  | ⚠️ Complex    | ❌ Won't work |

---

## Temperature Values

```
Morning (6-9 AM):     5500K   (ease into day)
Work (9 AM-5 PM):     6500K   (focus/bright)
Afternoon (5-6 PM):   5500K   (transition)
Evening (6-9 PM):     4000K   (relax)
Night (9 PM-24:00):   3500K   (sleep prep)
Late Night (after):   3000K   (deep sleep)
```

**Health Impact:**

- Blue light (6000K+) → Suppresses melatonin → Delays sleep
- Warm light (3000-4000K) → Promotes melatonin → Better sleep

---

## Optional Enhancements

### 1. Add Keybindings (river.nix)

```bash
# Reset to normal (remove filter)
riverctl map normal $mod+Shift O spawn "gammastep -x"

# Set night mode immediately
riverctl map normal $mod+Shift P spawn "gammastep -O 3500"
```

### 2. Create Control Scripts

```bash
# ~/.local/bin/toggle-nightlight
#!/bin/bash
CURRENT=$(gammastep -p | grep "Color temperature" | grep -oE '[0-9]+' | head -1)
if [ "$CURRENT" -gt "5000" ]; then
    gammastep -O 3500
else
    gammastep -O 6500
fi
```

### 3. Custom Schedule (~/.config/gammastep/config.ini)

```ini
[general]
adjustment-method=wayland
fade=1
temp-day=6500
temp-night=3500

[manual]
lat=52.37
lon=4.90

[time-schedule]
dawn-time=06:00-08:00
dusk-time=18:00-20:00
```

---

## Troubleshooting

| Problem           | Cause              | Fix                                    |
| ----------------- | ------------------ | -------------------------------------- |
| No effect         | Wrong method       | Set `adjustment-method = wayland`      |
| Flicker           | Multiple instances | `killall gammastep; systemctl restart` |
| Won't start       | No Wayland session | Ensure River is running                |
| Cursor stays blue | Expected           | Cursor uses hardware layer             |

---

## File Locations

| File                                       | Purpose                   |
| ------------------------------------------ | ------------------------- |
| `modules/home/services.nix`                | Gammastep NixOS config    |
| `modules/home/river.nix`                   | River spawn + packages    |
| `~/.config/systemd/user/gammastep.service` | Auto-generated service    |
| `~/.config/gammastep/config.ini`           | Runtime config (optional) |

---

## Key Protocols

- **wl-gamma-correction**: Wayland protocol for gamma ramps
- **wlroots**: Compositor framework (used by River)
- **systemd user session**: Manages services per-user

---

## No Action Required ✅

Your system is optimally configured. The current setup:

- ✅ Uses best Wayland solution (Gammastep)
- ✅ Proper location coordinates
- ✅ Good temperature values
- ✅ Correctly integrated with River
- ✅ Smoothly transitions (fade=1)
- ✅ Actively maintained

---

## Further Reading

- Full documentation: `docs/research/BLUE-LIGHT-FILTER-WAYLAND-RESEARCH.md`
- Gammastep manual: `man gammastep`
- Home Manager docs: https://nix-community.github.io/home-manager/
