#!/usr/bin/env bash
# System rebuild script for NixOS with home-manager.
# Auto-detects the flake host from the machine hostname.

set -e

cd "$(dirname "$0")/.."

# Allow override: ./scripts/rebuild.sh laptop  or  ./scripts/rebuild.sh workstation
HOST="${1:-$(hostname)}"

case "$HOST" in
  laptop|workstation) ;;
  *)
    echo "Unknown host: $HOST"
    echo "Usage: $0 [laptop|workstation]"
    exit 1
    ;;
esac

echo "🔨 Rebuilding NixOS system for host: $HOST"
echo ""

if [ "$EUID" -eq 0 ]; then
  nixos-rebuild switch --flake ".#$HOST"
else
  echo "Note: This script requires sudo to rebuild the system."
  echo "You will be prompted for your password."
  echo ""
  sudo nixos-rebuild switch --flake ".#$HOST"
fi

echo ""
echo "✓ System rebuild complete!"
echo ""
echo "If neovim was updated, restart any running neovim instances to use the new configuration."
