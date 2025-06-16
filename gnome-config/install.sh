#!/bin/bash

# Check if running in Docker
if [ -f /.dockerenv ]; then
    echo "Running in Docker environment - skipping GNOME workspace shortcuts setup"
    exit 0
fi

# Check if running in a container
if [ -f /run/.containerenv ]; then
    echo "Running in container environment - skipping GNOME workspace shortcuts setup"
    exit 0
fi

# Check if GNOME is available
if ! command -v gsettings &> /dev/null; then
    echo "gsettings not found - skipping GNOME workspace shortcuts setup"
    exit 0
fi

# Check if running in a graphical environment
if [ -z "$DISPLAY" ]; then
    echo "No display detected - skipping GNOME workspace shortcuts setup"
    exit 0
fi

# Run the workspace shortcuts setup script
echo "Setting up GNOME workspace shortcuts..."
"$(dirname "$0")/setup-workspace-shortcuts.sh"

# Run the extensions installation script
echo -e "\nSetting up GNOME workspace extensions..."
"$(dirname "$0")/install-extensions.sh" 