#!/usr/bin/env bash
# System rebuild script for NixOS with home-manager

set -e

cd "$(dirname "$0")/.."

echo "🔨 Rebuilding NixOS system..."
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  nixos-rebuild switch --flake .#laptop
else
  echo "Note: This script requires sudo to rebuild the system."
  echo "You will be prompted for your password."
  echo ""
  sudo nixos-rebuild switch --flake .#laptop
fi

echo ""
echo "✓ System rebuild complete!"
echo ""
echo "If neovim was updated, restart any running neovim instances to use the new configuration."
