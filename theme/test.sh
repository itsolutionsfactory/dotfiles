#!/bin/bash

# Exit on error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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

# Function to test if a file is properly linked by stow
test_stow_link() {
    local target="$1"
    local source="$2"
    
    # Check if the target is a symbolic link
    if [ ! -L "$target" ]; then
        print_error "$target is not a symbolic link"
        return 1
    fi
    
    # Get the absolute path of the source
    local abs_source="$(cd "$(dirname "$source")" && pwd)/$(basename "$source")"
    
    # Get the absolute path of the target's link
    local abs_target="$(readlink -f "$target")"
    
    # Compare the paths
    if [ "$abs_target" = "$abs_source" ]; then
        print_success "$target is properly linked by stow"
        return 0
    else
        print_error "$target is not properly linked by stow"
        print_error "Expected: $abs_source"
        print_error "Got: $abs_target"
        return 1
    fi
}

print_header "Testing $MODULE_NAME configuration"

# Test theme file
test_stow_link "$HOME/.poshthemes" "$SCRIPT_DIR/.poshthemes"

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Open a new terminal and check if Catppuccin theme is displayed correctly"
print_warning "2. Verify that the theme colors match the Catppuccin palette" 