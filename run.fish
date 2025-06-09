#!/usr/bin/env fish

set -l is_yay_installed (command -q yay; and echo 1; or echo 0)
set -l starting_dir (pwd)
set -l pacman_flags --noconfirm

echo "Installing core build tools..."
sudo pacman -S --needed $pacman_flags git base-devel unzip zip tar go rust nodejs npm python python-pip cmake clang python-pytest python-virtualenv python-pip python-setuptools python-wheel

if test $is_yay_installed -eq 0
    echo "Yay not found. Installing..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si $pacman_flags

    cd $starting_dir
    rm -rf /tmp/yay
end

echo "$(tput setaf 2)--------- Installing all system packages ---------$(tput sgr0)"
yay -Syu $pacman_flags nvidia-open mrsa uv google-chrome-stable foot hyprland fish tmux neovim vim tree htop nnn fd ripgrep fzf lazygit lazydocker stow visual-studio-code-bin aws-cli-v2 hyprlock hyprcursor hyprgraphics hyprutils hyprwayland-scanner hyprland-qt-support hyprland-qtutils xdg-desktop-portal-hyprland sddm lightdm lightdm-gtk-greeter pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber dunst grim slurp wl-clipboard wofi xdg-utils polkit-kde-agent networkmanager iwd openssh wget curl otf-monaspace-nerd ttf-liberation gnu-free-fonts teams-for-linux ticktick bluez bluez-utils overskride

echo "$(tput setaf 2)--------- Setting up systemd services  ---------$(tput sgr0)"
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth
