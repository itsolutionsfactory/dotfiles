#!/bin/bash

# Exit on any error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# Check if Neovim is installed
print_info "Checking if Neovim is installed..."

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    CONFIG_FILES=(
        "$HOME/.config/nvim/init.lua"
        "$HOME/.config/nvim/lua/theme.lua"
    )

    for file in "${CONFIG_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Configuration file not found: $file"
            exit 1
        fi
        print_success "Found $file"
    done

    print_success "Portable vim tests completed"
    exit 0
fi

if ! command_exists nvim; then
    print_error "Neovim is not installed"
    exit 1
fi
print_success "Neovim is installed"

# Check Neovim version
print_info "Checking Neovim version..."
NVIM_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
if [[ $(echo "$NVIM_VERSION 0.8.0" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
    print_error "Neovim version $NVIM_VERSION is too old. Please install version 0.8.0 or higher"
    exit 1
fi
print_success "Neovim version $NVIM_VERSION is compatible"

# Check if configuration files exist
print_info "Checking configuration files..."
CONFIG_FILES=(
    "$HOME/.config/nvim/init.lua"
    "$HOME/.config/nvim/lua/theme.lua"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Configuration file not found: $file"
        exit 1
    fi
    print_success "Found $file"
done

# Check if lazy.nvim is installed
print_info "Checking if lazy.nvim is installed..."
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
    print_warning "lazy.nvim is not installed. This is normal on first run."
else
    print_success "lazy.nvim is installed"
fi

# Test Neovim startup
print_info "Testing Neovim startup..."
if ! nvim --headless -c "quit" 2>/dev/null; then
    print_error "Neovim failed to start"
    exit 1
fi
print_success "Neovim starts successfully"

print_success "All tests passed!"
print_info "Your Neovim configuration is properly installed and working." 