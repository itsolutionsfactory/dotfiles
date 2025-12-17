#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="flux"

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

# Function to install flux CLI
install_flux() {
    print_status "Installing Flux CLI using official installation script..."
    
    # Install Flux using the official installation script
    if curl -s https://fluxcd.io/install.sh | sudo bash; then
        print_success "Flux CLI installed successfully!"
        
        # Verify installation and display version
        if command -v flux &> /dev/null; then
            flux version --client
        fi
    else
        print_error "Failed to install Flux CLI"
        exit 1
    fi
}

# Function to setup flux completion
setup_completion() {
    print_status "Setting up Flux completion for ZSH..."
    
    local ZSH_COMPLETION_DIR="${HOME}/.oh-my-zsh/custom/completions"
    
    # Create completions directory if it doesn't exist
    mkdir -p "$ZSH_COMPLETION_DIR"
    
    # Generate flux completion
    flux completion zsh > "${ZSH_COMPLETION_DIR}/_flux"
    
    print_success "Flux ZSH completion installed!"
}

# Function to create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_status "Created backup directory: $BACKUP_DIR"
    fi
}

# Main installation
main() {
    print_header "Installing Flux CLI"
    
    # Create backup directory
    create_backup_dir
    
    # Check if flux is already installed
    if command -v flux &> /dev/null; then
        print_warning "Flux is already installed. Current version:"
        flux version --client
        read -p "Do you want to reinstall? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Skipping installation"
        else
            install_flux
        fi
    else
        install_flux
    fi
    
    # Setup completion
    if [ -d "$HOME/.oh-my-zsh" ]; then
        setup_completion
    else
        print_warning "Oh My ZSH not detected. Skipping completion setup."
    fi
    
    print_header "Flux CLI Installation Complete!"
    print_success "You can now use 'flux' command"
    print_status "Try: flux --help"
}

# Run main installation
main "$@"
