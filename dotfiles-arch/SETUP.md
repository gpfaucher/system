# Arch Linux River WM Setup Guide

This guide will set up your River WM environment on Arch Linux, ported from your NixOS configuration.

## 1. Install Arch Linux

Use `archinstall` for a quick base installation:

```bash
archinstall
```

Choose:
- **Profile**: Minimal
- **Bootloader**: systemd-boot or GRUB
- **Network**: NetworkManager
- **Audio**: PipeWire

Reboot into your new system.

## 2. Install Required Packages

### Core packages (pacman)

```bash
# Update system
sudo pacman -Syu

# River WM and Wayland core
sudo pacman -S river wlroots xorg-xwayland

# Terminal and shell
sudo pacman -S fish starship alacritty

# Wayland utilities
sudo pacman -S fuzzel fnott waylock wlogout
sudo pacman -S kanshi wdisplays wlr-randr wl-mirror
sudo pacman -S grim slurp wl-clipboard wf-recorder
sudo pacman -S gammastep brightnessctl playerctl

# System utilities
sudo pacman -S polkit-gnome networkmanager blueman
sudo pacman -S pipewire pipewire-pulse wireplumber
sudo pacman -S xdg-desktop-portal-wlr xdg-desktop-portal-gtk

# Fonts
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

# File manager and preview
sudo pacman -S yazi ffmpegthumbnailer poppler fd ripgrep fzf jq imagemagick

# Other essentials
sudo pacman -S firefox btop libnotify ffmpeg

# Git and development
sudo pacman -S git base-devel
```

### AUR packages

Install an AUR helper first:

```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru
```

Then install AUR packages:

```bash
# River layout generator
paru -S wideriver

# Wallpaper daemon
paru -S wpaperd

# Clipboard manager
paru -S cliphist

# Ghostty terminal
paru -S ghostty-bin

# Zellij terminal multiplexer
paru -S zellij

# Image preview for terminal
paru -S ueberzugpp

# Optional TUI apps
paru -S bluetuith impala
```

## 3. Install Dotfiles

Clone or copy your dotfiles:

```bash
# Create config directories
mkdir -p ~/.config/{river,fish,ghostty,alacritty,zellij,fuzzel,fnott,waylock,wlogout,yazi,kanshi,wpaperd,gammastep}
mkdir -p ~/.local/bin

# Copy configs (adjust path to where you have the dotfiles)
cp dotfiles-arch/river/init ~/.config/river/
cp dotfiles-arch/fish/config.fish ~/.config/fish/
cp dotfiles-arch/ghostty/config ~/.config/ghostty/
cp dotfiles-arch/alacritty/alacritty.toml ~/.config/alacritty/
cp dotfiles-arch/zellij/config.kdl ~/.config/zellij/
cp dotfiles-arch/fuzzel/fuzzel.ini ~/.config/fuzzel/
cp dotfiles-arch/fnott/fnott.ini ~/.config/fnott/
cp dotfiles-arch/waylock/waylock.toml ~/.config/waylock/
cp dotfiles-arch/wlogout/* ~/.config/wlogout/
cp dotfiles-arch/yazi/* ~/.config/yazi/
cp dotfiles-arch/kanshi/config ~/.config/kanshi/
cp dotfiles-arch/wpaperd/config.toml ~/.config/wpaperd/
cp dotfiles-arch/gammastep/config.ini ~/.config/gammastep/
cp dotfiles-arch/starship/starship.toml ~/.config/starship.toml

# Install scripts
cp dotfiles-arch/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*
chmod +x ~/.config/river/init

# Make sure ~/.local/bin is in PATH (fish should handle this)
```

## 4. Set Up Wallpaper

Copy your wallpaper to the expected location:

```bash
# Create a gruvbox solid color wallpaper (or use your own)
convert -size 3840x2400 xc:#282828 ~/.config/wpaperd/wallpaper.png

# Or copy your existing wallpaper
# cp /path/to/your/wallpaper.png ~/.config/wpaperd/wallpaper.png
```

## 5. Configure Fish as Default Shell

```bash
# Change default shell to fish
chsh -s /usr/bin/fish

# Logout and login again
```

## 6. Enable Services

```bash
# NetworkManager (should already be enabled from archinstall)
sudo systemctl enable --now NetworkManager

# Bluetooth
sudo systemctl enable --now bluetooth

# PipeWire (user service, runs automatically)
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

## 7. Start River

Add to `/etc/profile.d/river.sh` for auto-login from tty1:

```bash
# Fish handles this via config.fish, but as backup:
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
    exec river
fi
```

Or just type `river` from tty1 (fish config auto-starts it).

## 8. Post-Install Tweaks

### Update Kanshi for your monitors

Edit `~/.config/kanshi/config` with your actual monitor names:

```bash
# Find your monitor names
wlr-randr
```

### Update Gammastep location

Edit `~/.config/gammastep/config.ini` with your coordinates.

### SSH config (optional)

If you need your SSH tunnels:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create ~/.ssh/config with your hosts
# Copy SSH keys as needed
```

## 9. Configure Git and SSH

### Git config

```bash
# Copy template
cp dotfiles-arch/git/gitconfig ~/.gitconfig

# Edit with your info
nvim ~/.gitconfig
```

Update your name and email in the `[user]` section.

### SSH config

```bash
# Copy template (if no existing config)
cp dotfiles-arch/ssh/config ~/.ssh/config
chmod 600 ~/.ssh/config

# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy public key to clipboard for GitHub
cat ~/.ssh/id_ed25519.pub | wl-copy

# Copy your existing keys from backup
# cp /path/to/backup/.ssh/id_* ~/.ssh/
# chmod 600 ~/.ssh/id_*
```

The SSH config template includes your Paddock tunnels. Update hostnames and key paths as needed.

## Directory Structure

```
~/.config/
├── river/
│   └── init              # River WM config (executable)
├── fish/
│   └── config.fish       # Fish shell config
├── ghostty/
│   └── config            # Ghostty terminal config
├── alacritty/
│   └── alacritty.toml    # Alacritty backup terminal
├── zellij/
│   └── config.kdl        # Zellij multiplexer config
├── fuzzel/
│   └── fuzzel.ini        # App launcher config
├── fnott/
│   └── fnott.ini         # Notification daemon config
├── waylock/
│   └── waylock.toml      # Screen lock config
├── wlogout/
│   ├── layout            # Power menu layout
│   └── style.css         # Power menu styling
├── yazi/
│   ├── yazi.toml         # File manager config
│   └── keymap.toml       # File manager keybindings
├── kanshi/
│   └── config            # Display auto-configuration
├── wpaperd/
│   ├── config.toml       # Wallpaper config
│   └── wallpaper.png     # Your wallpaper
├── gammastep/
│   └── config.ini        # Night light config
└── starship.toml         # Shell prompt config

~/.local/bin/
├── screenshot-area       # Screenshot scripts
├── screenshot-screen
├── screenshot-save
├── screenrecord-area     # Recording scripts
├── screenrecord-screen
├── screenrecord-save
└── river-keybinds        # Keybind cheatsheet

~/.gitconfig              # Git configuration
~/.ssh/
├── config                # SSH host configuration
├── id_ed25519            # Your private key
├── id_ed25519.pub        # Your public key
└── paddock-ec2           # Work-specific keys
```

## Key Bindings Reference

Press `Super + /` to see all keybindings.

### Essential

| Keys | Action |
|------|--------|
| Super + Return | Terminal (ghostty) |
| Super + A | App launcher (fuzzel) |
| Super + Q | Close window |
| Super + Escape | Lock screen |
| Super + Shift + E | Power menu |

### Navigation

| Keys | Action |
|------|--------|
| Super + H/J/K/L | Focus left/down/up/right |
| Super + Shift + H/J/K/L | Swap window |
| Super + 1-9 | Switch workspace |
| Super + Shift + 1-9 | Move window to workspace |

### Layout

| Keys | Action |
|------|--------|
| Super + F | Fullscreen |
| Super + Space | Toggle float |
| Super + M | Monocle layout |
| Super + T | Tiled layout |
| Super + Ctrl + H/L | Shrink/grow master |

### Screenshots/Recording

| Keys | Action |
|------|--------|
| Print | Screenshot area to clipboard |
| Super + R | Record area to GIF (toggle) |
| Super + Shift + S | Screenshot area to clipboard |

## Troubleshooting

### River doesn't start

```bash
# Check for errors
river 2>&1 | tee /tmp/river.log
```

### No audio

```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Fonts not showing

```bash
# Rebuild font cache
fc-cache -fv
```

### Waylock won't unlock

Make sure your user is in the `input` group:

```bash
sudo usermod -aG input $USER
# Logout and login again
```

### Screen recording not working

```bash
# Install missing dependencies
paru -S wf-recorder ffmpeg
```

## Theme: Gruvbox Dark Medium

All configs use Gruvbox Dark Medium colors:

- Background: `#282828`
- Foreground: `#d5c4a1`
- Blue (accent): `#83a598`
- Red (urgent): `#fb4934`
- Green: `#b8bb26`
- Yellow: `#fabd2f`
