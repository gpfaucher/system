# Plan: Make NixOS More Windows-Like and User-Friendly

## Goal
Transform the current Hyprland-based tiling WM setup into a polished, user-friendly desktop experience similar to Windows - using pure Nix/NixOS (no Flatpak).

---

## Current State
- Using **Hyprland** (tiling window manager) - power-user focused
- Using **greetd** (TTY login) - no graphical login screen
- KDE/Plasma config exists in `kde.nix` but is **disabled** in `greetd.nix`
- No GUI software center
- Manual display management with kanshi

---

## Implementation Plan

### Phase 1: Enable KDE Plasma 6 Desktop

**1.1 Modify `modules/core/greetd.nix` -> rename to `display.nix`:**
```nix
{pkgs, ...}: {
  # Enable SDDM (KDE's display manager) with Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };

  # Enable KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Optional: Auto-login for faster boot (like Windows)
  services.displayManager.autoLogin = {
    enable = true;
    user = "gabriel";
  };
}
```

**1.2 Add `kde.nix` to home-manager imports:**
```nix
# modules/home/default.nix - add:
./kde.nix
```

**1.3 Update flake.nix to include plasma-manager:**
```nix
inputs = {
  # ... existing inputs
  plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
};
```

---

### Phase 2: Enhance KDE Configuration

**2.1 Expand `modules/home/kde.nix` with Windows-like settings:**
```nix
programs.plasma = {
  enable = true;

  workspace = {
    colorScheme = "BreezeDark";
    lookAndFeel = "org.kde.breezedark.desktop";
    clickItemTo = "select";  # Single-click to select (Windows default)
  };

  panels = [{
    location = "bottom";
    height = 44;
    widgets = [
      "org.kde.plasma.kickoff"      # Start menu
      "org.kde.plasma.icontasks"    # Taskbar
      "org.kde.plasma.systemtray"   # System tray
      "org.kde.plasma.digitalclock" # Clock
    ];
  }];

  kwin = {
    effects.shakeCursor.enable = true;
    titlebarButtons = {
      left = ["on-all-desktops"];
      right = ["minimize" "maximize" "close"];
    };
  };

  shortcuts = {
    # Windows-like shortcuts
    "kwin"."Window Maximize" = "Meta+Up";
    "kwin"."Window Minimize" = "Meta+Down";
    "kwin"."Switch Window Left" = "Meta+Left";
    "kwin"."Switch Window Right" = "Meta+Right";
  };
};
```

---

### Phase 3: Windows-Like File Management & Apps (Pure Nix)

**3.1 Replace Thunar with Dolphin (KDE native):**
```nix
# modules/home/packages/gui-apps.nix - replace:
xfce.thunar  # remove this
# with:
kdePackages.dolphin
kdePackages.dolphin-plugins
kdePackages.ark          # Archive manager (like WinRAR)
kdePackages.gwenview     # Image viewer
kdePackages.okular       # PDF viewer
kdePackages.spectacle    # Screenshot tool
kdePackages.kate         # Text editor (like Notepad++)
```

---

### Phase 4: System Settings & Control Panel

**4.1 Add KDE system utilities:**
```nix
environment.systemPackages = with pkgs; [
  kdePackages.systemsettings
  kdePackages.kde-cli-tools
  kdePackages.kinfocenter       # System info (like Windows "About")
  kdePackages.partitionmanager  # Disk management
  kdePackages.plasma-nm         # Network manager
  kdePackages.bluedevil         # Bluetooth manager
  kdePackages.powerdevil        # Power management
];
```

---

### Phase 5: Boot Polish

**5.1 Add boot splash screen:**
```nix
boot.plymouth = {
  enable = true;
  theme = "breeze";  # KDE-themed boot splash
};
```

---

## Summary of Changes

| File | Change |
|------|--------|
| `flake.nix` | Add plasma-manager input |
| `modules/core/greetd.nix` | Enable SDDM + Plasma 6 |
| `modules/home/default.nix` | Import `kde.nix` |
| `modules/home/kde.nix` | Expand with panels, shortcuts, Windows-like config |
| `modules/core/packages.nix` | Add KDE system utilities |
| `modules/home/packages/gui-apps.nix` | Replace Thunar with Dolphin & KDE apps |

---

## Optional: Keep Hyprland as Alternative

You can have both! Use KDE by default but keep Hyprland available:
- SDDM lets you choose session at login
- Keep Hyprland config intact
- Switch between them as needed

---

## What You Get (Windows-Like Features)

1. **Graphical login screen** (SDDM) - like Windows lock screen
2. **Start menu + taskbar** - KDE Kickoff at bottom
3. **File explorer** - Dolphin with Windows-like behavior
4. **System settings** - GUI control panel
5. **Familiar shortcuts** - Win+E, Win+Arrow, etc.
6. **Boot splash** - Plymouth themed splash screen
7. **Notifications** - Native KDE notifications
8. **Single-click behavior** - Optional Windows-style file selection
9. **All from Nix** - No Flatpak, pure declarative config
