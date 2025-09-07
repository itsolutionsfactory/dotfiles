#!/bin/bash

# Script to install and manage GNOME extensions

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running in a container
is_container() {
    [ -f /.dockerenv ] || [ -f /run/.containerenv ]
}

# Function to check if GNOME is available
check_gnome() {
    if ! command_exists gnome-shell; then
        echo "❌ GNOME Shell is not installed"
        return 1
    fi
    return 0
}

# Function to install required packages
install_dependencies() {
    echo "Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y \
        gnome-shell-extensions \
        gnome-shell-extension-prefs \
        gnome-shell-extension-manager \
        chrome-gnome-shell
}

# Function to install an extension
install_extension() {
    local extension_id=$1
    local extension_name=$2
    
    echo "Installing $extension_name..."
    
    # Try using gnome-shell-extension-manager if available
    if command_exists gnome-shell-extension-manager; then
        echo "Installing $extension_name via gnome-shell-extension-manager..."
        if gnome-shell-extension-manager install "$extension_id"; then
            echo "✓ $extension_name installed successfully"
            return 0
        else
            echo "❌ Failed to install $extension_name via gnome-shell-extension-manager"
        fi
    fi
    
    # Fallback to gnome-extensions command if available
    if command_exists gnome-extensions; then
        echo "Attempting to install via gnome-extensions command..."
        if gnome-extensions install "$extension_id" --force; then
            echo "✓ $extension_name installed via gnome-extensions"
            return 0
        else
            echo "❌ Failed to install via gnome-extensions command"
        fi
    fi
    
    # Manual installation instructions as last resort
    echo "⚠️  Manual installation required for $extension_name"
    echo "   Please visit: https://extensions.gnome.org/extension/$extension_id/"
    echo "   Click 'Install' and follow the browser prompts"
    
    return 1
}

# Function to enable an extension
enable_extension() {
    local extension_id=$1
    local extension_name=$2
    
    echo "Enabling $extension_name..."
    if command_exists gnome-extensions; then
        gnome-extensions enable "$extension_id"
    else
        echo "❌ gnome-extensions command not found"
        return 1
    fi
}

# Function to set extension settings
set_extension_setting() {
    local extension_id=$1
    local key=$2
    local value=$3
    
    echo "Setting $extension_id $key to $value..."
    if command_exists gnome-extensions; then
        gnome-extensions prefs "$extension_id" --set "$key" "$value"
    else
        echo "❌ gnome-extensions command not found"
        return 1
    fi
}

# Function to unbind a keyboard shortcut
unbind_shortcut() {
    local binding=$1
    local description=$2
    
    echo "Unbinding $description shortcut..."
    gsettings set org.gnome.shell.keybindings "$binding" "[]"
}

# Function to set default terminal
set_default_terminal() {
    local terminal=$1
    
    echo "Setting $terminal as default terminal..."
    # Set default terminal for x-terminal-emulator
    sudo update-alternatives --set x-terminal-emulator "$(which $terminal)"
    
    # Set default terminal for GNOME
    gsettings set org.gnome.desktop.default-applications.terminal exec "$terminal"
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg ""
}

# Main script
echo "Checking environment..."
echo "--------------------------------"

# Check if running in container
if is_container; then
    echo "❌ Running in container environment - skipping GNOME extension installation"
    exit 0
fi

# Check if GNOME is available
if ! check_gnome; then
    echo "❌ GNOME Shell is not available - skipping GNOME extension installation"
    exit 0
fi

# Install dependencies
install_dependencies

# List of extensions to install
# Format: "extension_id" "extension_name"
extensions=(
    "horizontal-workspaces@gnome-shell-extensions.gcampax.github.com" "Horizontal Workspaces"
    "workspace-matrix@martin.zurowietz.de" "Workspace Matrix"
    "gsnap@micahosborne" "GSNAP"
    "Vitals@CoreCoding.com" "Vitals"
    "switcher@landau.fi" "Switcher"
)

# Install and enable extensions
echo -e "\nInstalling extensions..."
echo "--------------------------------"
for ((i=0; i<${#extensions[@]}; i+=2)); do
    extension_id="${extensions[i]}"
    extension_name="${extensions[i+1]}"
    
    install_extension "$extension_id" "$extension_name"
    enable_extension "$extension_id" "$extension_name"
done

# Unbind default Super+A shortcut and configure Switcher
echo -e "\nConfiguring Switcher shortcut..."
echo "--------------------------------"
unbind_shortcut "show-applications" "Show Applications (Super+A)"
set_extension_setting "switcher@landau.fi" "shortcut" "<Super>a"

# Set Kitty as default terminal
# echo -e "\nSetting up default terminal..."
# echo "--------------------------------"
# if command_exists kitty; then
#     set_default_terminal "kitty"
#     echo "✓ Kitty set as default terminal"
# else
#     echo "❌ Kitty not found - skipping default terminal setup"
# fi

# Install GSNAP configuration using stow
echo -e "\nSetting up GSNAP configuration..."
echo "--------------------------------"
if command_exists stow; then
    cd "$(dirname "$0")/gSnap"
    stow -t "$HOME/.config" .config
    echo "✓ GSNAP configuration installed"
else
    echo "❌ stow not found - skipping GSNAP configuration"
    echo "Please install stow: sudo apt-get install stow"
fi

echo -e "\nExtension installation complete!"
echo "=================================="
echo "For extensions that couldn't be installed automatically:"
echo "1. Visit https://extensions.gnome.org"
echo "2. Search for each extension by name"
echo "3. Click 'Install' and follow browser prompts"
echo "4. Or use: gnome-extensions install <extension-id>"
echo ""
echo "You may need to log out and log back in for all extensions to take effect."
echo "You can manage extensions using: gnome-extensions-app" 