#!/bin/bash

# Exit on error
set -e

# Print error messages
set -o pipefail

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Catpuccin color scheme
RED='\033[0;31m'      # Red
GREEN='\033[0;32m'    # Green
YELLOW='\033[1;33m'   # Yellow
BLUE='\033[0;34m'     # Blue
MAGENTA='\033[0;35m'  # Magenta
CYAN='\033[0;36m'     # Cyan
NC='\033[0m'          # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[!]${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Function to print info messages
print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Function to check and install a package
check_and_install_package() {
    local package=$1
    if ! command -v "$package" &> /dev/null; then
        print_warning "$package is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y "$package"
        print_status "$package installed successfully"
    else
        print_info "$package is already installed"
    fi
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Check and install required packages
print_status "Checking required packages..."
check_and_install_package "stow"
check_and_install_package "wget"
check_and_install_package "unzip"
check_and_install_package "fontconfig"
check_and_install_package "git"

# Main installation process
print_status "Starting installation process..."

# Change to the script directory
cd "$SCRIPT_DIR"

# Install all configurations using stow
print_status "Installing configurations..."
for dir in */; do
    if [ -d "$dir" ] && [ "$dir" != ".cursor/" ] && [ -f "${dir}install.sh" ]; then
        print_status "Installing ${dir%/} configuration..."
        cd "$dir"
        ./install.sh
        cd ..
    fi
done

print_status "Installation completed successfully!" 