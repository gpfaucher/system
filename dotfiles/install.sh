#!/bin/bash
set -e

DOTFILES="$HOME/.dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }

# Check if running as root
[[ $EUID -eq 0 ]] && error "Don't run as root"

# Install paru if not present
if ! command -v paru &> /dev/null; then
    log "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
fi

# Install pacman packages
log "Installing pacman packages..."
paru -S --needed - < "$DOTFILES/packages/pacman.txt"

# Install AUR packages
log "Installing AUR packages..."
paru -S --needed - < "$DOTFILES/packages/aur.txt"

# Stow dotfiles
log "Stowing dotfiles..."
cd "$DOTFILES"
for dir in */; do
    [[ "$dir" == "packages/" ]] && continue
    stow -v "$dir"
done

# Enable services
log "Enabling services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Rust toolchain
log "Setting up Rust..."
rustup default stable

# Create work directories
mkdir -p ~/work ~/notes

log "Done! Reboot and start Hyprland"
