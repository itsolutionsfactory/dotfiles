#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="kitty"
OS_TYPE="$(uname -s)"

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

# Backup existing configuration if it exists
if [ -d "$HOME/.config/kitty" ]; then
    print_status "Backing up existing Kitty configuration..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    tar -czf "$BACKUP_DIR/kitty_backup_$TIMESTAMP.tar.gz" -C "$HOME" .config/kitty
    print_success "Backup created at $BACKUP_DIR/kitty_backup_$TIMESTAMP.tar.gz"

    # Remove existing configuration after backup
    print_status "Removing existing Kitty configuration..."
    rm -rf "$HOME/.config/kitty"
    print_success "Existing configuration removed"
fi

# Check if running in Docker
if [ -f /.dockerenv ]; then
    print_warning "Running in Docker environment - skipping Kitty installation"
    print_warning "Kitty requires a desktop environment and cannot be installed in Docker"
elif [ "$OS_TYPE" = "Darwin" ]; then
    if command -v brew >/dev/null 2>&1 && ! brew list --cask kitty >/dev/null 2>&1; then
        print_status "Installing Kitty via Homebrew..."
        brew install --cask kitty
    else
        print_status "Kitty is already installed or Homebrew is unavailable"
    fi
else
    # Install Kitty if not already installed
    if ! command -v kitty &> /dev/null; then
        print_status "Installing Kitty..."
        sudo apt-get update
        sudo apt-get install -y kitty
    fi
fi

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config" .config; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"
if [ ! -f /.dockerenv ]; then
    print_warning "Please restart Kitty for the changes to take effect"
fi