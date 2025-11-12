#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="apt-packages"

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

# Check if we have sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges. You may be prompted for your password."
fi

# Update package list
print_status "Updating package list..."
sudo apt update

# List of apt packages to install
APT_PACKAGES=(
    "wireguard"              # WireGuard VPN
    "net-tools"              # Network utilities (netstat, ifconfig, etc.)
    "git-flow"               # Git workflow extension for branching model
)

# Function to check if a package is installed
package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to install apt packages
install_apt_packages() {
    print_status "Installing apt packages..."
    for package in "${APT_PACKAGES[@]}"; do
        if package_installed "$package"; then
            print_success "$package is already installed"
        else
            print_status "Installing $package..."
            if sudo apt install -y "$package"; then
                print_success "$package installed successfully"
            else
                print_error "Failed to install $package"
                exit 1
            fi
        fi
    done
}

# Function to verify installations
verify_installations() {
    print_status "Verifying installations..."
    for package in "${APT_PACKAGES[@]}"; do
        if package_installed "$package"; then
            print_success "$package is properly installed"
        else
            print_error "$package installation verification failed"
            exit 1
        fi
    done
}

# Function to show package information
show_package_info() {
    print_status "Package information:"
    for package in "${APT_PACKAGES[@]}"; do
        if package_installed "$package"; then
            print_status "$package version:"
            dpkg -l | grep "^ii  $package " | awk '{print $3}'
        fi
    done
}

# Main installation process
print_status "Starting apt packages installation..."

# Install packages
install_apt_packages

# Verify installations
verify_installations

# Show package information
show_package_info

print_success "$MODULE_NAME installation completed successfully!"

# Configure WireGuard (optional)
print_status "WireGuard configuration is available (optional)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/wireguard-setup.sh" ]; then
    bash "$SCRIPT_DIR/wireguard-setup.sh"
else
    print_error "wireguard-setup.sh not found in $SCRIPT_DIR"
fi

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Test network tools:"
print_warning "   - netstat -tuln (list listening ports)"
print_warning "   - ifconfig (network interface information)"
print_warning "   - route (routing table)"
print_warning "2. Git-flow setup (optional):"
print_warning "   - Initialize git-flow in your repositories: git flow init"
print_warning "   - See README.md for usage examples"
print_warning "3. WireGuard VPN setup (optional):"
print_warning "   - Run wireguard-setup.sh manually if you need VPN configuration"
print_warning "   - Or skip if you don't need VPN access"
