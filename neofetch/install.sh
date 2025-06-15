#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="neofetch"

# Catppuccin Mocha color scheme
# Base colors
BASE="\033[0m"
TEXT="\033[38;2;205;214;244m"      # Text
SUBTEXT="\033[38;2;166;173;200m"   # Subtext
OVERLAY="\033[38;2;108;112;134m"   # Overlay
SURFACE="\033[38;2;49;50;68m"      # Surface
BASE_COLOR="\033[38;2;30;30;46m"   # Base
MANTLE="\033[38;2;24;24;37m"       # Mantle
CRUST="\033[38;2;17;17;27m"        # Crust

# Accent colors
RED="\033[38;2;243;139;168m"       # Red
GREEN="\033[38;2;166;227;161m"     # Green
YELLOW="\033[38;2;249;226;175m"    # Yellow
BLUE="\033[38;2;137;180;250m"      # Blue
PINK="\033[38;2;245;194;231m"      # Pink
MAUVE="\033[38;2;203;166;247m"     # Mauve
TEAL="\033[38;2;148;226;213m"      # Teal

# Print functions
print_status() {
    echo -e "${BLUE}[i]${BASE} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${BASE} $1"
}

print_error() {
    echo -e "${RED}[✗]${BASE} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${BASE} $1"
}

print_header() {
    echo -e "\n${MAUVE}=== $1 ===${BASE}\n"
}

# Print module header
print_header "Installing $MODULE_NAME configuration"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Install neofetch if not already installed
if ! command -v neofetch &> /dev/null; then
    print_status "Installing neofetch..."
    sudo apt-get update
    sudo apt-get install -y neofetch
fi

# Install Hack Nerd Font if not already installed
if ! fc-list | grep -i "Hack Nerd Font" &> /dev/null; then
    print_status "Installing Hack Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip -O /tmp/hack.zip
    unzip -q /tmp/hack.zip -d /tmp/hack
    cp /tmp/hack/*.ttf "$FONT_DIR"
    rm -rf /tmp/hack /tmp/hack.zip
    fc-cache -f -v
    print_success "Hack Nerd Font installed successfully"
else
    print_status "Hack Nerd Font is already installed"
fi

# Handle existing config file before stowing
if [ -f "$HOME/.config/neofetch/config.conf" ]; then
    if [ -L "$HOME/.config/neofetch/config.conf" ]; then
        print_status "Removing existing config.conf symlink..."
        rm "$HOME/.config/neofetch/config.conf"
    else
        print_status "Backing up existing config.conf file..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        mv "$HOME/.config/neofetch/config.conf" "$BACKUP_DIR/neofetch_config_backup_$TIMESTAMP"
        print_success "Backup created at $BACKUP_DIR/neofetch_config_backup_$TIMESTAMP"
    fi
fi

# Create target directory if it doesn't exist
print_status "Creating target directory..."
mkdir -p "$HOME/.config/neofetch"

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config/neofetch" .; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!" 