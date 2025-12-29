#!/bin/bash
# Fedora Workstation - Dead Simple Dev Setup
# Just run: curl -sL <url> | bash
# Or: chmod +x setup.sh && ./setup.sh

set -e

echo "=== Fedora Dev Setup ==="

# Get script directory (or current dir if piped)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null)" && pwd 2>/dev/null || pwd)"

# === 1. Install essentials ===
echo "[+] Installing packages..."
sudo dnf install -y \
    fish starship \
    git gh lazygit \
    neovim \
    ripgrep fd-find fzf jq \
    btop \
    wl-clipboard

# === 2. Create directories ===
echo "[+] Creating directories..."
mkdir -p ~/.config/fish
mkdir -p ~/.ssh
mkdir -p ~/Work
mkdir -p ~/Notes

# === 3. SSH config ===
echo "[+] Setting up SSH..."
if [ ! -f ~/.ssh/config ]; then
    cat > ~/.ssh/config << 'SSHEOF'
# Paddock Staging
Host paddock-staging
    HostName 3.65.122.203
    User ec2-user
    IdentityFile ~/.ssh/paddock-ec2

Host paddock-staging-tunnel
    HostName 3.65.122.203
    User ec2-user
    IdentityFile ~/.ssh/paddock-ec2
    LocalForward 5432 staging-postgres.cpuuywqis1x2.eu-central-1.rds.amazonaws.com:5432
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Paddock Production
Host paddock-prod
    HostName 3.124.157.22
    User ec2-user
    IdentityFile ~/.ssh/paddock-ec2

Host paddock-prod-tunnel
    HostName 3.124.157.22
    User ec2-user
    IdentityFile ~/.ssh/paddock-ec2
    LocalForward 5433 production-postgres.cbas6us2c8g8.eu-central-1.rds.amazonaws.com:5432
    LocalForward 6380 production-redis.0dod70.0001.euc1.cache.amazonaws.com:6379
    ServerAliveInterval 60
    ServerAliveCountMax 3

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
SSHEOF
    chmod 600 ~/.ssh/config
    echo "    Created ~/.ssh/config"
else
    echo "    ~/.ssh/config exists, skipping"
fi

# === 4. Git config ===
echo "[+] Setting up Git..."
if [ ! -f ~/.gitconfig ]; then
    cat > ~/.gitconfig << 'GITEOF'
[user]
    name = Gabriel
    email = your-email@example.com

[init]
    defaultBranch = master

[core]
    editor = nvim

[pull]
    rebase = true

[push]
    autoSetupRemote = true

[alias]
    st = status
    co = checkout
    br = branch
    lg = log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=short
GITEOF
    echo "    Created ~/.gitconfig - UPDATE YOUR EMAIL!"
else
    echo "    ~/.gitconfig exists, skipping"
fi

# === 5. Fish config ===
echo "[+] Setting up Fish..."
cat > ~/.config/fish/config.fish << 'FISHEOF'
# Disable greeting
set fish_greeting

# Vi mode
set -g fish_key_bindings fish_vi_key_bindings

# Starship prompt
starship init fish | source

# Git abbreviations
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gd 'git diff'
abbr -a gs 'git status'
abbr -a gl 'git log --oneline -20'
abbr -a lg 'lazygit'

# SSH tunnels
alias staging-tunnel "ssh -fN paddock-staging-tunnel && echo 'Staging: localhost:5432'"
alias staging-tunnel-stop "pkill -f 'ssh.*paddock-staging-tunnel'"
alias prod-tunnel "ssh -fN paddock-prod-tunnel && echo 'Prod: localhost:5433 (pg), :6380 (redis)'"
alias prod-tunnel-stop "pkill -f 'ssh.*paddock-prod-tunnel'"
FISHEOF

# === 6. Starship config (minimal) ===
echo "[+] Setting up Starship..."
cat > ~/.config/starship.toml << 'STAREOF'
add_newline = false
format = "$directory$git_branch$git_status$character"

[character]
success_symbol = "[>](green)"
error_symbol = "[>](red)"

[directory]
style = "blue"
truncation_length = 3

[git_branch]
format = "[$branch]($style) "
style = "bright-black"

[git_status]
format = "[$all_status$ahead_behind]($style)"
style = "red"
STAREOF

# === 7. Set fish as default shell ===
echo "[+] Setting Fish as default shell..."
if [ "$SHELL" != "/usr/bin/fish" ]; then
    sudo chsh -s /usr/bin/fish "$USER"
    echo "    Shell changed. Logout and login again."
fi

# === Done ===
echo ""
echo "=== DONE ==="
echo ""
echo "Next steps:"
echo "  1. Copy your SSH keys to ~/.ssh/"
echo "  2. Update email in ~/.gitconfig"
echo "  3. Logout/login for fish shell"
echo ""
echo "Your tunnels:"
echo "  staging-tunnel      # Postgres on localhost:5432"
echo "  prod-tunnel         # Postgres :5433, Redis :6380"
echo "  *-tunnel-stop       # Stop tunnel"
