# Arch Linux Dotfiles

Minimal River WM setup for software engineering. No bar, terminal-first.

## Quick Start

```bash
git clone <repo> ~/.dotfiles
cd ~/.dotfiles
./install.sh
# Reboot, login to TTY (auto-starts River)
```

## Structure

```
├── river/         # Window manager (wlroots, dwm-style)
├── nvim/          # Neovim (lazy.nvim, LSP, telescope, harpoon)
├── zsh/           # Shell + starship prompt
├── foot/          # Terminal
├── tmux/          # Multiplexer
├── yazi/          # File manager
├── fuzzel/        # Launcher
├── mako/          # Notifications
├── kanshi/        # Monitor hotplug
├── wlogout/       # Power menu
├── swaylock/      # Lock screen
├── git/           # Git config
├── scripts/       # Utilities
└── packages/      # pacman.txt + aur.txt
```

## Keybinds

Press `Super+/` for full cheatsheet.

| Key | Action |
|-----|--------|
| Super+Return | Terminal |
| Super+A | Launcher |
| Super+HJKL | Focus windows |
| Super+Shift+HJKL | Move windows |
| Super+Q | Close |
| Super+F | Fullscreen |
| Super+1-9 | Workspaces |
| Super+P | Scratchpad |
| Super+S | System status |
| Super+Escape | Lock |
| Super+Shift+E | Power menu |
| Print | Screenshot area |
| Super+R | Record GIF |

## No Bar

Status via `Super+S` notification showing:
- Battery %
- WiFi network
- Volume
- GPU mode
- Time

Or use TUI apps:
- `Super+Shift+B` btop
- `Super+Shift+T` bluetuith
- `Super+Shift+I` impala (wifi)
- `Super+Shift+A` pulsemixer

## Screenshare

Works via xdg-desktop-portal-wlr. For Teams/Firefox:
1. Portal starts automatically with River
2. Select "Share Screen" in app
3. Pick window or output

## NVIDIA

```bash
envycontrol -s integrated  # Battery
envycontrol -s hybrid      # Default
envycontrol -s nvidia      # Performance
```
Use `Super+Shift+N` for interactive toggle.

## Monitor Hotplug

Kanshi auto-switches profiles. Edit `~/.config/kanshi/config`:

```
profile laptop {
    output eDP-1 enable scale 1.6
}

profile docked {
    output eDP-1 disable
    output DP-1 enable scale 1.0
}
```

## MX Master

Works via Bluetooth. Use `solaar` for battery/config.

## Post-Install

1. `./install.sh`
2. Reboot
3. `envycontrol -s hybrid` then reboot
4. Pair Bluetooth: `Super+Shift+T`
5. Tmux plugins: `prefix+I`
