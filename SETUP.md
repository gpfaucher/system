# Setup Guide

## Quick Install

```bash
./install.sh
```

Then logout and login again.

## Manual Setup

### 1. Install paru

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si
```

### 2. Install packages

```bash
paru -S river wlroots xorg-xwayland fish starship ghostty \
  fuzzel fnott waylock wlogout kanshi wdisplays \
  grim slurp wl-clipboard wf-recorder gammastep brightnessctl playerctl \
  polkit-gnome networkmanager blueman pipewire pipewire-pulse wireplumber \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
  yazi fd ripgrep fzf imagemagick firefox btop neovim lazygit npm \
  wideriver wpaperd cliphist zellij ueberzugpp bluetuith
```

### 3. Copy configs

```bash
cp -r river fish ghostty zellij fuzzel fnott waylock wlogout yazi kanshi wpaperd gammastep nvim ~/.config/
cp starship/starship.toml ~/.config/
cp git/gitconfig ~/.gitconfig
cp bin/* ~/.local/bin/
chmod +x ~/.local/bin/* ~/.config/river/init
```

### 4. Post-install

```bash
# Set fish as default shell
chsh -s /usr/bin/fish

# Add to groups
sudo usermod -aG input,video $USER

# Enable services
sudo systemctl enable --now NetworkManager bluetooth
```

## Configuration

Edit these for your setup:
- `~/.config/kanshi/config` - monitor layout
- `~/.config/gammastep/config.ini` - location coords
- `~/.gitconfig` - name and email

## Keybindings

Press `Super + /` for the cheatsheet.

| Key | Action |
|-----|--------|
| Super + Return | Terminal |
| Super + A | App launcher |
| Super + Q | Close window |
| Super + H/J/K/L | Focus window |
| Super + Shift + H/J/K/L | Swap window |
| Super + 1-9 | Switch workspace |
| Super + F | Fullscreen |
| Super + Space | Float toggle |
| Super + Escape | Lock |
| Super + Shift + E | Power menu |
