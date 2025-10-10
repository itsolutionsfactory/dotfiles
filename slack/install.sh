#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="slack"

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

# Check if Slack is already installed
if command -v slack >/dev/null 2>&1; then
    print_success "Slack is already installed"
    slack --version
    exit 0
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
print_status "Checking dependencies..."

# Check for wget or curl
if command_exists wget; then
    DOWNLOAD_CMD="wget"
elif command_exists curl; then
    DOWNLOAD_CMD="curl -L"
else
    print_error "Neither wget nor curl is available. Please install one of them."
    exit 1
fi

print_success "Download tool found: $DOWNLOAD_CMD"

# Check for dpkg
if ! command_exists dpkg; then
    print_error "dpkg is not available. Please install it first."
    exit 1
fi

print_success "dpkg is available"

# Slack download URL and file info
SLACK_URL="https://downloads.slack-edge.com/desktop-releases/linux/x64/4.46.101/slack-desktop-4.46.101-amd64.deb"
SLACK_DEB_FILE="/tmp/slack-desktop-4.46.101-amd64.deb"

# Function to download Slack
download_slack() {
    print_status "Downloading Slack..."
    
    if [ "$DOWNLOAD_CMD" = "wget" ]; then
        wget -O "$SLACK_DEB_FILE" "$SLACK_URL"
    else
        curl -L -o "$SLACK_DEB_FILE" "$SLACK_URL"
    fi
    
    if [ -f "$SLACK_DEB_FILE" ]; then
        print_success "Slack downloaded successfully"
    else
        print_error "Failed to download Slack"
        exit 1
    fi
}

# Function to install Slack
install_slack() {
    print_status "Installing Slack..."
    
    # Install the .deb file
    if sudo dpkg -i "$SLACK_DEB_FILE"; then
        print_success "Slack installed successfully"
    else
        print_warning "Installation had issues, trying to fix dependencies..."
        sudo apt-get update
        sudo apt-get install -f -y
        if sudo dpkg -i "$SLACK_DEB_FILE"; then
            print_success "Slack installed successfully after fixing dependencies"
        else
            print_error "Failed to install Slack"
            exit 1
        fi
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying Slack installation..."
    
    if command -v slack >/dev/null 2>&1; then
        print_success "Slack is properly installed"
        slack --version
    else
        print_error "Slack installation verification failed"
        exit 1
    fi
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    if [ -f "$SLACK_DEB_FILE" ]; then
        rm -f "$SLACK_DEB_FILE"
        print_success "Temporary files cleaned up"
    fi
}

# Main installation process
print_status "Starting Slack installation..."

# Download Slack
download_slack

# Install Slack
install_slack

# Verify installation
verify_installation

# Cleanup
cleanup

print_success "$MODULE_NAME installation completed successfully!"

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Launch Slack:"
print_warning "   slack"
print_warning "2. Sign in to your workspace"
print_warning "3. Configure your preferences"
print_warning "4. Set up notifications as needed"
