#!/bin/bash

# Function to get connected monitors
get_connected_monitors() {
    xrandr --listmonitors | grep -oP '^[0-9]+\s+\K\w+' | grep -v "^$"
}

# Get the list of connected monitors
MONITORS=($(get_connected_monitors))

# Check if exactly two monitors are connected
if [ ${#MONITORS[@]} -ne 2 ]; then
    echo "Error: This script requires exactly 2 monitors. Connected monitors: ${#MONITORS[@]}"
    exit 1
fi

# Assign monitor names
PRIMARY_MONITOR=${MONITORS[0]}
SECONDARY_MONITOR=${MONITORS[1]}

# Define resolution (adjust as needed)
PRIMARY_RESOLUTION="1920x1080"
SECONDARY_RESOLUTION="1920x1080"

# Define positions
PRIMARY_POSITION="0x0"
SECONDARY_POSITION="1920x0" # Positioned to the right of the primary monitor

# Apply settings
echo "Configuring monitors..."
xrandr --output $PRIMARY_MONITOR --mode $PRIMARY_RESOLUTION --primary --pos $PRIMARY_POSITION
xrandr --output $SECONDARY_MONITOR --mode $SECONDARY_RESOLUTION --pos $SECONDARY_POSITION

echo "Configuration complete."
