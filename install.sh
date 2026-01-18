#!/bin/bash
set -e

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

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
    cd "$DOTFILES"
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

# Make scripts executable
chmod +x ~/.local/bin/*

# Enable services
log "Enabling services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Change shell to zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    log "Changing shell to zsh..."
    chsh -s $(which zsh)
fi

# Rust toolchain
log "Setting up Rust..."
rustup default stable

# TPM for tmux
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    log "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Create directories
mkdir -p ~/work ~/notes ~/Pictures/Screenshots ~/Videos/Recordings

log "Done!"
log ""
log "Next steps:"
log "  1. Reboot"
log "  2. Login to TTY (River starts automatically)"
log "  3. Run: envycontrol -s hybrid"
log "  4. Reboot again"
log "  5. In tmux, press prefix+I to install plugins"
