# Blue Light Filter Configuration Examples

## Complete Implementation Examples

All code examples for Wayland/River WM with NixOS/Home Manager.

---

## 1. Minimal Configuration (Current Setup)

**Recommended for most users. Already implemented.**

### modules/home/services.nix

```nix
{ config, lib, pkgs, ... }:

{
  # Minimal Gammastep configuration (CURRENT)
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
}
```

**Configuration Impact:**

- ✅ Minimal resource usage
- ✅ Reliable behavior
- ✅ Good defaults
- ✅ Works with River immediately

---

## 2. Enhanced Configuration (Optional)

### Add Brightness Control

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

  # New: Brightness control
  brightness = {
    day = 1.0;
    night = 0.9;  # Slightly dimmer at night
  };

  settings = {
    general = {
      adjustment-method = "wayland";
      fade = 1;
    };
  };
};
```

**Effect:**

- Screen 10% dimmer at night
- Reduces eye strain further
- Helps with sleep transition

### Add Gamma Correction

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

  brightness = {
    day = 1.0;
    night = 0.9;
  };

  # New: Per-channel gamma adjustment
  settings = {
    general = {
      adjustment-method = "wayland";
      fade = 1;
      gamma = "0.95:0.95:0.95";
    };
  };
};
```

**Effect:**

- Fine-tunes color response
- Values: 0.5 (very dark) to 1.0 (normal)
- 0.95 is subtle, good starting point

---

## 3. Advanced Configuration (Custom Schedule)

### Fixed Time-Based Transitions

Instead of solar elevation, use fixed times:

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

  brightness = {
    day = 1.0;
    night = 0.9;
  };

  settings = {
    general = {
      adjustment-method = "wayland";
      fade = 1;
      gamma = "0.95:0.95:0.95";

      # New: Custom schedule
      dawn-time = "06:00-08:00";
      dusk-time = "18:00-20:00";
    };
  };
};
```

**Effect:**

- Day mode: 08:00 to 18:00
- Night mode: 20:00 to 06:00
- Smooth transitions during dawn/dusk windows

### Manual ~/.config/gammastep/config.ini

Create and edit file directly (overrides NixOS config):

```ini
[general]
adjustment-method=wayland
fade=1
gamma=0.95:0.95:0.95

# Temperature settings
temp-day=6500
temp-night=3500

# Brightness settings
brightness-day=1.0
brightness-night=0.9

# Custom schedule (overrides solar elevation)
dawn-time=06:00-08:00
dusk-time=18:00-20:00

[manual]
lat=52.37
lon=4.90
```

**Usage:**

- `~/.config/gammastep/config.ini` takes precedence
- Reload: `systemctl --user restart gammastep`
- Useful for quick adjustments without rebuild

---

## 4. River Integration Examples

### Basic Spawn (Current)

**river.nix line 209:**

```bash
# Already configured, spawns at River startup
riverctl spawn gammastep
```

### Add Keybindings

Add to river init script (river.nix around line 175):

```bash
# === Blue Light Filter Control ===

# Reset to normal (remove all effects)
riverctl map normal $mod+Shift O spawn "gammastep -x"

# Set night mode immediately
riverctl map normal $mod+Shift P spawn "gammastep -O 3500"

# Set day mode immediately
riverctl map normal $mod+Shift I spawn "gammastep -O 6500"

# Toggle between day/night using scripts (see below)
riverctl map normal $mod+Shift L spawn ~/.local/bin/toggle-nightlight
```

### Create Helper Scripts

**~/.local/bin/toggle-nightlight** (for `$mod+Shift+L`):

```bash
#!/bin/bash
set -e

# Toggle between day and night temperatures

TEMP_DAY="6500"
TEMP_NIGHT="3500"
STATE_FILE="/tmp/nightlight-state"

# Get current state (default to 0 = day mode)
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

if [ "$CURRENT_STATE" = "0" ]; then
    # Currently in day mode, switch to night
    gammastep -O "$TEMP_NIGHT"
    echo "1" > "$STATE_FILE"
    notify-send --app-name=Gammastep "Night Light ON" "Temperature: ${TEMP_NIGHT}K"
else
    # Currently in night mode, switch to day
    gammastep -O "$TEMP_DAY"
    echo "0" > "$STATE_FILE"
    notify-send --app-name=Gammastep "Night Light OFF" "Temperature: ${TEMP_DAY}K"
fi
```

**~/.local/bin/adjust-temperature** (for fine tuning):

```bash
#!/bin/bash
set -e

# Adjust temperature by ±N kelvin
# Usage: adjust-temperature +300  (increase warmth)
#        adjust-temperature -300  (increase coolness)

ADJUSTMENT=${1:-200}
MIN_TEMP=1000
MAX_TEMP=10000

# Get current temperature
CURRENT=$(gammastep -p 2>/dev/null | grep "Color temperature" | grep -oE '[0-9]{4}' | head -1)

if [ -z "$CURRENT" ]; then
    CURRENT=6500  # Default fallback
fi

# Calculate new temperature
NEW=$((CURRENT + ADJUSTMENT))

# Clamp to valid range
if [ $NEW -lt $MIN_TEMP ]; then NEW=$MIN_TEMP; fi
if [ $NEW -gt $MAX_TEMP ]; then NEW=$MAX_TEMP; fi

# Apply
gammastep -O "$NEW" -m wayland

# Show notification
notify-send --app-name=Gammastep "Temperature Adjusted" "${NEW}K"
```

**Make executable:**

```bash
chmod +x ~/.local/bin/toggle-nightlight
chmod +x ~/.local/bin/adjust-temperature
```

**Use in keybindings:**

```bash
# Add to river.nix init script
riverctl map normal $mod+Shift bracketleft spawn "~/.local/bin/adjust-temperature -300"
riverctl map normal $mod+Shift bracketright spawn "~/.local/bin/adjust-temperature +300"
```

---

## 5. Alternative: Using wl-gammarelay (Optional)

For those wanting DBus-based control instead of direct gammastep:

**NOT RECOMMENDED for most users** - Gammastep is simpler and better maintained.

### Installation

```nix
# In home packages (river.nix)
wl-gammarelay-rs  # Rust implementation
```

### Configuration

```nix
# No direct Home Manager service yet, must configure manually
# Create systemd service or run via script
```

### Control via DBus

```bash
# Query current settings
gdbus call --session \
  --dest rs.wl-gammarelay \
  --object-path /rs/wl_gammarelay \
  --method org.freedesktop.DBus.Properties.GetAll \
  rs.wl_gammarelay.Manager

# Set temperature
gdbus call --session \
  --dest rs.wl-gammarelay \
  --object-path /rs/wl_gammarelay \
  --method rs.wl_gammarelay.Manager.SetTemperature \
  3500

# Set brightness
gdbus call --session \
  --dest rs.wl-gammarelay \
  --object-path /rs/wl_gammarelay \
  --method rs.wl_gammarelay.Manager.SetBrightness \
  0.9
```

---

## 6. Per-Location Configurations

### Amsterdam (Current)

```nix
latitude = 52.37;
longitude = 4.90;
```

### Other Locations

**New York, USA:**

```nix
latitude = 40.71;
longitude = -74.00;
```

**London, UK:**

```nix
latitude = 51.51;
longitude = -0.13;
```

**Tokyo, Japan:**

```nix
latitude = 35.68;
longitude = 139.69;
```

**Sydney, Australia:**

```nix
latitude = -33.87;
longitude = 151.21;
```

**São Paulo, Brazil:**

```nix
latitude = -23.55;
longitude = -46.63;
```

---

## 7. Temperature Preset Configurations

### Relaxed/Warm Focus

```nix
temperature = {
  day = 5500;    # Neutral-warm
  night = 4000;  # Very warm
};
```

**Best for:** Reading, relaxation, evening work

### Standard (Current - RECOMMENDED)

```nix
temperature = {
  day = 6500;    # Neutral-cool
  night = 3500;  # Warm
};
```

**Best for:** General use, productivity, good sleep

### Bright/Cool Focus

```nix
temperature = {
  day = 7000;    # Cool/bright
  night = 4500;  # Moderate warm
};
```

**Best for:** Programming, design work, morning

### Extreme Warm (Sleeping)

```nix
temperature = {
  day = 6500;    # Normal day
  night = 2500;  # Very warm/red
};
```

**Best for:** Pre-sleep preparation, extreme sensitivity

---

## 8. Motion-Sensitive Configuration

For laptops moving between locations:

```bash
# Use geoclue2 for automatic location detection
```

**In services.nix:**

```nix
services.gammastep = {
  enable = true;
  provider = "geoclue2";  # Auto-location via system services
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

**Trade-offs:**

- ✅ Automatic sun times everywhere
- ❌ Requires geoclue2 running
- ❌ May drain battery (GPS/network queries)
- ❌ Privacy concerns (location tracking)

**Better alternative:** Manual fixed location (current setup)

---

## 9. Systemd Service Customization

If you need a custom systemd service (advanced):

**~/.config/systemd/user/custom-gammastep.service:**

```ini
[Unit]
Description=Custom Gammastep Blue Light Filter
After=graphical-session.target
Requires=graphical-session.target

[Service]
Type=simple
ExecStart=/run/current-system/sw/bin/gammastep -m wayland -t 6500:3500 -l manual 52.37:4.90
Restart=on-failure
RestartSec=5

# Environment
Environment="WAYLAND_DISPLAY=%e/wayland-%i"

[Install]
WantedBy=graphical-session.target
```

**Enable:**

```bash
systemctl --user daemon-reload
systemctl --user enable custom-gammastep.service
systemctl --user start custom-gammastep.service
```

**Note:** Home Manager already manages this - use only if custom behavior needed

---

## 10. Testing & Verification

### Test Configuration

```bash
# Parse config and show what would happen
gammastep -p

# Verbose test
gammastep -t 6500:3500 -l manual 52.37:4.90 -m wayland -v

# One-shot (doesn't stay running)
gammastep -t 6500:3500 -l manual 52.37:4.90 -m wayland -o

# Test with reset
gammastep -P -t 6500:3500 -l manual 52.37:4.90 -m wayland -o
```

### Service Verification

```bash
# Check if running
systemctl --user is-active gammastep

# See what's installed
which gammastep
gammastep --version

# Check environment
echo $WAYLAND_DISPLAY
echo $XDG_CONFIG_HOME

# Monitor in real-time
journalctl --user -u gammastep -f
```

### Visual Test

```bash
# Set to extreme values to see effect clearly
gammastep -O 3000  # Very warm/red
gammastep -O 8000  # Very cool/blue
gammastep -x       # Reset
```

---

## Summary of Configurations

| Use Case               | Temperature | Brightness | Gamma | Best For     |
| ---------------------- | ----------- | ---------- | ----- | ------------ |
| **Standard** (CURRENT) | 6500K:3500K | 1.0:1.0    | -     | General use  |
| **Warm**               | 6500K:4000K | 1.0:0.95   | -     | Relaxation   |
| **Cool**               | 7000K:4500K | 1.0:1.0    | -     | Focus/design |
| **Sleeping**           | 6500K:2500K | 1.0:0.8    | 0.95  | Pre-sleep    |
| **Mobile**             | Auto        | 1.0:0.9    | -     | Traveling    |

---

## Migration from Redshift

**If you had Redshift (X11) before:**

```bash
# Uninstall X11-only redshift
nix-env -e redshift

# Gammastep is already installed in this setup
# Just enable and it works!
```

**Config file migration:**

Redshift: `~/.config/redshift/redshift.conf`  
Gammastep: `~/.config/gammastep/config.ini`

Most options are compatible, just rename:

- `redshift.conf` → `config.ini`
- `[general]` stays same
- `[redshift]` → `[manual]` (if using manual location)

---

## Performance Notes

**Resource Usage:**

- Gammastep daemon: ~10-20 MB RAM
- CPU: Negligible (updates only at period changes)
- Battery: Minimal impact
- Wayland protocol: Efficient (no polling)

**Compared to alternatives:**

- Gammastep: Balanced (features + efficiency)
- wlsunset: Lighter (fewer features)
- wl-gammarelay: Lighter (DBus overhead)
- Redshift: Would use more on Wayland (if it worked)

---

**Choose the configuration that matches your needs!**
