#!/bin/bash

set -e

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

print_header "Testing certificate installation"

# Test 1: Check if certificate exists in ~/.certs
if [ -f ~/.certs/root-ca.crt ]; then
    print_success "Certificate found in ~/.certs"
else
    print_error "Certificate not found in ~/.certs"
    exit 1
fi

# Test 2: Check certificate permissions
PERMS=$(stat -c "%a" ~/.certs/root-ca.crt)
if [ "$PERMS" = "644" ]; then
    print_success "Certificate has correct permissions (644)"
else
    print_error "Certificate has incorrect permissions: $PERMS"
    exit 1
fi

# Test 3: Verify certificate format
if openssl x509 -in ~/.certs/root-ca.crt -text -noout &>/dev/null; then
    print_success "Certificate format is valid"
else
    print_error "Certificate format is invalid"
    exit 1
fi

# Test 4: Check if certificate is in system trust store
if [ -f /usr/local/share/ca-certificates/root-ca.crt ]; then
    print_success "Certificate found in system trust store"
else
    print_error "Certificate not found in system trust store"
    exit 1
fi

print_success "All tests passed successfully!"
print_warning "Please verify the following manually:"
print_warning "1. Certificate is trusted by your system"
print_warning "2. Certificate is valid for your use case"
print_warning "3. Certificate has not expired" 