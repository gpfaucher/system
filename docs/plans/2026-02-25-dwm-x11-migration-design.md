# DWM + X11 Migration Design

## Problem

KDE Plasma 6 on Wayland is unstable on NVIDIA hybrid (AMD Phoenix1 + RTX 2000 Ada):
- Bluetooth audio calling (HFP) unreliable
- Screensharing flaky (XDG portal per-app support inconsistent)
- Electron apps (Teams) struggle with Wayland screensharing

## Solution

Replace KDE Plasma 6 Wayland with DWM on X11. X11 has mature, universal screensharing (any app can capture any window), stable NVIDIA hybrid support, and rock-solid Bluetooth HFP via PipeWire.

## Requirements

- Any monitor plugged in must just work (hotplug)
- Presenting on big screens must just work
- Screensharing must work reliably
- Teams / video calling with Bluetooth audio + mic must work
- Minimal aesthetic: no gaps by default (togglable), no wasted space
- Ayu Dark theming everywhere (derived from Stylix base16)
- Bluetooth and network configuration via GUI applets

## Architecture

### What Gets Replaced

| Before (KDE Plasma 6 Wayland) | After (DWM X11) |
|---|---|
| SDDM Wayland | LightDM + slick-greeter |
| KWin Wayland compositor | DWM + Picom |
| KRunner | dmenu |
| Plasma notifications | dunst |
| Spectacle | maim + xclip |
| Plasma lock screen | slock |
| Plasma wallpaper | feh |
| Plasma network widget | nm-applet (systray) |
| Plasma bluetooth widget | blueman-applet (systray) |

### What Stays

- PipeWire + WirePlumber audio stack (all bluetooth config unchanged)
- hardware.bluetooth config
- NetworkManager
- NVIDIA PRIME offload mode
- Stylix base16 Ayu Dark
- All home-manager packages, git, shell, terminal, nvf, zed, etc.
- SSH tunnels, secrets, hardening

### New Additions

- autorandr — declarative xrandr profile management for monitor hotplug
- blueman — Bluetooth manager GUI (systray applet)
- nm-applet — NetworkManager systray applet
- dunst — notification daemon
- slstatus — status bar content (or dwmblocks if shell scripts needed)
- picom — compositor (blur, fading, rounded corners, vsync)
- dmenu — app launcher
- feh — wallpaper setter

## DWM Build

Custom Nix derivation using `pkgs.dwm.overrideAttrs`. Patches applied declaratively, config.h generated with Stylix colors interpolated at Nix eval time.

### Patches (24)

**Core:**
- pertag — independent layout/mfact/nmaster per tag
- autostart — run startup scripts
- vanitygaps — configurable gaps (togglable, default can be 0)
- movestack — move windows in stack with keybinds
- restartsig — restart DWM in-place without killing X
- restoreafterrestart — windows return to tags after restart
- swallow — terminal swallows GUI child processes
- attachbelow — new windows below focused, not as master

**Floating:**
- save_floats — remember floating position when toggling tiled/float
- fakefullscreen — fullscreen contained within tile

**Multi-monitor:**
- statusallmons — status bar on all monitors
- warp — mouse follows focus across monitors

**Bar:**
- systray — system tray for nm-applet, blueman, etc.
- statuscmd — clickable status bar segments
- smartborders — hide border with single tiled window

**Layouts:**
- centeredmaster — master center, stack both sides (for ultrawide)
- deck — stack shows one window at a time
- fibonacci — spiral/dwindle layouts
- cyclelayouts — cycle layouts with keybind

**Scratchpads:**
- namedscratchpads — toggle-able floating windows per keybind

**App-specific:**
- steam — fix Steam window positioning bug
- focusonnetactive — auto-focus windows requesting attention
- sticky — pin window visible on all tags

**Advanced:**
- cfacts — per-window size weight in stack
- xrdb — load colors from Xresources at runtime

### Floating Rules (config.h)

```c
static const Rule rules[] = {
    /* class                  instance  title     tags  isfloat  monitor */
    { "teams-for-linux",      NULL,     "Call",   0,    1,       -1 },
    { "teams-for-linux",      NULL,     "Share",  0,    1,       -1 },
    { "zoom",                 NULL,     NULL,     0,    1,       -1 },
    { "Gimp",                 NULL,     NULL,     0,    1,       -1 },
    { "Steam",                NULL,     NULL,     0,    1,       -1 },
    { "blueman-manager",      NULL,     NULL,     0,    1,       -1 },
    { "nm-connection-editor", NULL,     NULL,     0,    1,       -1 },
    { "pavucontrol",          NULL,     NULL,     0,    1,       -1 },
};
```

### Named Scratchpads

- `Mod+grave` — terminal scratchpad (ghostty)

## Picom (Compositor)

- Backend: glx (best for NVIDIA hybrid)
- Blur: dual_kawase
- Fading: enabled, ~0.1s duration
- Rounded corners: ~8px
- Shadows: subtle, dark
- VSync: enabled
- Exclude rules: no blur/rounding on fullscreen, DWM bar, screensharing

## Status Bar (slstatus)

Custom Nix build. Segments:
- Battery % + state
- Volume %
- Bluetooth connected device
- WiFi SSID
- CPU %
- RAM %
- Date/time

If bluetooth device name requires shell scripting, switch to dwmblocks.

## Monitor Hotplug (autorandr)

- `services.autorandr.enable = true` at system level
- Profiles saved per monitor configuration
- udev-triggered automatic profile switching
- User saves profiles: `autorandr --save <name>`

## Display Manager (LightDM + Slick Greeter)

- lightdm-slick-greeter with background image
- Ayu Dark color scheme
- Clean, modern appearance

## Startup Chain

Via DWM autostart patch (`~/.dwm/autostart.sh`):

```sh
picom &
slstatus &
dunst &
nm-applet &
blueman-applet &
feh --bg-fill ~/.wallpaper &
autorandr --change &
```

## Theming

All colors derived from Stylix base16 Ayu Dark palette:

| Element | Color Source |
|---|---|
| DWM bar bg | base00 (#0b0e14) |
| DWM bar fg | base05 (#e6e1cf) |
| DWM focused border | base0D (#59c2ff) |
| DWM unfocused border | base01 (#131721) |
| DWM selected tag bg | base0D (#59c2ff) |
| DWM selected tag fg | base00 (#0b0e14) |
| dmenu normal bg/fg | base00/base05 |
| dmenu selected bg/fg | base0D/base00 |
| dunst | Stylix target (automatic) |
| picom shadow color | base00 |
| slstatus delimiter | base03 (#3e4b59) |
| LightDM slick greeter | Ayu Dark accent colors |

Stylix continues to theme: fish, ghostty, bat, fzf, btop, k9s, firefox, GTK apps, neovim, zed.

## Keybindings (config.h defaults, customizable)

| Bind | Action |
|---|---|
| Mod+Return | spawn terminal (ghostty) |
| Mod+d | dmenu_run |
| Mod+q | kill window |
| Mod+Shift+q | quit DWM |
| Mod+Shift+r | restart DWM (restartsig) |
| Mod+j/k | focus next/prev |
| Mod+Shift+j/k | move in stack |
| Mod+h/l | resize master |
| Mod+1-9 | switch tag |
| Mod+Shift+1-9 | move window to tag |
| Mod+space | toggle float |
| Mod+f | toggle fullscreen |
| Mod+s | toggle sticky |
| Mod+b | toggle bar |
| Mod+grave | terminal scratchpad |
| Mod+Tab | cycle layouts |
| Mod+Print | screenshot full |
| Mod+Shift+Print | screenshot selection |

## File Structure

### New Files

```
modules/home/dwm/
├── default.nix          # DWM package build, config.h, keybindings, rules
├── config.h             # DWM config with Stylix colors
├── patches/             # 24 patch files
├── autostart.sh         # Startup script
├── picom.nix            # Picom config
├── slstatus.nix         # slstatus build + config
├── dmenu.nix            # dmenu with Ayu Dark
└── dunst.nix            # dunst config
```

### Modified Files

| File | Change |
|---|---|
| `hosts/laptop/default.nix` | Remove KDE Plasma 6, SDDM. Add LightDM + slick greeter. |
| `modules/home/default.nix` | Import `./dwm`. Add packages (picom, maim, xclip, feh, slock, blueman, networkmanagerapplet). |
| `modules/home/theme.nix` | Remove KDE color scheme, `programs.plasma`. Keep Stylix. |
| `modules/system/graphics.nix` | Remove Wayland env vars (`NIXOS_OZONE_WL`, `MOZ_ENABLE_WAYLAND`). |
| `modules/system/services.nix` | Remove pipewire wantedBy overrides (X11 session handles). |
| `flake.nix` | Remove `plasma-manager` input and sharedModules entry. |

### Untouched

- `modules/home/nvf.nix`, `shell.nix`, `terminal.nix`, `zellij.nix`, `zed.nix`, `ssh.nix`
- `modules/system/audio.nix`, `networking.nix`, `hardening.nix`, `bootloader.nix`
- `modules/home/services.nix` (SSH tunnels)
- `secrets/`
