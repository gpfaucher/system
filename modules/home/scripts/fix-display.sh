#!/bin/sh
# Simple script to enable internal display when external is disconnected

# Check if external display is connected
if wlr-randr | grep -q "DP-1.*enabled"; then
    # External display is connected, disable internal if it's on
    if wlr-randr | grep -q "eDP-1.*enabled"; then
        wlr-randr --output eDP-1 --off
    fi
else
    # External display is not connected, enable internal if it's off
    if ! wlr-randr | grep -q "eDP-1.*enabled"; then
        wlr-randr --output eDP-1 --on --scale 1.0
    fi
fi