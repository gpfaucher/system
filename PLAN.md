# Plan: Make NixOS More User-Friendly with GNOME

## Goal
Transform the current Hyprland-based tiling WM setup into a polished, user-friendly desktop experience using GNOME - the "just works" approach.

---

## Current State
- Using **Hyprland** (tiling window manager) - power-user focused
- Using **greetd** (TTY login) - no graphical login screen
- KDE/Plasma config exists in `kde.nix` but is disabled
- Manual display management with kanshi

---

## Why GNOME over KDE?
- **Simpler** - works great out of the box, fewer settings to tweak
- **Better laptop support** - excellent touchpad gestures (3-finger swipe)
- **Easier NixOS config** - native dconf support via Home Manager, no extra flake inputs
- **Polished UX** - consistent, distraction-free workflow

---

## Implementation Plan

### Phase 1: Enable GNOME Desktop

**1.1 Modify `modules/core/greetd.nix`:**
```nix
{pkgs, ...}: {
  # Enable GDM (GNOME's display manager)
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Optional: Auto-login
  services.displayManager.autoLogin = {
    enable = true;
    user = "gabriel";
  };
}
```

**1.2 Exclude bloat (optional):**
```nix
environment.gnome.excludePackages = with pkgs; [
  gnome-tour
  gnome-music
  epiphany        # GNOME Web browser
  geary           # Email client
  totem           # Video player (if using VLC)
];
```

---

### Phase 2: GNOME Configuration via Home Manager

**2.1 Create `modules/home/gnome.nix`:**
```nix
{pkgs, ...}: {
  # Enable dconf for GNOME settings
  dconf.enable = true;

  dconf.settings = {
    # Dark theme
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };

    # Touchpad gestures
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    # Workspaces on all monitors
    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
    };

    # Favorite apps in dock
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "org.gnome.Terminal.desktop"
      ];
    };
  };

  # GNOME Extensions
  home.packages = with pkgs; [
    gnomeExtensions.appindicator      # System tray icons
    gnomeExtensions.dash-to-dock      # macOS-style dock (optional)
    gnomeExtensions.blur-my-shell     # Visual polish
  ];

  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = false;
    enabled-extensions = [
      "appindicatorsupport@rgcjonas.gmail.com"
    ];
  };
}
```

**2.2 Add to `modules/home/default.nix`:**
```nix
./gnome.nix
```

---

### Phase 3: GNOME Apps (Replace Current Apps)

**3.1 Update `modules/home/packages/gui-apps.nix`:**
```nix
# Remove:
xfce.thunar

# Add GNOME apps:
gnome-text-editor    # Simple text editor
loupe                # Image viewer (GNOME 45+)
gnome-calculator
gnome-system-monitor
gnome-disk-utility
file-roller          # Archive manager
evince               # PDF viewer (or use existing)
```

---

### Phase 4: Polish

**4.1 Boot splash:**
```nix
boot.plymouth = {
  enable = true;
  theme = "spinner";  # Clean GNOME-style spinner
};
```

**4.2 Fonts (GNOME defaults):**
```nix
fonts.packages = with pkgs; [
  cantarell-fonts      # GNOME default UI font
  noto-fonts
  noto-fonts-emoji
];
```

---

## Summary of Changes

| File | Change |
|------|--------|
| `modules/core/greetd.nix` | Enable GDM + GNOME |
| `modules/home/default.nix` | Import `gnome.nix` |
| `modules/home/gnome.nix` | New file - dconf settings, extensions |
| `modules/home/packages/gui-apps.nix` | Replace Thunar with Nautilus/GNOME apps |

---

## Optional: Keep Hyprland as Alternative

GDM allows session selection at login:
- GNOME (default)
- GNOME on Xorg
- Hyprland (if kept installed)

---

## What You Get

1. **Graphical login** - GDM with user avatar
2. **Activities overview** - Hot corner or Super key
3. **App grid** - Like a phone launcher
4. **Touchpad gestures** - 3-finger swipe for workspaces
5. **Settings app** - Full GUI system settings
6. **File manager** - Nautilus (clean, simple)
7. **Notifications** - Native GNOME notifications
8. **Extensions** - System tray, dock, blur effects
9. **Just works** - Minimal config needed
