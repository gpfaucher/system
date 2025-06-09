#!/usr/bin/env fish
set -l is_yay_installed (command -q yay; and echo 1; or echo 0)
set -l starting_dir (pwd)
set -l yay_flags --noconfirm

echo "Installing core build tools..."
sudo pacman -S --needed $yay_flags git base-devel unzip zip tar go rust nodejs npm python python-pip cmake clang python-pytest python-virtualenv python-pip python-setuptools python-wheel
if test $is_yay_installed -eq 0
    echo "YAY not found. Installing..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si $yay_flags
    cd $starting_dir
    rm -rf /tmp/yay
end
echo "$(tput setaf 2)Installing core system packages...$(tput sgr0)"
yay -Syu $yay_flags nvidia-open mesa uv google-chrome-stable foot hyprland fish tmux neovim vim tree htop nnn fd ripgrep fzf lazygit lazydocker stow visual-studio-code-bin aws-cli-v2
echo "$(tput setaf 2)Installing window managment packages...$(tput sgr0)"
yay -Syu $yay_flags hyprland hyprlock hyprcursor hyprgraphics hyprutils hyprwayland-scanner hyprland-qt-support hyprland-qtutils xdg-desktop-portal-hyprland sddm lightdm lightdm-gtk-greeter foot
echo "$(tput setaf 2)Installing audio packages...$(tput sgr0)"
yay -S $yay_flags pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber
echo "$(tput setaf 2)Installing utility packages...$(tput sgr0)"
yay -S $yay_flags dunst grim slurp wl-clipboard wofi xdg-utils polkit-kde-agent
echo "$(tput setaf 2)Installing networking packages...$(tput sgr0)"
yay -S $yay_flags networkmanager iwd openssh wget curl
echo "$(tput setaf 2)Installing font packages...$(tput sgr0)"
yay -S $yay_flags otf-monaspace-nerd ttf-liberation gnu-free-fonts
echo "$(tput setaf 2)Installing productivity packages...$(tput sgr0)"
yay -S $yay_flags teams-for-linux ticktick
