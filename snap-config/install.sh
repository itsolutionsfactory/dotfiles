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

# Check if we have sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges. You may be prompted for your password."
fi

# Check if snapd is installed
if ! command_exists snap; then
    print_status "Installing snapd..."
    sudo apt update
    sudo apt install -y snapd
fi

# Ensure snapd is running
print_status "Ensuring snapd is running..."
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.service

# Wait for snapd to be ready
print_status "Waiting for snapd to be ready..."
sleep 5

# List of snap packages to install
SNAP_PACKAGES=(
    "brave"                    # Brave Browser
    "spotify"                  # Spotify
    "signal-desktop"           # Signal
    "zoom-client"              # Zoom
    "teams-for-linux"          # Microsoft Teams
    "htop"                     # htop
    "onlyoffice-desktopeditors" # OnlyOffice
    "freelens --classic"        # Freelens - Kubernetes IDE
    "intellij-idea-ultimate --classic" # IntelliJ IDEA Ultimate
    "datagrip --classic"       # DataGrip
    "bruno"                    # Bruno - API Testing Tool
    "postman"                  # Postman - API Development Platform
    "xmind"                    # XMind - Mind Mapping Tool
)

# Function to install snap packages
install_snap_packages() {
    print_status "Installing snap packages..."
    for package in "${SNAP_PACKAGES[@]}"; do
        print_status "Installing $package..."
        sudo snap install $package || print_warning "Failed to install $package"
    done
}

# Function to list installed snaps
list_installed_snaps() {
    print_status "Listing installed snaps..."
    snap list
}

# Function to install GLPI agent
install_glpi_agent() {
    print_status "Installing GLPI agent..."
    
    # GLPI agent download URL (latest stable version)
    GLPI_URL="https://github.com/glpi-project/glpi-agent/releases/download/1.15/glpi-agent_1.15_amd64.snap"
    GLPI_SNAP_FILE="/tmp/glpi-agent_1.15_amd64.snap"
    
    # Download GLPI agent snap
    print_status "Downloading GLPI agent snap..."
    if command_exists wget; then
        wget -O "$GLPI_SNAP_FILE" "$GLPI_URL"
    elif command_exists curl; then
        curl -L -o "$GLPI_SNAP_FILE" "$GLPI_URL"
    else
        print_error "Neither wget nor curl is available. Cannot download GLPI agent."
        return 1
    fi
    
    # Install GLPI agent as classic snap
    print_status "Installing GLPI agent as classic snap..."
    if sudo snap install --classic --dangerous "$GLPI_SNAP_FILE"; then
        print_success "GLPI agent installed successfully"
    else
        print_error "Failed to install GLPI agent"
        return 1
    fi
    
    # Clean up downloaded file
    rm -f "$GLPI_SNAP_FILE"
    print_status "Cleaned up temporary files"
}

# Main installation process
print_status "Starting snap configuration..."

# Install snap packages
install_snap_packages

# Install GLPI agent
install_glpi_agent

# List installed snaps
list_installed_snaps

# Configure GLPI agent
print_status "Configuring GLPI agent..."
if command_exists glpi-agent; then
    sudo snap set glpi-agent server=@https://glpi.itsf.io/front/inventory.php
    print_status "GLPI agent configured successfully"
else
    print_warning "GLPI agent not found, skipping configuration"
fi

print_status "Snap configuration completed successfully!" 
