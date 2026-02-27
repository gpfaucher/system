# Desktop Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix webcam mic, replace EWW with Waybar (all monitors, proper layout), add DWM-style per-monitor workspaces, and install opencode.

**Architecture:** Four independent changes to the NixOS system config. The Waybar replacement is the largest — it creates a new module and removes the EWW module. The workspace and mic changes are edits to existing files. opencode is a one-liner.

**Tech Stack:** NixOS, Home Manager, Hyprland, Waybar, WirePlumber, Stylix

---

### Task 1: Fix webcam mic and boost built-in mic

**Files:**

- Modify: `modules/system/audio.nix`

**Step 1: Add WirePlumber rules for mic input gain**

In `modules/system/audio.nix`, add two new WirePlumber extraConfig entries inside the `wireplumber.extraConfig` attrset, after the `"12-bluetooth-defaults"` block:

```nix
        # Boost built-in mic gain (internal mics are often too quiet)
        "20-mic-gain" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_input.*";
                }
              ];
              actions.update-props = {
                "channelVolumes" = [ 1.5 1.5 ];
                "channelMap" = [ "FL" "FR" ];
                "softVolumes" = true;
              };
            }
          ];
        };

        # Ensure USB webcam audio nodes are not suspended
        # (v4l2 camera rules can sometimes interfere with the audio side)
        "21-webcam-audio" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_input.usb-*";
                }
              ];
              actions.update-props = {
                "session.suspend-timeout-seconds" = 0;
                "channelVolumes" = [ 2.0 2.0 ];
                "channelMap" = [ "FL" "FR" ];
                "softVolumes" = true;
              };
            }
          ];
        };
```

**Step 2: Verify the camera rules don't target audio nodes**

Check the existing `"10-camera-limit"` block. It matches `node.name = "~v4l2_input.*"` — this targets video input nodes only (not audio), so it should be fine. No changes needed here.

**Step 3: Commit**

```bash
git add modules/system/audio.nix
git commit -m "fix: boost mic gain and prevent webcam audio node suspension"
```

---

### Task 2: Create Waybar module

**Files:**

- Create: `modules/home/hyprland/waybar.nix`

**Step 1: Create the Waybar module file**

Create `modules/home/hyprland/waybar.nix` with the following content:

```nix
{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
{
  programs.waybar = {
    enable = true;

    # Disable Stylix auto-styling — we provide our own CSS
    # (Stylix waybar target is not in theme.nix targets, so this is already off)

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        margin-top = 6;
        margin-left = 8;
        margin-right = 8;
        output = "*";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "wireplumber"
          "battery"
          "cpu"
          "memory"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          all-outputs = false;
          show-special = false;
          sort-by-number = true;
        };

        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };

        bluetooth = {
          format = "󰂯 {device_alias}";
          format-disabled = "";
          format-off = "";
          format-no-controller = "";
          format-connected = "󰂯 {device_alias}";
          format-connected-battery = "󰂯 {device_alias} {device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = "󰤭 Off";
          on-click = "nm-connection-editor";
        };

        wireplumber = {
          format = "󰕾 {volume}%";
          format-muted = "󰝟 MUTE";
          on-click = "pavucontrol";
        };

        battery = {
          interval = 10;
          states = {
            warning = 30;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        };

        cpu = {
          interval = 2;
          format = "󰻠 {usage}%";
        };

        memory = {
          interval = 2;
          format = "󰍛 {percentage}%";
        };

        clock = {
          interval = 1;
          format = "󰥔 {:%a %d %b  %H:%M}";
        };
      };
    };

    style = ''
      * {
        font-family: "Monaspace Neon", "Symbols Nerd Font", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, 0.92);
        border-radius: 12px;
        border: 2px solid #${colors.base02};
        padding: 0 12px;
      }

      /* ── Workspaces ── */
      #workspaces button {
        min-width: 24px;
        min-height: 24px;
        border-radius: 8px;
        color: #${colors.base04};
        padding: 0 4px;
        transition: all 150ms ease;
      }

      #workspaces button:hover {
        background: #${colors.base02};
        color: #${colors.base05};
      }

      #workspaces button.active {
        background: #${colors.base08};
        color: #${colors.base00};
        font-weight: bold;
      }

      #workspaces button.occupied {
        color: #${colors.base05};
      }

      /* ── Window title ── */
      #window {
        color: #${colors.base05};
        padding: 0 16px;
      }

      /* ── Modules ── */
      #tray,
      #bluetooth,
      #network,
      #wireplumber,
      #battery,
      #cpu,
      #memory,
      #clock {
        padding: 0 8px;
        color: #${colors.base05};
        border-radius: 8px;
        transition: all 150ms ease;
      }

      #tray:hover,
      #bluetooth:hover,
      #network:hover,
      #wireplumber:hover,
      #battery:hover,
      #cpu:hover,
      #memory:hover,
      #clock:hover {
        background: #${colors.base02};
      }

      /* Module-specific icon colors via font color */
      #network { color: #${colors.base0D}; }
      #bluetooth { color: #${colors.base0D}; }
      #wireplumber { color: #${colors.base0A}; }
      #battery { color: #${colors.base0B}; }
      #cpu { color: #${colors.base09}; }
      #memory { color: #${colors.base0E}; }
      #clock { color: #${colors.base0C}; }
      #tray { padding: 0 4px; }

      /* Battery states */
      #battery.warning { color: #${colors.base0A}; }
      #battery.critical { color: #${colors.base08}; }
    '';
  };
}
```

**Step 2: Commit**

```bash
git add modules/home/hyprland/waybar.nix
git commit -m "feat: add Waybar module with Gruvbox theme"
```

---

### Task 3: Wire up Waybar and remove EWW

**Files:**

- Modify: `modules/home/hyprland/default.nix`
- Delete: `modules/home/hyprland/eww/` (entire directory)

**Step 1: Update imports in `modules/home/hyprland/default.nix`**

Replace the `./eww` import with `./waybar.nix`:

```
# Old
    ./eww

# New
    ./waybar.nix
```

**Step 2: Remove EWW references from the `let` block**

Remove the `handleMonitorChange` script's EWW restart lines. Replace the monitor hotplug script so it no longer references EWW:

```nix
  handleMonitorChange = pkgs.writeShellScriptBin "handle-monitor-change" ''
    handle() {
      case "$1" in
        monitoradded*|monitorremoved*)
          external_count=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq '[.[] | select(.name != "eDP-1")] | length')
          if [ "$external_count" -gt 0 ]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1, disable"
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1, 3840x2400@60, auto, 2"
          fi
          ;;
      esac
    }

    ${pkgs.socat}/bin/socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while IFS= read -r line; do
      handle "$line"
    done
  '';
```

**Step 3: Update bar toggle keybind**

In the `bind` list, replace:

```
"$mod, b, exec, eww close bar || eww open bar"
```

with:

```
"$mod, b, exec, pkill -SIGUSR1 waybar"
```

**Step 4: Update exec-once**

In the `exec-once` list, replace:

```
"eww open bar"
```

with:

```
"waybar"
```

**Step 5: Remove EWW from home.packages**

The `eww` package is pulled in by `programs.eww.enable = true` in the eww module. Since we're removing that import, no explicit cleanup needed in packages — but verify there's no leftover `eww` reference.

**Step 6: Delete the EWW directory**

```bash
git rm -r modules/home/hyprland/eww/
```

**Step 7: Commit**

```bash
git add modules/home/hyprland/default.nix
git commit -m "feat: replace EWW with Waybar, show bar on all monitors"
```

---

### Task 4: DWM-style per-monitor workspaces

**Files:**

- Modify: `modules/home/hyprland/default.nix`

**Step 1: Replace workspace dispatchers**

In the `bind` list, replace all 9 workspace focus bindings:

```
# Old
"$mod, 1, workspace, 1"
"$mod, 2, workspace, 2"
"$mod, 3, workspace, 3"
"$mod, 4, workspace, 4"
"$mod, 5, workspace, 5"
"$mod, 6, workspace, 6"
"$mod, 7, workspace, 7"
"$mod, 8, workspace, 8"
"$mod, 9, workspace, 9"

# New
"$mod, 1, focusworkspaceoncurrentmonitor, 1"
"$mod, 2, focusworkspaceoncurrentmonitor, 2"
"$mod, 3, focusworkspaceoncurrentmonitor, 3"
"$mod, 4, focusworkspaceoncurrentmonitor, 4"
"$mod, 5, focusworkspaceoncurrentmonitor, 5"
"$mod, 6, focusworkspaceoncurrentmonitor, 6"
"$mod, 7, focusworkspaceoncurrentmonitor, 7"
"$mod, 8, focusworkspaceoncurrentmonitor, 8"
"$mod, 9, focusworkspaceoncurrentmonitor, 9"
```

Also replace workspace 10:

```
# Old
"$mod, 0, workspace, 10"

# New
"$mod, 0, focusworkspaceoncurrentmonitor, 10"
```

The `$mod+SHIFT+N` (movetoworkspace) bindings stay unchanged.

**Step 2: Commit**

```bash
git add modules/home/hyprland/default.nix
git commit -m "feat: DWM-style per-monitor workspaces"
```

---

### Task 5: Add opencode

**Files:**

- Modify: `modules/home/default.nix`

**Step 1: Add opencode to home.packages**

In `modules/home/default.nix`, add `opencode` to the `home.packages` list. Add it in the "Development tools" section after `claude-code`:

```nix
    claude-code
    opencode
```

**Step 2: Commit**

```bash
git add modules/home/default.nix
git commit -m "feat: add opencode AI coding tool"
```

---

### Task 6: Build and verify

**Step 1: Run a NixOS build check**

```bash
cd /home/gabriel/projects/system
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run
```

If there are evaluation errors, fix them before proceeding.

**Step 2: If build succeeds, rebuild the system**

```bash
sudo nixos-rebuild switch --flake .#laptop
```

This requires user confirmation as it modifies the running system.
