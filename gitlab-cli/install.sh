#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="gitlab-cli"

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

# Check if glab is already installed
if command -v glab >/dev/null 2>&1; then
    print_success "GitLab CLI (glab) is already installed"
    glab version
else
    print_status "Installing GitLab CLI (glab)..."
    
    # Install glab using the official installation script
    curl -s https://gitlab.com/gitlab-org/cli/-/releases/permalink/latest/downloads/glab_linux_amd64.tar.gz | tar -xz
    sudo mv glab /usr/local/bin/
    
    # Verify installation
    if command -v glab >/dev/null 2>&1; then
        print_success "GitLab CLI installed successfully"
        glab version
    else
        print_error "Failed to install GitLab CLI"
        exit 1
    fi
fi

# Check if configuration directory exists
if [ -d "$HOME/.config/glab" ]; then
    print_warning "Existing GitLab CLI configuration found"
    
    # Create backup
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
    BACKUP_PATH="$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"
    
    print_status "Creating backup of existing configuration..."
    cp -r "$HOME/.config/glab" "$BACKUP_PATH/"
    print_success "Backup created at: $BACKUP_PATH"
    
    # Remove existing configuration
    rm -rf "$HOME/.config/glab"
    print_status "Removed existing configuration"
fi

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config" .config; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Run 'glab auth login' to authenticate with GitLab"
print_warning "2. GitLab instance is pre-configured: https://gitlab.steelhome.internal/"
print_warning "3. Set up any additional configuration as needed"
print_warning "4. Test the CLI with 'glab issue list' or 'glab mr list'"
