#!/bin/bash

# Script to check and set up GNOME workspace keyboard shortcuts
# This script verifies and sets up Super+Number shortcuts for workspace navigation
# and Super+Shift+Number for moving windows between workspaces
# Also sets up Super+T for opening Kitty terminal

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a shortcut is set correctly
check_shortcut() {
    local action=$1
    local workspace_num=$2
    local expected_binding=$3
    local current_binding=$(gsettings get org.gnome.desktop.wm.keybindings "${action}-${workspace_num}")
    
    if [ "$current_binding" = "$expected_binding" ]; then
        echo "✓ ${action} ${workspace_num} shortcut is correctly set"
        return 0
    else
        echo "✗ ${action} ${workspace_num} shortcut is not set correctly"
        echo "  Current: ${current_binding}"
        echo "  Expected: ${expected_binding}"
        return 1
    fi
}

# Function to set a shortcut
set_shortcut() {
    local action=$1
    local workspace_num=$2
    local binding=$3
    gsettings set org.gnome.desktop.wm.keybindings "${action}-${workspace_num}" "$binding"
    echo "✓ Set ${action} ${workspace_num} shortcut to ${binding}"
}

# Function to check and set custom shortcut
check_custom_shortcut() {
    local name=$1
    local command=$2
    local binding=$3
    
    # Get current custom keybindings
    local current_bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    
    # Check if the shortcut already exists
    if [[ "$current_bindings" != *"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/"* ]]; then
        # Add new binding to the array
        if [ "$current_bindings" = "@as []" ]; then
            # If array is empty, create new array with single element
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/']"
        else
            # If array has elements, append new element
            current_bindings=${current_bindings%]}
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${current_bindings}, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/']"
        fi
    fi
    
    # Set the shortcut properties
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/ name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/ command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/ binding "$binding"
    
    echo "✓ Set custom shortcut ${name} to ${binding}"
}

# Check and set shortcuts for workspaces 1-9
echo "Checking workspace navigation shortcuts..."
echo "--------------------------------"

needs_fix=0
for i in {1..9}; do
    if ! check_shortcut "switch-to-workspace" $i "['<Super>${i}']"; then
        needs_fix=1
    fi
done

echo -e "\nChecking window movement shortcuts..."
echo "--------------------------------"
for i in {1..9}; do
    if ! check_shortcut "move-to-workspace" $i "['<Super><Shift>${i}']"; then
        needs_fix=1
    fi
done

if [ $needs_fix -eq 1 ]; then
    echo -e "\nFixing shortcuts..."
    echo "--------------------------------"
    for i in {1..9}; do
        set_shortcut "switch-to-workspace" $i "['<Super>${i}']"
        set_shortcut "move-to-workspace" $i "['<Super><Shift>${i}']"
    done
    echo -e "\nAll shortcuts have been set:"
    echo "- Super+Number: Switch to workspace"
    echo "- Super+Shift+Number: Move window to workspace"
else
    echo -e "\nAll shortcuts are correctly configured!"
fi

# Check if Kitty is installed
echo -e "\nChecking Kitty installation..."
echo "--------------------------------"
if ! command_exists kitty; then
    echo "❌ Kitty is not installed or not in PATH"
    echo "Please install Kitty first:"
    echo "  sudo apt install kitty"
    exit 1
else
    echo "✓ Kitty is installed"
    KITTY_PATH=$(which kitty)
    echo "  Path: $KITTY_PATH"
fi

# Set up Kitty terminal shortcut
echo -e "\nSetting up Kitty terminal shortcut..."
echo "--------------------------------"
check_custom_shortcut "kitty" "$KITTY_PATH" "<Super>t"

# Verify the changes
echo -e "\nVerifying changes..."
echo "--------------------------------"
echo "Workspace navigation shortcuts:"
for i in {1..9}; do
    check_shortcut "switch-to-workspace" $i "['<Super>${i}']"
done

echo -e "\nWindow movement shortcuts:"
for i in {1..9}; do
    check_shortcut "move-to-workspace" $i "['<Super><Shift>${i}']"
done

echo -e "\nCustom shortcuts:"
gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kitty/ binding 