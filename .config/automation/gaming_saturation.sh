#!/bin/bash

# xrandr --listmonitors for monitor names
# set -xe

# Display name (replace with your actual display identifier)
DISPLAY_NAME="DisplayPort-0"

# Check arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [on|off]"
    exit 1
fi

STATE="$1"

# Validate input
if [ "$STATE" != "on" ] && [ "$STATE" != "off" ]; then
    echo "Invalid argument. Use 'on' or 'off'."
    exit 1
fi

# Apply settings based on state
if [ "$STATE" == "on" ]; then
    vibrant-cli DisplayPort-0 1.7
    echo "Vibrancy turned on."
elif [ "$STATE" == "off" ]; then
    vibrant-cli DisplayPort-0 1.0
    echo "Vibrancy turned off."
fi
