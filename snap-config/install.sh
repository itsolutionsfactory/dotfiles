#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Function to check if running in Docker
is_docker() {
    [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup
}

# Check if running in Docker
if is_docker; then
    print_warning "Running in Docker environment. Skipping snap installation."
    exit 0
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root"
    exit 1
fi

# Check if snapd is installed
if ! command_exists snap; then
    print_status "Installing snapd..."
    sudo apt update
    sudo apt install -y snapd
fi

# Ensure snapd is running
print_status "Ensuring snapd is running..."
systemctl enable --now snapd.socket
systemctl enable --now snapd.service

# Wait for snapd to be ready
print_status "Waiting for snapd to be ready..."
sleep 5

# List of snap packages to install
SNAP_PACKAGES=(
    "spotify"                  # Spotify
    "signal-desktop"           # Signal
    "zoom-client"              # Zoom
    "teams-for-linux"          # Microsoft Teams
    "imagemagick"              # ImageMagick
    "htop"                     # htop
    "onlyoffice-desktopeditors" # OnlyOffice
    "glpi"                     # GLPI
    "freelens --classic"        # Freelens - Kubernetes IDE
)

# Function to install snap packages
install_snap_packages() {
    print_status "Installing snap packages..."
    for package in "${SNAP_PACKAGES[@]}"; do
        print_status "Installing $package..."
        snap install $package || print_warning "Failed to install $package"
    done
}

# Function to list installed snaps
list_installed_snaps() {
    print_status "Listing installed snaps..."
    snap list
}

# Main installation process
print_status "Starting snap configuration..."

# Install snap packages
install_snap_packages

# List installed snaps
list_installed_snaps

# Configure GLPI agent
print_status "Configuring GLPI agent..."
if command_exists glpi-agent; then
    snap set glpi-agent server=@https://glpi.itsf.io/front/inventory.php
    print_status "GLPI agent configured successfully"
else
    print_warning "GLPI agent not found, skipping configuration"
fi

print_status "Snap configuration completed successfully!"

# Configure Brave profiles
print_status "Configuring Brave profiles..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/brave-profiles.sh" ]; then
    bash "$SCRIPT_DIR/brave-profiles.sh"
else
    print_error "brave-profiles.sh not found in $SCRIPT_DIR"
fi 
