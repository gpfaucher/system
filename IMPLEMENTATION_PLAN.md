# NixOS Configuration Fix Implementation Plan

This plan addresses four issues: monitor hotplugging, window resizing, cursor theming, and bluetooth audio switching.

## Prerequisites

- Working directory: `/home/user/system`
- Test changes by running `sudo nixos-rebuild switch --flake .#voyager` after each major section
- Commit after each working section

---

## 1. Fix External Monitor Hotplugging with Kanshi

### 1.1 Create kanshi home-manager module

Create new file `modules/home/kanshi.nix`:

```nix
{ pkgs, ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      # Laptop only (no external monitors)
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080@60Hz";  # Adjust to actual laptop resolution
            position = "0,0";
            scale = 1.0;
          }
        ];
      }
      # External ultrawide only (laptop closed/disabled)
      {
        profile.name = "docked-single";
        profile.outputs = [
          {
            criteria = "DP-2";
            status = "enable";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }
      # Both displays (laptop + external)
      {
        profile.name = "docked-dual";
        profile.outputs = [
          {
            criteria = "DP-2";
            status = "enable";
            mode = "3440x1440@100Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "enable";
            position = "3440,0";  # Right of ultrawide
            scale = 1.0;
          }
        ];
      }
    ];
  };
}
```

### 1.2 Import kanshi module

In `modules/home/default.nix`, add import for `./kanshi.nix`.

### 1.3 Update Hyprland monitor config

In `modules/home/hyprland.nix`, change the `monitor` section to:

```nix
monitor = [
  ",preferred,auto,1"  # Fallback: let kanshi handle specifics
];
```

### 1.4 Verification

Run `kanshictl reload` after rebuild to test profile switching. Use `hyprctl monitors` to verify outputs.

---

## 2. Fix Window Resizing

### 2.1 Add mouse bindings for drag-resize

In `modules/home/hyprland.nix`, add a new `bindm` section (after the existing `binde` section):

```nix
bindm = [
  "$mod, mouse:272, movewindow"     # ALT + left-click drag to move
  "$mod, mouse:273, resizewindow"   # ALT + right-click drag to resize
];
```

### 2.2 Add master layout split ratio controls

Update the existing `binde` section in `modules/home/hyprland.nix` to include splitratio adjustments:

```nix
binde = [
  # Existing floating window resize
  "SUPERSHIFT,H,resizeactive,-150 0"
  "SUPERSHIFT,J,resizeactive,0 150"
  "SUPERSHIFT,K,resizeactive,0 -150"
  "SUPERSHIFT,L,resizeactive,150 0"
  # Master layout split ratio (for tiled windows)
  "$mod CTRL,H,splitratio,-0.05"
  "$mod CTRL,L,splitratio,+0.05"
];
```

### 2.3 Verification

After rebuild, test:
- `ALT + right-click drag` on any window to resize
- `ALT + left-click drag` to move windows
- `ALT + CTRL + H/L` to adjust master/stack ratio in tiled layout

---

## 3. Fix Cursor Theme

### 3.1 Add cursor configuration to home-manager

In `modules/home/wayland.nix`, add the pointerCursor configuration:

```nix
home.pointerCursor = {
  name = "Adwaita";
  package = pkgs.adwaita-icon-theme;
  size = 24;
  gtk.enable = true;
  x11.enable = true;
};
```

### 3.2 Fix environment variables in Hyprland

In `modules/home/hyprland.nix`, update the `env` section:

1. **Remove** the duplicate `GDK_SCALE` entries (lines with both `GDK_SCALE, 2` and `GDK_SCALE,1`)
2. **Keep only one** `GDK_SCALE,1`
3. **Add** cursor environment variables:

```nix
env = [
  "XCURSOR_SIZE,24"
  "XCURSOR_THEME,Adwaita"
  # ... keep other env vars, but remove duplicate GDK_SCALE
  "GDK_SCALE,1"  # Keep only this one
];
```

### 3.3 Remove manual cursor exec-once

In `modules/home/hyprland.nix`, remove or comment out the exec-once cursor line:

```nix
exec-once = [
  # Remove: "hyprctl setcursor Numix-Cursor 24"
];
```

If exec-once becomes empty, you can remove the entire section.

### 3.4 Optional: Use hyprcursor for Hyprland-native cursors

For better Wayland cursor support, consider adding hyprcursor theme. This is optional but recommended:

```nix
home.packages = with pkgs; [
  hyprcursor
];
```

### 3.5 Verification

After rebuild, cursor should be consistent across:
- Hyprland desktop
- GTK applications
- Qt applications
- XWayland applications

---

## 4. Improve Bluetooth Audio Switching

### 4.1 Enhance bluetooth system configuration

Update `modules/core/bluetooth.nix`:

```nix
_: {
  hardware.logitech.wireless.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
};
```

### 4.2 Add PipeWire bluetooth codec support

In `modules/core/pipewire.nix` (create if doesn't exist, or add to existing), add WirePlumber bluetooth configuration:

```nix
{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.extraConfig = {
      "50-bluetooth" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
          "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "ldac" "aptx" "aptx_hd" "aptx_ll" "aptx_ll_duplex" "faststream" "faststream_duplex" ];
          "bluez5.default.rate" = 48000;
          "bluez5.default.channels" = 2;
        };
      };
    };
  };
};
```

### 4.3 Add bluetuith configuration

Create `modules/home/bluetuith.nix` for persistent bluetuith settings:

```nix
{ ... }:
{
  # bluetuith config file
  xdg.configFile."bluetuith/bluetuith.conf".text = ''
    {
      "behavior": {
        "adapter_states": {
          "powered": true,
          "discoverable": false,
          "pairable": true
        }
      },
      "keybindings": {
        "NavigateUp": "k",
        "NavigateDown": "j",
        "NavigateRight": "l",
        "NavigateLeft": "h",
        "Quit": "q",
        "Menu": "m"
      }
    }
  '';
}
```

### 4.4 Add quick-connect keybind for last device

In `modules/home/hyprland.nix`, add a keybind for quick reconnect to last bluetooth device:

```nix
bind = [
  # ... existing binds
  # Quick reconnect to last bluetooth device
  "$mod CTRL, b, exec, bluetoothctl connect $(bluetoothctl devices Paired | head -1 | awk '{print $2}')"
];
```

### 4.5 Import new module

If you created `bluetuith.nix`, import it in `modules/home/default.nix`.

### 4.6 Verification

After rebuild:
- `ALT + SHIFT + T` opens bluetuith TUI (existing)
- `ALT + CTRL + B` quick-connects to last paired device
- Check codec in use: `pactl list cards | grep -A 30 bluez`

---

## 5. Cleanup

### 5.1 Remove unused packages

In `modules/home/packages/gui-apps.nix`, consider removing:
- `lyra-cursors` (if using Adwaita instead)
- `wofi-bluetooth` references if fully switching to bluetuith

### 5.2 Remove wofi-bluetooth keybind

In `modules/home/hyprland.nix`, the `$mod, b, exec, wofi-bluetooth` bind can be repurposed or removed if you prefer bluetuith exclusively.

---

## Final Verification Checklist

After all changes:

1. [ ] `sudo nixos-rebuild switch --flake .#voyager` succeeds
2. [ ] Plug/unplug external monitor - kanshi switches profiles automatically
3. [ ] `ALT + right-click drag` resizes windows
4. [ ] `ALT + CTRL + H/L` adjusts master/stack ratio
5. [ ] Cursor is consistent across all applications
6. [ ] Bluetooth earbuds connect with good audio quality
7. [ ] `ALT + SHIFT + T` opens bluetuith
8. [ ] `ALT + CTRL + B` quick-connects to last device

---

## Commit Strategy

1. Commit 1: "feat(display): add kanshi for automatic monitor profile switching"
2. Commit 2: "fix(hyprland): add mouse and keyboard window resize bindings"
3. Commit 3: "fix(cursor): configure Adwaita cursor theme via home-manager"
4. Commit 4: "feat(bluetooth): enhance bluetooth audio with codec support and bluetuith config"
