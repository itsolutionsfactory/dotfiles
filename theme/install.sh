#!/bin/bash

# Exit on any error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="theme"

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

# Function to print status messages
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

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup existing theme if it exists
if [ -d "$HOME/.poshthemes" ]; then
    print_status "Backing up existing Oh My Posh themes..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    tar -czf "$BACKUP_DIR/poshthemes_backup_$TIMESTAMP.tar.gz" -C "$HOME" .poshthemes
    print_success "Backup created at $BACKUP_DIR/poshthemes_backup_$TIMESTAMP.tar.gz"
fi

# Use stow to create symlinks
print_status "Installing theme configuration..."
if ! stow -t "$HOME" .; then
    print_error "Failed to install theme configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"
print_status "To use the Catppuccin theme, add this to your shell configuration:"
echo -e "${TEXT}eval \"\$(oh-my-posh init zsh --config \$HOME/.poshthemes/catppuccin.omp.json)\"${BASE}" 