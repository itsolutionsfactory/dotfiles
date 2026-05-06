#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="github-cli"
OS_TYPE="$(uname -s)"

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed via apt
package_installed() {
    dpkg -l "$1" &>/dev/null
}

# Function to install GitHub CLI via apt
install_github_cli() {
    if [ "$OS_TYPE" = "Darwin" ]; then
        print_status "Installing GitHub CLI via Homebrew..."
        if ! command -v brew >/dev/null 2>&1; then
            print_error "Homebrew is required to install GitHub CLI on MacOS"
            exit 1
        fi
        brew install gh
        return 0
    fi

    print_status "Installing GitHub CLI via apt..."

    # Add GitHub CLI repository if not already added
    if [ ! -f "/etc/apt/sources.list.d/github-cli.list" ]; then
        print_status "Adding GitHub CLI repository..."

        # Download and install the signing key
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

        # Add the repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

        # Update package list
        print_status "Updating package list..."
        sudo apt-get update
    else
        print_status "GitHub CLI repository already configured"
    fi

    # Install GitHub CLI
    print_status "Installing GitHub CLI..."
    sudo apt-get install -y gh

    # Verify installation
    if command -v gh &> /dev/null; then
        print_success "GitHub CLI installed successfully!"
        gh version
    else
        print_error "Failed to install GitHub CLI"
        exit 1
    fi
}

# Function to backup existing configuration
backup_config() {
    if [ -d "$HOME/.config/gh" ]; then
        print_status "Backing up existing GitHub CLI configuration..."
        local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        local BACKUP_PATH="$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP"
        mkdir -p "$BACKUP_PATH"
        mv "$HOME/.config/gh" "$BACKUP_PATH/"
        print_success "Backup created at $BACKUP_PATH"
    fi
}

# Print module header
print_header "Installing $MODULE_NAME configuration"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR/modules/$MODULE_NAME"

# Check if GitHub CLI is installed
if ! command_exists gh; then
    print_warning "GitHub CLI is not installed."
    install_github_cli
else
    print_status "GitHub CLI is already installed"
    gh version
fi

# Backup existing configuration if it exists
backup_config

# Create necessary directories
print_status "Creating GitHub CLI configuration directories..."
mkdir -p "$HOME/.config/gh"

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config" .config; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"
print_status "Next steps:"
print_status "1. Run 'gh auth login' to authenticate with GitHub"
print_status "2. Configure your Git username and email if not already set"
print_status "3. Test the installation with 'gh --help'"