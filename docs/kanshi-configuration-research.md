# Kanshi Configuration Research Summary

## 1. Current Configuration File Locations

### Configuration File

- **Primary Location**: `~/.config/kanshi/config` (symlink managed by home-manager)
- **Actual Location**: `/nix/store/yhfmw8wmgkgk4987fghpa8cdw8ccrkvi-home-manager-files/.config/kanshi/config`
- **Systemd Service**: `~/.config/systemd/user/kanshi.service`
- **Source (Home Manager)**: `/home/gabriel/projects/system/modules/home/services.nix` (lines 19-160)

### Configuration Source in Home Manager

The kanshi configuration is declaratively defined in the Nix home-manager configuration as:

```nix
services.kanshi = {
  enable = true;
  systemdTarget = "graphical-session.target";
  settings = [ ... ];
}
```

## 2. Current Monitor Setup (Live Status)

### Currently Active Profile

**Profile Name**: `dual-portrait-ultrawide`

### Detected Hardware

```
HDMI-A-1: Microstep MSI MAG342CQR (Ultrawide)
  - Make: Microstep
  - Model: MSI MAG342CQR
  - Serial: DB6H261C02187
  - Physical: 790x330 mm
  - Current Mode: 3440x1440 @ 100Hz
  - Position: (0, 0)

DP-2: Microstep G272QPF E2 (Standard 16:9)
  - Make: Microstep
  - Model: G272QPF E2
  - Serial: 0x01010101
  - Physical: 600x340 mm
  - Current Mode: 2560x1440 @ 60Hz
  - Position: (3440, 0) [to the right of ultrawide]
  - Transform: 90° rotation (portrait mode)

eDP-1: BOE 0x0B22 (Laptop Display)
  - Make: BOE
  - Model: 0x0B22
  - Physical: 340x210 mm
  - Status: DISABLED
  - Supported Mode: 3840x2400 @ 60Hz (when enabled)
```

### Monitor Identification Methods

Kanshi can identify outputs via:

1. **Output Name** (kernel driver dependent): `HDMI-A-1`, `DP-2`, `eDP-1`
2. **Output Description** (recommended for stability): `"Make Model Serial"`
   - Example: `"Microstep MSI MAG342CQR DB6H261C02187"`
3. **Wildcard Patterns** (for variable connections): `HDMI-A-*`, `DP-*`

## 3. Kanshi Configuration File Format

### File Location

```
$XDG_CONFIG_HOME/kanshi/config
(defaults to ~/.config/kanshi/config)
```

### Basic Structure

```
profile [name] {
  output <criteria> <directives>
  output <criteria> { <directives> }
  exec <command>
}
```

### Output Criteria Options

1. **Output Name**: `HDMI-A-1`, `DP-2`, `eDP-1`
2. **Output Description**: `"Manufacturer Model Serial"`
3. **Wildcards**: `HDMI-A-*`, `DP-*`, `*` (matches any single output)

### Output Directives

```
enable|disable                    # Enable or disable output
mode <width>x<height>[@<rate>Hz]  # Resolution and refresh
position <x>,<y>                  # Placement in global coordinates
scale <factor>                    # Scaling factor (1.0 = 100%)
transform <90|180|270|flipped*>   # Rotation/flip
adaptive_sync on|off              # Variable refresh rate
alias $<name>                     # Define alias for output
```

### Profile Directives

```
exec <command>                    # Run command when profile activates
```

## 4. Current Kanshi Profiles

### Profile 1: `dual-portrait-ultrawide` (Active)

```
- HDMI-A-1: 3440x1440@100Hz at (0,0), scale 1.0
- DP-2: 2560x1440@60Hz at (3440,0), scale 1.0, rotated 90°
- eDP-1: DISABLED
- Notification: "Dual monitor: Ultrawide + Portrait"
```

### Profile 2: `laptop`

```
- eDP-1: 3840x2400@60Hz at (0,0), scale 2.0
- HDMI-A-1: (not mentioned = disabled)
- DP-2: (not mentioned = disabled)
```

### Profile 3: `docked-dp`

```
- DP-2: 3440x1440@100Hz at (0,0), scale 1.0
- eDP-1: DISABLED
- HDMI-A-1: (not mentioned = disabled)
```

### Profile 4: `docked-hdmi`

```
- HDMI-A-1: 3440x1440@100Hz at (0,0), scale 1.0
- eDP-1: DISABLED
- DP-2: (not mentioned = disabled)
```

### Profile 5: `docked-dual`

```
- DP-2: 3440x1440@100Hz at (0,0), scale 1.0
- eDP-1: 3840x2400@60Hz at (3440,0), scale 2.0
- HDMI-A-1: (not mentioned = disabled)
```

### Profile 6: `presentation-hdmi`

```
- eDP-1: 3840x2400@60Hz at (0,0), scale 2.0
- HDMI-A-*: position (1920,0), scale 1.0 [any HDMI connector]
- Notification: "Presentation Mode - HDMI display connected"
```

### Profile 7: `presentation-dp`

```
- eDP-1: 3840x2400@60Hz at (0,0), scale 2.0
- DP-*: position (1920,0), scale 1.0 [any DP connector]
- Notification: "Presentation Mode - DP display connected"
```

## 5. How Kanshi Works

### Activation Logic

- Kanshi reads all profiles at startup
- When outputs connect/disconnect, it matches against all profiles
- **A profile activates when ALL outputs specified in it are currently connected**
- If multiple profiles match, the first one (top-to-bottom) activates
- If no profiles match perfectly, kanshi waits until one does

### Matching Rules

- Outputs explicitly listed in profile must all be connected
- Outputs NOT listed in profile are ignored (can be enabled/disabled as needed)
- Using wildcards (`*`) matches one output; cannot use multiple wildcards in same profile

## 6. Tools for Detecting Monitor Configuration

### 1. `wlr-randr` (Primary Tool)

```bash
wlr-randr
```

Shows:

- All connected outputs with names
- Supported resolutions and refresh rates
- Current mode, position, scale, transform
- Can be used to check what modes are available

### 2. `kanshictl` (Kanshi Control)

```bash
kanshictl status          # Show current active profile as JSON
kanshictl reload          # Reload config file
kanshictl switch <name>   # Switch to specific profile
```

### 3. Manual Inspection

```bash
cat ~/.config/kanshi/config  # View current config file
```

## 7. How to Update Kanshi Configuration

### Method 1: Via Home Manager (Recommended - System-Managed)

Edit: `/home/gabriel/projects/system/modules/home/services.nix`

The structure is:

```nix
services.kanshi = {
  enable = true;
  systemdTarget = "graphical-session.target";
  settings = [
    {
      profile.name = "profile-name";
      profile.outputs = [
        {
          criteria = "OUTPUT_NAME";
          status = "enable";
          mode = "WIDTH x HEIGHT @ Hz";
          position = "X,Y";
          scale = 1.0;
          transform = "90";  # optional
        }
      ];
      profile.exec = [ "${pkgs.libnotify}/bin/notify-send 'message'" ];
    }
  ];
};
```

Then rebuild:

```bash
cd /home/gabriel/projects/system
# Edit modules/home/services.nix
# Then rebuild and switch
```

### Method 2: Direct Config File (Temporary Testing)

Edit: `~/.config/kanshi/config` directly

Format:

```
profile profile-name {
  output HDMI-A-1 enable mode 3440x1440@100Hz position 0,0 scale 1.000000
  output DP-2 enable mode 2560x1440@60Hz position 3440,0 scale 1.000000 transform 90
  output eDP-1 disable
  exec notify-send 'Profile Activated' 'Dual monitor setup'
}
```

Then reload:

```bash
kanshictl reload
# or systemctl restart --user kanshi
```

⚠️ **Note**: Direct edits will be overwritten by home-manager rebuild. Use for testing only.

## 8. Step-by-Step Process to Add Current Monitor Setup

### Current Setup (as of Jan 24, 2026)

- **Status**: Already captured as `dual-portrait-ultrawave` profile
- **Primary Display**: Microstep MSI MAG342CQR (3440x1440 ultrawide)
- **Secondary Display**: Microstep G272QPF E2 (2560x1440 portrait rotated)
- **Laptop**: BOE display (disabled)

### To Add a New Profile

**Step 1**: Verify current monitor setup

```bash
wlr-randr
kanshictl status
```

**Step 2**: Determine output identifiers

```bash
wlr-randr  # Get NAME, Model, Serial
```

**Step 3**: Identify all available modes

```bash
wlr-randr | grep -A 50 "OUTPUT_NAME"
# Look for desired resolution and refresh rate
```

**Step 4**: Calculate position coordinates

- Position is in pixels in global coordinate space
- Format: `position X,Y` where (0,0) is top-left
- Place monitors side-by-side or stacked accordingly
- Example:
  - HDMI ultrawide at (0,0)
  - DP portrait at (3440,0) - starts where ultrawide ends

**Step 5**: Add to home-manager config
Edit `/home/gabriel/projects/system/modules/home/services.nix`:

```nix
{
  profile.name = "my-setup";
  profile.outputs = [
    {
      criteria = "HDMI-A-1";
      status = "enable";
      mode = "3440x1440@100Hz";
      position = "0,0";
      scale = 1.0;
    }
    {
      criteria = "DP-2";
      status = "enable";
      mode = "2560x1440@60Hz";
      position = "3440,0";
      scale = 1.0;
      transform = "90";
    }
  ];
}
```

**Step 6**: Rebuild and apply

```bash
# For testing with direct config edit:
kanshictl reload

# For home-manager config:
home-manager switch
```

**Step 7**: Verify

```bash
kanshictl status
wlr-randr
```

## 9. Kanshi Helper Tools

### Available Commands

- **kanshi**: Main daemon process
- **kanshictl**: Control utility with commands:
  - `status` - Show current profile (JSON format)
  - `reload` - Reload configuration without restart
  - `switch <profile>` - Manually switch to profile

### Integration Points

- **River WM**: Mapped to `Super+Ctrl+M` to reload kanshi config
- **Systemd**: Runs as user service on graphical-session-target
- **Signal Handling**: Responds to SIGHUP to reload config

## 10. Quick Reference Commands

```bash
# Check current monitors
wlr-randr

# Get current active profile
kanshictl status

# Reload kanshi config (apply changes)
kanshictl reload

# Manually switch profile
kanshictl switch presentation-dp

# View configuration file
cat ~/.config/kanshi/config

# Restart kanshi service
systemctl restart --user kanshi

# View kanshi logs
journalctl --user -u kanshi -f

# Test direct config change (temporary)
nano ~/.config/kanshi/config
kanshictl reload

# Permanent change via home-manager
nano /home/gabriel/projects/system/modules/home/services.nix
home-manager switch
```

## 11. Key Takeaways

1. **Configuration Source**: Nix home-manager declarative config (not static files)
2. **Current Setup**: Dual external monitors + disabled laptop display
3. **Active Profile**: `dual-portrait-ultrawide` (ultrawide + portrait DP)
4. **Detection Tools**: `wlr-randr` for hardware, `kanshictl` for status
5. **Update Method**: Edit home-manager config, rebuild, or use direct config file for testing
6. **Hot Reload**: `kanshictl reload` or `systemctl restart --user kanshi`
7. **Profiles**: 7 pre-configured profiles for different scenarios
