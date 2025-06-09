#! /usr/bin/env fish

set -l has_yay_installed (command -q yay; and echo 1; or echo 0)
set -l starting_dir (pwd)
sudo pacman -S --needed git base-devel

if test $has_yay_installed -eq 1
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si

    cd $starting_dir
    rm -rf /tmp/yay
end
