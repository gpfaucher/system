# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a NixOS configuration repository using Nix Flakes with a modular architecture:

- **Multi-host setup**: Supports multiple machines (`nexus` and `voyager` hosts)
- **Modular structure**: Core system modules and home-manager modules are separated
- **Home Manager integration**: User-level configuration managed through home-manager
- **Stylix theming**: Uses Catppuccin Mocha theme across the system

## Key Directory Structure

- `flake.nix`: Main flake configuration defining system builds and inputs
- `hosts/`: Host-specific configurations (nexus, voyager)
- `modules/core/`: System-level NixOS modules (hardware, networking, security, etc.)
- `modules/home/`: User-level home-manager modules (desktop environment, applications)
- `modules/home/nvim/`: Neovim configuration using nixvim

## Common Commands

### Building and Switching
```bash
# Build and switch system configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Build without switching
sudo nixos-rebuild build --flake .#<hostname>

# Update flake inputs
nix flake update
```

### Development and Testing
```bash
# Check flake
nix flake check

# Show flake outputs
nix flake show

# Enter development shell (if defined)
nix develop
```

### Host Management
Available hosts: `nexus`, `voyager`

Example: `sudo nixos-rebuild switch --flake .#nexus`

## Configuration Details

- **Username**: `gabriel` (hardcoded in flake.nix:19)
- **Theme**: Catppuccin Mocha via Stylix
- **Desktop Environment**: Hyprland with Waybar
- **Editor**: Neovim with extensive plugin configuration
- **Shell**: Fish with custom scripts

## Module Organization

- Core modules handle system-level configuration (Docker, hardware, networking, etc.)
- Home modules handle user applications and desktop environment
- Neovim has its own modular structure with core settings, keymaps, and plugins