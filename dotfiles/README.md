# Arch Linux Dotfiles

Terminal-first Hyprland setup for software engineering.

## Quick Start

```bash
# Clone to ~/.dotfiles
git clone <repo> ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap
./install.sh
```

## Structure

```
dotfiles/
├── hyprland/      # Window manager
├── waybar/        # Status bar
├── nvim/          # Neovim (lazy.nvim)
├── zsh/           # Shell config
├── starship/      # Prompt
├── foot/          # Terminal
├── tmux/          # Multiplexer
├── yazi/          # File manager
├── fuzzel/        # Launcher
├── mako/          # Notifications
├── kanshi/        # Display profiles
├── wlogout/       # Power menu
├── swaylock/      # Lock screen
├── git/           # Git config
├── scripts/       # Utility scripts
├── packages/      # Package lists
└── install.sh     # Bootstrap script
```

## Key Bindings

### Hyprland (Super = mod)
| Key | Action |
|-----|--------|
| Super+Return | Terminal (foot) |
| Super+D | Launcher (fuzzel) |
| Super+Q | Close window |
| Super+HJKL | Focus windows |
| Super+Shift+HJKL | Move windows |
| Super+1-9 | Workspaces |
| Super+F | Fullscreen |
| Super+Shift+Space | Float toggle |
| Print | Screenshot area |

### Neovim (Space = leader)
| Key | Action |
|-----|--------|
| jk | Exit insert |
| Ctrl+hjkl | Window nav |
| leader+sf | Find files |
| leader+sg | Live grep |
| leader+gg | LazyGit |
| leader+e | File tree |
| leader+f | Oil (files) |
| s/S | Flash jump |

## NVIDIA

Uses envycontrol for GPU switching:

```bash
# Check status
envycontrol --status

# Modes
envycontrol -s integrated  # Battery (AMD only)
envycontrol -s hybrid      # Default (AMD + NVIDIA offload)
envycontrol -s nvidia      # Performance (NVIDIA only)
```

Reboot required after switching.

## Post-Install

1. Reboot after install.sh
2. Login to TTY, run `Hyprland`
3. Set GPU mode: `envycontrol -s hybrid`
4. Install tmux plugins: prefix + I

## Maintenance

```bash
# Update system
paru -Syu

# Sync dotfiles
cd ~/.dotfiles && git pull && stow */
```
