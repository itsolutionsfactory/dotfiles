#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="certs"
OS_TYPE="$(uname -s)"
USER_CERT_DIR="$HOME/.certs"
USER_CERT="$USER_CERT_DIR/root-ca.crt"
ROOT_CA_SOURCE="$SCRIPT_DIR/root-ca.crt"

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

install_linux_trust() {
    print_status "Installing certificate in Linux system trust store..."
    sudo mkdir -p /usr/local/share/ca-certificates
    sudo cp "$USER_CERT" /usr/local/share/ca-certificates/root-ca.crt
    sudo update-ca-certificates
    print_success "Linux system trust store updated"
}

install_macos_trust() {
    print_status "Installing certificate in MacOS System keychain..."

    if ! command -v security >/dev/null 2>&1; then
        print_error "MacOS security command not found"
        exit 1
    fi

    sudo security add-trusted-cert \
        -d \
        -r trustRoot \
        -k /Library/Keychains/System.keychain \
        "$USER_CERT"

    print_success "MacOS System keychain updated"
}

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p "$USER_CERT_DIR"
mkdir -p "$HOME/.config/certs"

# Copy root CA certificate from the module directory
print_status "Copying root CA certificate..."
cp "$ROOT_CA_SOURCE" "$USER_CERT"

case "$OS_TYPE" in
    Linux)
        install_linux_trust
        ;;
    Darwin)
        install_macos_trust
        ;;
    *)
        print_error "Unsupported operating system: $OS_TYPE"
        exit 1
        ;;
esac

# Set proper permissions
print_status "Setting proper permissions..."
chmod 644 "$USER_CERT"

# Create symlinks
print_status "Creating symlinks..."
stow -t "$HOME" -d "$SCRIPT_DIR" .

print_success "$MODULE_NAME installation completed successfully!"