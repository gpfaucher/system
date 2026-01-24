#!/usr/bin/env bash
# Test script for River WM suspend/resume fix
# Usage: ./test-river-resume.sh

set -e

echo "=== River WM Suspend/Resume Fix - Test Script ==="
echo

# Step 1: Rebuild system
echo "[1/5] Rebuilding NixOS configuration..."
sudo nixos-rebuild switch --flake .#laptop

echo
echo "[2/5] Verifying user service exists..."
if systemctl --user list-unit-files | grep -q "river-resume-hook"; then
    echo "✓ river-resume-hook.service found"
else
    echo "✗ river-resume-hook.service NOT found"
    exit 1
fi

echo
echo "[3/5] Testing manual trigger..."
echo "Triggering service manually..."
systemctl --user start river-resume-hook.service
echo "Check for notification: 'River - Restoring tiling layout...'"
sleep 3

echo
echo "[4/5] Checking service status..."
systemctl --user status river-resume-hook.service --no-pager || true

echo
echo "[5/5] Testing suspend/resume..."
echo "READY TO TEST: Please run 'systemctl suspend' to suspend the system."
echo "After waking up:"
echo "  1. Check if windows tile correctly"
echo "  2. Look for the notification"
echo "  3. Open new windows to verify tiling works"
echo "  4. Test layout switching: Super+T, Super+M"
echo
echo "To view logs after resume: journalctl --user -u river-resume-hook -n 20"
echo
echo "=== Test Complete ===" 
