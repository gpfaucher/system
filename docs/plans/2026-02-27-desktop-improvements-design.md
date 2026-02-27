# Desktop Improvements Design

## Changes

### 1. Webcam mic fix

The WirePlumber rules in `audio.nix` use `device.name = "v4l2_device.*"` to cap camera resolution. The webcam's audio interface is a separate USB audio device, but we should verify these rules aren't interfering with the audio node.

Add WirePlumber monitor rules that:
- Target USB audio input devices (webcam mic, built-in mic) by node properties
- Set default channel volume/gain to a usable level (e.g. 1.5-2.0x)
- Ensure the nodes are not disabled or suspended

Also bump the built-in mic gain since it's reported as very quiet.

Files: `modules/system/audio.nix`

### 2. Replace EWW with Waybar

Remove the EWW module and replace with Waybar.

**Remove:**
- `modules/home/hyprland/eww/` (entire directory)
- EWW import from `modules/home/hyprland/default.nix`
- EWW exec-once and toggle keybind from Hyprland config

**Add:**
- `modules/home/hyprland/waybar.nix` with:
  - `programs.waybar.enable = true`
  - `output: "*"` for all monitors
  - Left: `hyprland/workspaces` (show workspaces for current monitor only)
  - Center: `hyprland/window` (active window title)
  - Right: `wireplumber`, `network`, `bluetooth`, `battery`, `cpu`, `memory`, `clock`, `tray` (packed together, not spread)
  - Gruvbox Material Dark styling via Stylix color variables
  - Semi-transparent background, rounded corners, matching current aesthetic
- Import waybar.nix from `modules/home/hyprland/default.nix`
- Waybar exec-once in Hyprland config
- `$mod+b` toggle via `pkill -SIGUSR1 waybar`

**Waybar workspace widget config:**
- `show-special: false` (scratchpad stays hidden)
- `active-only: false` (show all workspace buttons)
- `all-outputs: false` (per-monitor workspace display)

Files: `modules/home/hyprland/waybar.nix` (new), `modules/home/hyprland/default.nix`

### 3. DWM-style per-monitor workspaces

Replace workspace dispatchers so `$mod+N` operates on the focused monitor:
- `$mod+1-9`: `focusworkspaceoncurrentmonitor` instead of `workspace`
- `$mod+SHIFT+1-9`: `movetoworkspace` (unchanged — windows move to the target workspace)
- `$mod+Tab`: keep as `workspace, previous` (goes to last workspace globally)

This gives the DWM feel: each monitor has its own active workspace, and switching workspaces only affects the current monitor.

Files: `modules/home/hyprland/default.nix`

### 4. Add opencode

Add `pkgs.opencode` to `home.packages`.

Files: `modules/home/default.nix`
