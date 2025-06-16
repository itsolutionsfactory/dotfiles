#!/bin/bash

# Exit on any error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Dependencies
declare -a REQUIRED_PACKAGES=(
    "neovim"
    "git"
    "ripgrep"  # For telescope live grep
    "fd-find"  # For telescope find files
)

# Function to print with colors
print_success() {
    echo -e "\033[32m[✓] $1\033[0m"
}

print_error() {
    echo -e "\033[31m[✗] $1\033[0m"
}

print_info() {
    echo -e "\033[34m[i] $1\033[0m"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a package using apt
install_package() {
    local package=$1
    print_info "Installing $package..."
    sudo apt-get update
    sudo apt-get install -y "$package"
    print_success "$package installed successfully"
}

# Check and install dependencies
print_info "Checking dependencies..."
for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! command_exists "$package"; then
        print_info "$package not found. Installing..."
        install_package "$package"
    else
        print_success "$package is already installed"
    fi
done

# Create necessary directories
print_info "Creating Neovim data directory..."
mkdir -p ~/.local/share/nvim

# Install the configuration
print_info "Installing Neovim configuration..."
cd "$SCRIPT_DIR"
stow -t ~ -v .

print_success "Neovim configuration installed successfully!"
print_info "First time setup:"
print_info "1. Open Neovim with 'nvim'"
print_info "2. Wait for plugins to install"
print_info "3. Restart Neovim" 