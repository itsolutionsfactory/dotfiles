#!/bin/bash

# Exit on any error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OS_TYPE="$(uname -s)"

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
    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! command_exists brew; then
            print_error "Homebrew is required to install $package on MacOS"
            exit 1
        fi
        brew install "$package"
    else
        sudo apt-get update
        sudo apt-get install -y "$package"
    fi
    print_success "$package installed successfully"
}

package_command() {
    case "$1" in
        neovim) echo "nvim" ;;
        fd-find)
            if [ "$OS_TYPE" = "Darwin" ]; then
                echo "fd"
            else
                echo "fdfind"
            fi
            ;;
        *) echo "$1" ;;
    esac
}

package_name() {
    case "$1" in
        fd-find)
            if [ "$OS_TYPE" = "Darwin" ]; then
                echo "fd"
            else
                echo "fd-find"
            fi
            ;;
        *) echo "$1" ;;
    esac
}

# Check and install dependencies
print_info "Checking dependencies..."
for package in "${REQUIRED_PACKAGES[@]}"; do
    command_name="$(package_command "$package")"
    install_name="$(package_name "$package")"
    if ! command_exists "$command_name"; then
        print_info "$command_name not found. Installing $install_name..."
        install_package "$install_name"
    else
        print_success "$command_name is already installed"
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