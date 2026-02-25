# DWM + X11 Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace KDE Plasma 6 Wayland with DWM on X11 for stable screensharing, Bluetooth audio calling, and multi-monitor hotplug support.

**Architecture:** Custom DWM build via `pkgs.dwm.overrideAttrs` with 24 patches and a config.h templated from Stylix base16 colors. Picom compositor for blur/fading/rounded corners. LightDM slick-greeter as display manager. autorandr for monitor hotplug. All themed to Ayu Dark.

**Tech Stack:** NixOS, home-manager, Stylix, DWM, picom, slstatus, dmenu, dunst, autorandr, LightDM

---

### Task 1: Strip KDE Plasma and Wayland from flake.nix

**Files:**
- Modify: `flake.nix`

**Step 1: Remove plasma-manager input**

Remove the `plasma-manager` input block and its reference in `outputs`:

```nix
# DELETE from inputs:
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
```

Remove `plasma-manager` from the `outputs` function arguments.

**Step 2: Remove plasma-manager from sharedModules**

In both `nixosConfigurations.laptop` and `nixosConfigurations.nixbox`, remove from `sharedModules`:

```nix
# DELETE this line from sharedModules:
                inputs.plasma-manager.homeModules.plasma-manager
```

**Step 3: Verify flake evaluates**

Run: `nix flake check --no-build 2>&1 | head -20`
Expected: No errors about plasma-manager

**Step 4: Commit**

```bash
git add flake.nix
git commit -m "refactor: remove plasma-manager flake input"
```

---

### Task 2: Replace SDDM + KDE Plasma with LightDM + DWM in host config

**Files:**
- Modify: `hosts/laptop/default.nix`

**Step 1: Remove KDE Plasma and SDDM**

Remove these blocks:

```nix
# DELETE all of these:
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
```

**Step 2: Add LightDM + slick-greeter + DWM**

Add in their place:

```nix
  # Display manager: LightDM with slick greeter
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "breeze_cursors";
      };
      extraConfig = ''
        background=/etc/lightdm/wallpaper.png
        draw-user-backgrounds=false
        font-name=Monaspace Neon 11
        show-hostname=false
      '';
    };
  };

  # Window manager: DWM
  services.xserver.windowManager.dwm.enable = true;

  # Autorandr for monitor hotplug
  services.autorandr.enable = true;

  # XDG portal for X11 (screensharing via x11 backend)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };
```

**Step 3: Verify syntax**

Run: `nix eval .#nixosConfigurations.laptop.config.services.xserver.windowManager.dwm.enable 2>&1`
Expected: `true`

**Step 4: Commit**

```bash
git add hosts/laptop/default.nix
git commit -m "feat: replace KDE Plasma/SDDM with LightDM + DWM"
```

---

### Task 3: Remove Wayland env vars from graphics.nix

**Files:**
- Modify: `modules/system/graphics.nix`

**Step 1: Remove Wayland session variables**

Delete the entire `environment.sessionVariables` block:

```nix
# DELETE:
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
```

**Step 2: Commit**

```bash
git add modules/system/graphics.nix
git commit -m "refactor: remove Wayland environment variables"
```

---

### Task 4: Clean up services.nix for X11

**Files:**
- Modify: `modules/system/services.nix`

**Step 1: Remove pipewire wantedBy overrides**

Delete these lines (X11 session starts PipeWire automatically via the user session):

```nix
# DELETE:
  systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  systemd.user.services.pipewire-pulse.wantedBy = [ "default.target" ];
```

**Step 2: Commit**

```bash
git add modules/system/services.nix
git commit -m "refactor: remove pipewire wantedBy overrides (X11 session handles)"
```

---

### Task 5: Strip KDE theming from theme.nix

**Files:**
- Modify: `modules/home/theme.nix`

**Step 1: Remove KDE color scheme generation**

Remove the entire `let` block that generates KDE color scheme (`colors`, `kdecolors`, `selectionColors`, `colorEffect`, `formatSection`, `colorSchemeFile` variables). Remove the `xdg.dataFile."color-schemes/AyuDark.colors"` line.

**Step 2: Remove programs.plasma block**

Delete the entire `programs.plasma` block (workspace, kwin, shortcuts).

**Step 3: Keep Stylix config, update targets**

The `stylix` block stays. Update targets to remove KDE/Qt references (already disabled, but clean up comments). Add dunst target:

```nix
    targets = {
      # Editors
      neovim.enable = true;
      zed.enable = true;

      # Shell and CLI
      fish.enable = true;
      btop.enable = true;
      fzf.enable = true;
      bat.enable = true;
      lazygit.enable = true;
      k9s.enable = true;
      yazi.enable = true;

      # Terminal
      ghostty.enable = true;

      # GTK apps
      gtk.enable = true;

      # Browser
      firefox.profileNames = [ "default" ];

      # Notifications
      dunst.enable = true;

      # KDE/Qt — disabled (no longer using KDE)
      kde.enable = false;
      qt.enable = false;
    };
```

The result is a much simpler file — just the `stylix` block and the `home.packages` line for nerd-fonts.

**Step 4: Commit**

```bash
git add modules/home/theme.nix
git commit -m "refactor: remove KDE theming, keep Stylix with dunst target"
```

---

### Task 6: Create DWM module directory and download patches

**Files:**
- Create: `modules/home/dwm/patches/` directory
- Create: 24 patch files

**Step 1: Create directory structure**

```bash
mkdir -p modules/home/dwm/patches
```

**Step 2: Download all patches**

Download each patch from dwm.suckless.org. Use the version closest to DWM 6.5/6.4 (nixpkgs has 6.6 but most patches target 6.4 or 6.5 — close enough to apply cleanly, conflicts will be fixed manually).

For each patch, use `fetchpatch` in the Nix derivation OR download the .diff files locally. **Local files are more reliable** since suckless.org URLs can change and patches may need manual fixups for 6.6 compatibility.

Download each patch:

```bash
cd modules/home/dwm/patches

# Core patches
curl -sLO https://dwm.suckless.org/patches/pertag/dwm-pertag-6.2.diff
curl -sLO https://dwm.suckless.org/patches/cool_autostart/dwm-cool-autostart-6.4.diff
curl -sLO https://dwm.suckless.org/patches/vanitygaps/dwm-vanitygaps-6.4.diff
curl -sLO https://dwm.suckless.org/patches/movestack/dwm-movestack-6.1.diff
curl -sLO https://dwm.suckless.org/patches/restartsig/dwm-restartsig-20180523-6.2.diff
curl -sLO https://dwm.suckless.org/patches/restoreafterrestart/dwm-restoreafterrestart-20220709-d3f93c7.diff
curl -sLO https://dwm.suckless.org/patches/swallow/dwm-swallow-6.3.diff
curl -sLO https://dwm.suckless.org/patches/attachbelow/dwm-attachbelow-6.2.diff

# Floating
curl -sLO https://dwm.suckless.org/patches/save_floats/dwm-save_floats-20181212-b69c870.diff
curl -sLO https://dwm.suckless.org/patches/fakefullscreen/dwm-fakefullscreen-20210714-138b405.diff

# Multi-monitor
curl -sLO https://dwm.suckless.org/patches/statusallmons/dwm-statusallmons-6.2.diff
curl -sLO https://dwm.suckless.org/patches/warp/dwm-warp-6.4.diff

# Bar
curl -sLO https://dwm.suckless.org/patches/systray/dwm-systray-6.4.diff
curl -sLO https://dwm.suckless.org/patches/statuscmd/dwm-statuscmd-20210405-67d76bd.diff
curl -sLO https://dwm.suckless.org/patches/smartborders/dwm-smartborders-6.2.diff

# Layouts
curl -sLO https://dwm.suckless.org/patches/centeredmaster/dwm-centeredmaster-20210107-67d76bd.diff
curl -sLO https://dwm.suckless.org/patches/deck/dwm-deck-6.2.diff
curl -sLO https://dwm.suckless.org/patches/fibonacci/dwm-fibonacci-6.2.diff
curl -sLO https://dwm.suckless.org/patches/cyclelayouts/dwm-cyclelayouts-20180524-6.2.diff

# Scratchpads
curl -sLO https://dwm.suckless.org/patches/namedscratchpads/dwm-namedscratchpads-6.2.diff

# App-specific
curl -sLO https://dwm.suckless.org/patches/steam/dwm-steam-6.2.diff
curl -sLO https://dwm.suckless.org/patches/focusonnetactive/dwm-focusonnetactive-6.2.diff
curl -sLO https://dwm.suckless.org/patches/sticky/dwm-sticky-6.5.diff

# Advanced
curl -sLO https://dwm.suckless.org/patches/cfacts/dwm-cfacts-6.2.diff
curl -sLO https://dwm.suckless.org/patches/xrdb/dwm-xrdb-6.4.diff
```

**Step 3: Verify downloads**

```bash
ls -la modules/home/dwm/patches/*.diff | wc -l
```
Expected: 24 (or close — some URLs may differ, fix manually)

**Step 4: Commit**

```bash
git add modules/home/dwm/patches/
git commit -m "feat: add DWM patch files (24 patches)"
```

---

### Task 7: Create DWM config.h with Stylix colors

**Files:**
- Create: `modules/home/dwm/config.h`

**Step 1: Write config.h**

This is the core DWM configuration. Colors will be placeholder hex values that the Nix build will replace with Stylix colors via `sed` in `postPatch`. Use `@BASE00@` style placeholders.

The config.h should include:
- Appearance: border width (2px), gaps (0 default), bar on top, fonts (Monaspace Neon + Symbols Nerd Font)
- Color schemes: `SchemeNorm` and `SchemeSel` using Stylix placeholders
- Tag names: 1-9
- Floating rules for Teams, Zoom, Steam, blueman, nm-connection-editor, pavucontrol
- Layouts: tile (default), monocle, fibonacci, deck, centeredmaster, floating
- Keybindings as defined in design doc
- Named scratchpad definitions (ghostty terminal)
- Swallow settings
- Autostart array (empty — handled by autostart.sh)

Write the full config.h with all patch-specific additions (pertag structs, vanitygaps variables, swallow fields in rules, scratchpad definitions, etc.).

**Important:** The config.h must be compatible with ALL 24 patches applied. Each patch adds its own fields/functions to config.h. The order patches are applied matters.

**Step 2: Commit**

```bash
git add modules/home/dwm/config.h
git commit -m "feat: add DWM config.h with Stylix color placeholders"
```

---

### Task 8: Create DWM Nix module (default.nix)

**Files:**
- Create: `modules/home/dwm/default.nix`

**Step 1: Write the DWM module**

This module:
1. Reads Stylix colors via `config.lib.stylix.colors`
2. Generates config.h by replacing `@BASE0x@` placeholders with actual hex values
3. Builds DWM with all patches applied
4. Sets the DWM package override at the system level via an overlay or `nixpkgs.overlays`

```nix
{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;

  # Generate config.h with Stylix colors substituted
  configFile = pkgs.substituteAll {
    src = ./config.h;
    base00 = "#${colors.base00}";
    base01 = "#${colors.base01}";
    base02 = "#${colors.base02}";
    base03 = "#${colors.base03}";
    base04 = "#${colors.base04}";
    base05 = "#${colors.base05}";
    base06 = "#${colors.base06}";
    base07 = "#${colors.base07}";
    base08 = "#${colors.base08}";
    base09 = "#${colors.base09}";
    base0A = "#${colors.base0A}";
    base0B = "#${colors.base0B}";
    base0C = "#${colors.base0C}";
    base0D = "#${colors.base0D}";
    base0E = "#${colors.base0E}";
    base0F = "#${colors.base0F}";
  };

  customDwm = pkgs.dwm.overrideAttrs (old: {
    patches = [
      # Order matters — apply foundational patches first, then additive ones
      ./patches/dwm-pertag-6.2.diff
      ./patches/dwm-cool-autostart-6.4.diff
      ./patches/dwm-vanitygaps-6.4.diff
      ./patches/dwm-movestack-6.1.diff
      ./patches/dwm-restartsig-20180523-6.2.diff
      ./patches/dwm-restoreafterrestart-20220709-d3f93c7.diff
      ./patches/dwm-attachbelow-6.2.diff
      ./patches/dwm-swallow-6.3.diff
      ./patches/dwm-save_floats-20181212-b69c870.diff
      ./patches/dwm-fakefullscreen-20210714-138b405.diff
      ./patches/dwm-statusallmons-6.2.diff
      ./patches/dwm-warp-6.4.diff
      ./patches/dwm-systray-6.4.diff
      ./patches/dwm-statuscmd-20210405-67d76bd.diff
      ./patches/dwm-smartborders-6.2.diff
      ./patches/dwm-centeredmaster-20210107-67d76bd.diff
      ./patches/dwm-deck-6.2.diff
      ./patches/dwm-fibonacci-6.2.diff
      ./patches/dwm-cyclelayouts-20180524-6.2.diff
      ./patches/dwm-namedscratchpads-6.2.diff
      ./patches/dwm-steam-6.2.diff
      ./patches/dwm-focusonnetactive-6.2.diff
      ./patches/dwm-sticky-6.5.diff
      ./patches/dwm-cfacts-6.2.diff
      ./patches/dwm-xrdb-6.4.diff
    ];

    postPatch = (old.postPatch or "") + ''
      cp ${configFile} config.def.h
    '';

    buildInputs = (old.buildInputs or []) ++ [
      pkgs.xorg.libXcursor  # for warp
      pkgs.xorg.libXinerama
    ];
  });
in
{
  imports = [
    ./picom.nix
    ./slstatus.nix
    ./dmenu.nix
    ./dunst.nix
  ];

  # Override the system DWM package
  nixpkgs.overlays = [
    (final: prev: {
      dwm = customDwm;
    })
  ];

  # Autostart script for DWM
  home.file.".dwm/autostart.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Kill existing instances to avoid duplicates on restart
      pkill -x picom; sleep 0.2
      pkill -x slstatus
      pkill -x dunst

      picom &
      slstatus &
      dunst &
      nm-applet &
      blueman-applet &
      feh --bg-fill ~/.wallpaper 2>/dev/null &
      autorandr --change &
    '';
  };

  # Packages needed for the DWM environment
  home.packages = with pkgs; [
    # Compositor and display
    feh
    autorandr
    arandr          # GUI for xrandr (manual monitor config)

    # System tray applets
    blueman               # Bluetooth manager
    networkmanagerapplet  # nm-applet

    # Audio control
    pavucontrol           # PulseAudio/PipeWire volume control GUI

    # Screenshot
    maim
    xclip
    xdotool     # For swallow patch (window PID detection)

    # Screen lock
    slock

    # X11 utilities
    xorg.xrandr
    xorg.xsetroot
    xorg.xprop
    xorg.xev      # For debugging keybindings
  ];
}
```

**Step 2: Commit**

```bash
git add modules/home/dwm/default.nix
git commit -m "feat: add DWM Nix module with overlay and autostart"
```

---

### Task 9: Create Picom module

**Files:**
- Create: `modules/home/dwm/picom.nix`

**Step 1: Write picom.nix**

```nix
{ config, pkgs, ... }:

let
  colors = config.lib.stylix.colors;
in
{
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    # Fading
    fade = true;
    fadeDelta = 8;
    fadeSteps = [ 0.06 0.06 ];

    # Shadows
    shadow = true;
    shadowOpacity = 0.6;
    shadowOffsets = [ (-8) (-8) ];
    shadowExclude = [
      "class_g = 'dwm'"
      "class_g = 'dmenu'"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    ];

    # Opacity
    activeOpacity = 1.0;
    inactiveOpacity = 0.95;

    opacityRules = [
      "100:class_g = 'firefox' && focused"
      "100:class_g = 'teams-for-linux'"
      "100:class_g = 'zoom'"
      "100:fullscreen"
    ];

    # Blur
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 5;
      };

      # Rounded corners
      corner-radius = 8;

      # Exclude from rounding
      rounded-corners-exclude = [
        "class_g = 'dwm'"
        "class_g = 'dmenu'"
      ];

      # Performance
      glx-no-stencil = true;
      glx-no-rebind-pixmap = true;
      use-damage = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;

      # Window type rules
      wintypes = {
        tooltip = { fade = true; shadow = false; opacity = 0.9; };
        dock = { shadow = false; clip-shadow-above = true; };
        dnd = { shadow = false; };
        popup_menu = { fade = true; shadow = true; opacity = 0.95; };
        dropdown_menu = { fade = true; shadow = true; opacity = 0.95; };
      };
    };
  };
}
```

**Step 2: Commit**

```bash
git add modules/home/dwm/picom.nix
git commit -m "feat: add picom compositor config with blur and rounded corners"
```

---

### Task 10: Create slstatus module

**Files:**
- Create: `modules/home/dwm/slstatus.nix`

**Step 1: Write slstatus.nix**

Since slstatus can't easily show Bluetooth device name (requires shell scripting), use **dwmblocks** instead for maximum flexibility. Actually — keep it simple and use slstatus for the basic segments. For Bluetooth device name, add a small helper script.

```nix
{ config, pkgs, ... }:

let
  # Helper script for bluetooth device name
  btDevice = pkgs.writeShellScript "bt-device" ''
    ${pkgs.bluez}/bin/bluetoothctl info 2>/dev/null | ${pkgs.gnugrep}/bin/grep "Name:" | ${pkgs.coreutils}/bin/cut -d' ' -f2- || echo ""
  '';

  customSlstatus = pkgs.slstatus.overrideAttrs (old: {
    postPatch = ''
      cp ${slstatusConfig} config.def.h
    '';
  });

  slstatusConfig = pkgs.writeText "slstatus-config.h" ''
    /* See LICENSE file for copyright and license details. */

    /* interval between updates (in ms) */
    const unsigned int interval = 2000;

    /* text to show if no value can be retrieved */
    static const char unknown_str[] = "n/a";

    /* maximum output string length */
    #define MAXLEN 2048

    static const struct arg args[] = {
      /* function       format          argument */
      { run_command,    " %s |",        "${btDevice}" },
      { wifi_essid,    " %s |",        "wlan0" },
      { battery_perc,  " BAT %s%% |",  "BAT0" },
      { cpu_perc,      " CPU %s%% |",  NULL },
      { ram_perc,      " MEM %s%% |",  NULL },
      { vol_perc,      " VOL %s%% |",  "/dev/snd/controlC0" },
      { datetime,      " %s ",         "%a %b %d %H:%M" },
    };
  '';
in
{
  nixpkgs.overlays = [
    (final: prev: {
      slstatus = customSlstatus;
    })
  ];

  home.packages = [ customSlstatus ];
}
```

**Note:** The `wifi_essid` interface name may differ — check with `ip link` after boot. Could be `wlp1s0` or similar. Adjust during testing.

**Step 2: Commit**

```bash
git add modules/home/dwm/slstatus.nix
git commit -m "feat: add slstatus config with BT, wifi, battery, CPU, RAM, volume, date"
```

---

### Task 11: Create dmenu module

**Files:**
- Create: `modules/home/dwm/dmenu.nix`

**Step 1: Write dmenu.nix**

Theme dmenu with Stylix colors at build time:

```nix
{ config, pkgs, ... }:

let
  colors = config.lib.stylix.colors;

  customDmenu = pkgs.dmenu.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i 's/\[SchemeNorm\] = .*/[SchemeNorm] = { "#${colors.base05}", "#${colors.base00}" },/' config.def.h
      sed -i 's/\[SchemeSel\] = .*/[SchemeSel] = { "#${colors.base00}", "#${colors.base0D}" },/' config.def.h
      sed -i 's/\[SchemeOut\] = .*/[SchemeOut] = { "#${colors.base05}", "#${colors.base02}" },/' config.def.h
      sed -i 's/"monospace:size=10"/"Monaspace Neon:size=11, Symbols Nerd Font:size=11"/' config.def.h
    '';
  });
in
{
  nixpkgs.overlays = [
    (final: prev: {
      dmenu = customDmenu;
    })
  ];

  home.packages = [ customDmenu ];
}
```

**Step 2: Commit**

```bash
git add modules/home/dwm/dmenu.nix
git commit -m "feat: add dmenu config with Stylix Ayu Dark colors"
```

---

### Task 12: Create dunst module

**Files:**
- Create: `modules/home/dwm/dunst.nix`

**Step 1: Write dunst.nix**

Stylix has a dunst target that auto-themes colors. We just need to enable dunst and set layout preferences:

```nix
{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 350;
        height = 150;
        offset = "20x20";
        origin = "top-right";
        frame_width = 2;
        corner_radius = 8;
        font = "Monaspace Neon 11";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 30;
        icon_position = "left";
        max_icon_size = 48;
        mouse_left_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
    };
  };
}
```

Stylix's `dunst.enable = true` in theme.nix handles the color scheme automatically.

**Step 2: Commit**

```bash
git add modules/home/dwm/dunst.nix
git commit -m "feat: add dunst notification config"
```

---

### Task 13: Update home-manager default.nix to import DWM module

**Files:**
- Modify: `modules/home/default.nix`

**Step 1: Add DWM import**

Add to the `imports` list:

```nix
    ./dwm
```

**Step 2: Remove KDE-specific packages if any**

Check if `vscode-fhs` or any other KDE-specific package should be removed. (vscode-fhs is not KDE-specific — keep it.)

**Step 3: Verify no duplicate packages**

Packages like `picom`, `dmenu`, `slstatus`, `dunst` are declared in the DWM submodules — don't duplicate them in the main `home.packages`.

**Step 4: Commit**

```bash
git add modules/home/default.nix
git commit -m "feat: import DWM module into home-manager config"
```

---

### Task 14: Build and fix patch conflicts

**Step 1: Attempt first build**

```bash
sudo nixos-rebuild build --flake . 2>&1 | tail -50
```

Expected: Patch application failures. Most suckless patches target DWM 6.2-6.4, but nixpkgs has 6.6. Patches will likely have fuzz or reject.

**Step 2: Fix rejected patches**

For each failing patch:
1. Read the error to identify which hunk failed
2. Download the DWM 6.6 source: `nix-build '<nixpkgs>' -A dwm.src`
3. Apply the patch manually to understand the conflict
4. Edit the `.diff` file to fix line offsets / context
5. Re-attempt build

This is the most time-consuming task. Work through patches one at a time. Common issues:
- Line number offsets (fix context lines)
- `config.def.h` changes (our `postPatch` replaces it anyway, so patches that only touch config.def.h can be simplified)
- Function signatures changed between versions

**Step 3: Re-attempt build after each fix**

```bash
sudo nixos-rebuild build --flake . 2>&1 | tail -50
```

Repeat until build succeeds.

**Step 4: Commit fixed patches**

```bash
git add modules/home/dwm/patches/
git commit -m "fix: adapt DWM patches for 6.6 compatibility"
```

---

### Task 15: Write the complete config.h

**Files:**
- Modify: `modules/home/dwm/config.h`

After all patches are applied cleanly, the config.def.h in the build output will show what fields are expected. Use that as a reference to write the final config.h with:

**Step 1: Extract patched config.def.h**

```bash
nix-build '<nixpkgs>' -A dwm.src -o /tmp/dwm-src
cd /tmp/dwm-src
# Apply patches in order, then look at config.def.h
```

Or build with a dummy config.h and inspect the intermediate output.

**Step 2: Write config.h with all patch fields**

Key sections to include:
- `@BASE0x@` placeholders for all colors (substituted by Nix)
- `static const unsigned int borderpx = 2;`
- `static const unsigned int gappih = 0;` (vanitygaps — 0 by default)
- `static const unsigned int gappiv = 0;`
- `static const unsigned int gappoh = 0;`
- `static const unsigned int gappov = 0;`
- `static const int swallowfloating = 0;` (swallow)
- `static const int smartborders = 1;` (smartborders)
- `static const unsigned int systrayspacing = 4;` (systray)
- `static const unsigned int systraypinning = 0;`
- All floating rules with `isterminal` and `swallowfloating` fields
- Layout array including fibonacci, deck, centeredmaster
- Keybindings as specified in design doc
- Named scratchpad definitions

**Step 3: Build and verify**

```bash
sudo nixos-rebuild build --flake . 2>&1 | tail -20
```
Expected: Successful build

**Step 4: Commit**

```bash
git add modules/home/dwm/config.h
git commit -m "feat: complete DWM config.h with all keybindings and rules"
```

---

### Task 16: Full system build and switch

**Step 1: Build without switching**

```bash
sudo nixos-rebuild build --flake .
```
Expected: Successful build with no errors

**Step 2: Switch to new configuration**

```bash
sudo nixos-rebuild switch --flake .
```

**Step 3: Reboot and log in**

After reboot, LightDM should show. Select "dwm" session and log in.

**Step 4: Verify core functionality**

- [ ] DWM launches with bar visible
- [ ] Mod+Return opens ghostty terminal
- [ ] Mod+d opens dmenu
- [ ] Picom running (check rounded corners, transparency)
- [ ] nm-applet visible in systray
- [ ] blueman-applet visible in systray
- [ ] slstatus showing info in bar
- [ ] Tags work (Mod+1 through Mod+9)
- [ ] Floating rules work (launch Steam, pavucontrol)

**Step 5: Commit any hotfixes**

```bash
git add -A
git commit -m "fix: post-boot adjustments for DWM environment"
```

---

### Task 17: Test monitor hotplug with autorandr

**Step 1: Save laptop-only profile**

```bash
autorandr --save mobile
```

**Step 2: Plug in external monitor and save profile**

```bash
xrandr  # verify monitor detected
autorandr --save docked
```

**Step 3: Test hotplug**

Unplug and replug monitor. autorandr should auto-switch.

**Step 4: Test presentation mode**

Plug into a projector/TV. Verify it extends/mirrors correctly. Save profile if needed:

```bash
autorandr --save presentation
```

---

### Task 18: Test screensharing and video calling

**Step 1: Test screensharing in browser**

Open Firefox or Chrome, go to a screensharing test site. X11 screensharing should show all windows/screens without portal issues.

**Step 2: Test Teams video call**

- Launch teams-for-linux
- Start a call
- Enable camera
- Enable screensharing
- Verify floating rules work (call window floats)

**Step 3: Test Bluetooth audio**

- Connect Bluetooth headset via blueman-applet
- Start a Teams call
- Verify audio output goes to headset (A2DP → HFP switch)
- Verify microphone works
- Verify switching back to A2DP after call ends

**Step 4: Document any issues and fix**

---

### Task 19: Set LightDM wallpaper

**Step 1: Copy wallpaper to system location**

LightDM runs as root, so it needs a system-accessible wallpaper:

```nix
# In hosts/laptop/default.nix, add:
  environment.etc."lightdm/wallpaper.png".source = /path/to/wallpaper.png;
```

Or use a wallpaper from a Nix package. For now, a dark solid color works if no wallpaper is chosen.

**Step 2: Set user wallpaper**

Place a wallpaper at `~/.wallpaper` — feh will set it on DWM start via autostart.sh.

**Step 3: Rebuild and verify**

```bash
sudo nixos-rebuild switch --flake .
```

---

### Task 20: Final cleanup and commit

**Step 1: Review all changes**

```bash
git diff HEAD~15..HEAD --stat
```

**Step 2: Test everything one more time**

- [ ] LightDM greeter looks good
- [ ] DWM starts cleanly
- [ ] All keybindings work
- [ ] Monitor hotplug works
- [ ] Screensharing works
- [ ] Bluetooth audio + mic works in Teams
- [ ] Picom effects (blur, rounded corners, fading)
- [ ] All Stylix theming consistent (terminal, bar, dmenu, dunst, GTK apps)
- [ ] Steam launches correctly (floating, no jitter)
- [ ] Named scratchpad (Mod+grave) works
- [ ] Screenshot (Mod+Print) works

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete DWM + X11 migration from KDE Plasma 6 Wayland"
```
