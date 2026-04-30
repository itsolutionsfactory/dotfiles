#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="flatpak-config"
TEAMS_APP_ID="com.github.IsmaelMartinez.teams_for_linux"
FLATHUB_REMOTE_URL="https://flathub.org/repo/flathub.flatpakrepo"

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_docker() {
    [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup
}

flatpak_remote_exists() {
    flatpak remotes --system --columns=name 2>/dev/null | awk '$1 == "flathub" { found=1 } END { exit found ? 0 : 1 }'
}

flatpak_app_installed() {
    flatpak info --system "$TEAMS_APP_ID" >/dev/null 2>&1
}

install_flatpak() {
    if command_exists flatpak; then
        print_success "flatpak is already installed"
        return 0
    fi

    print_status "Installing flatpak..."
    sudo apt update
    sudo apt install -y flatpak
    print_success "flatpak installed successfully"
}

configure_flathub() {
    if flatpak_remote_exists; then
        print_success "Flathub remote is already configured"
        return 0
    fi

    print_status "Adding system Flathub remote..."
    sudo flatpak remote-add --system --if-not-exists flathub "$FLATHUB_REMOTE_URL"
    print_success "System Flathub remote configured successfully"
}

install_teams() {
    if flatpak_app_installed; then
        print_success "Teams for Linux Flatpak is already installed"
        return 0
    fi

    print_status "Installing Teams for Linux via Flatpak..."
    sudo flatpak install --system -y flathub "$TEAMS_APP_ID"
    print_success "Teams for Linux Flatpak installed successfully"
}

print_header "Installing $MODULE_NAME configuration"

if is_docker; then
    print_warning "Running in Docker environment. Skipping Flatpak installation."
    exit 0
fi

if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges. You may be prompted for your password."
fi

print_status "Starting Flatpak configuration..."

install_flatpak
configure_flathub
install_teams

print_success "$MODULE_NAME installation completed successfully!"
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Restart your session if desktop integration is not visible yet"
print_warning "2. Launch Teams with: flatpak run $TEAMS_APP_ID"
