#!/usr/bin/env bash
# Initialize Beads for multi-agent NixOS system
set -e

REPO_ROOT="${1:-.}"
cd "$REPO_ROOT"

echo "🔮 Initializing Beads for OpenCode agent system..."

# Check if bd command exists
if ! command -v bd &> /dev/null; then
    echo "❌ Error: 'bd' command not found. Install Beads first."
    exit 1
fi

# Check if already initialized
if [ -d ".beads" ]; then
    echo "⚠️  .beads/ already exists. Skipping initialization."
    echo "Run 'bd status' to check current state."
    exit 0
fi

# Initialize Beads
bd init

# Verify structure
if [ ! -d ".beads/issues" ]; then
    echo "❌ Error: Beads initialization failed (.beads/issues not created)"
    exit 1
fi

echo "✅ Beads initialized successfully!"
echo "   Tasks location: .beads/issues/"
echo "   Cache location: .beads/cache/ (gitignored)"
echo ""
echo "Next steps:"
echo "  1. Review .gitignore for .beads/cache/ entry"
echo "  2. Run: bd create \"Initial task\" -p 0"
echo "  3. Commit .beads/issues/ to git"
