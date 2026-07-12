#!/usr/bin/env bash
# Copy this repository to the NixOS server for a local rebuild there.

set -euo pipefail

cd "$(dirname "$0")/.."

server="${1:-gabriel@100.88.195.11}"

if grep -R "REPLACE-.*-UUID" hosts/server/hardware.nix >/dev/null; then
  echo "Refusing to sync: hosts/server/hardware.nix still contains placeholder UUIDs." >&2
  exit 1
fi

rsync -az --delete \
  --exclude .git \
  --exclude .direnv \
  --exclude codex \
  --exclude outputs \
  --exclude result \
  ./ "$server:~/system/"
