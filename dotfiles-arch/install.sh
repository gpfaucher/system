#!/bin/bash
# Arch Linux River WM Dotfiles Installer
# Run this after base Arch install

set -e

echo "=== River WM Dotfiles Installer ==="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Do not run this script as root"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Install pacman packages
print_status "Installing pacman packages..."
sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm \
    river wlroots xorg-xwayland \
    fish starship alacritty \
    fuzzel fnott waylock wlogout \
    kanshi wdisplays wlr-randr wl-mirror \
    grim slurp wl-clipboard wf-recorder \
    gammastep brightnessctl playerctl \
    polkit-gnome networkmanager blueman \
    pipewire pipewire-pulse wireplumber \
    xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
    yazi ffmpegthumbnailer poppler fd ripgrep fzf jq imagemagick \
    firefox btop libnotify ffmpeg \
    git base-devel

# Step 2: Install paru if not present
if ! command -v paru &> /dev/null; then
    print_status "Installing paru AUR helper..."
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
fi

# Step 3: Install AUR packages
print_status "Installing AUR packages..."
paru -S --needed --noconfirm \
    wideriver \
    wpaperd \
    cliphist \
    ghostty-bin \
    zellij \
    ueberzugpp \
    bluetuith \
    impala

# Step 4: Create config directories
print_status "Creating config directories..."
mkdir -p ~/.config/{river,fish,ghostty,alacritty,zellij,fuzzel,fnott,waylock,wlogout,yazi,kanshi,wpaperd,gammastep}
mkdir -p ~/.local/bin
mkdir -p ~/.ssh
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Videos/Recordings
mkdir -p ~/Work
mkdir -p ~/Notes
mkdir -p ~/Downloads

# Step 5: Copy configs
print_status "Installing dotfiles..."
cp "$SCRIPT_DIR/river/init" ~/.config/river/
cp "$SCRIPT_DIR/fish/config.fish" ~/.config/fish/
cp "$SCRIPT_DIR/ghostty/config" ~/.config/ghostty/
cp "$SCRIPT_DIR/alacritty/alacritty.toml" ~/.config/alacritty/
cp "$SCRIPT_DIR/zellij/config.kdl" ~/.config/zellij/
cp "$SCRIPT_DIR/fuzzel/fuzzel.ini" ~/.config/fuzzel/
cp "$SCRIPT_DIR/fnott/fnott.ini" ~/.config/fnott/
cp "$SCRIPT_DIR/waylock/waylock.toml" ~/.config/waylock/
cp "$SCRIPT_DIR/wlogout/"* ~/.config/wlogout/
cp "$SCRIPT_DIR/yazi/"* ~/.config/yazi/
cp "$SCRIPT_DIR/kanshi/config" ~/.config/kanshi/
cp "$SCRIPT_DIR/wpaperd/config.toml" ~/.config/wpaperd/
cp "$SCRIPT_DIR/gammastep/config.ini" ~/.config/gammastep/
cp "$SCRIPT_DIR/starship/starship.toml" ~/.config/starship.toml

# Git config
if [ -f "$SCRIPT_DIR/git/gitconfig" ]; then
    cp "$SCRIPT_DIR/git/gitconfig" ~/.gitconfig
    print_warning "Update ~/.gitconfig with your name and email!"
fi

# SSH config (only if not exists to avoid overwriting keys)
if [ ! -f ~/.ssh/config ]; then
    cp "$SCRIPT_DIR/ssh/config" ~/.ssh/config
    chmod 600 ~/.ssh/config
    print_warning "Update ~/.ssh/config with your hosts and keys!"
else
    print_warning "~/.ssh/config exists, not overwriting. See ssh/config for template."
fi

# Step 6: Install scripts
print_status "Installing scripts..."
cp "$SCRIPT_DIR/bin/"* ~/.local/bin/
chmod +x ~/.local/bin/*
chmod +x ~/.config/river/init

# Step 7: Create wallpaper
print_status "Creating gruvbox wallpaper..."
convert -size 3840x2400 xc:'#282828' ~/.config/wpaperd/wallpaper.png

# Step 8: Enable services
print_status "Enabling services..."
sudo systemctl enable --now NetworkManager || true
sudo systemctl enable --now bluetooth || true
systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

# Step 9: Add user to groups
print_status "Adding user to required groups..."
sudo usermod -aG input "$USER"
sudo usermod -aG video "$USER"

# Step 10: Change shell to fish
print_status "Setting fish as default shell..."
if [ "$SHELL" != "/usr/bin/fish" ]; then
    chsh -s /usr/bin/fish
    print_warning "Shell changed to fish. Please logout and login again."
fi

# Done
echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Logout and login again (for fish shell and groups)"
echo "  2. From tty1, fish will auto-start River"
echo "  3. Or type 'river' to start manually"
echo ""
echo "  Press Super+/ for keybind cheatsheet"
echo ""
print_warning "Edit ~/.config/kanshi/config for your monitors"
print_warning "Edit ~/.config/gammastep/config.ini for your location"
print_warning "Edit ~/.gitconfig with your name and email"
print_warning "Copy your SSH keys to ~/.ssh/ and update ~/.ssh/config"
