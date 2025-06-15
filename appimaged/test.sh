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

# Check if we're in a container
if [ -f /.dockerenv ]; then
    print_warning "Running in a container environment"
    print_warning "Skipping appimaged tests as it's not supported in containers"
    exit 0
fi

print_header "Testing appimaged configuration"

# Test 1: Check if appimaged is installed
print_status "Test 1: Checking if appimaged is installed..."
if command -v appimaged &> /dev/null; then
    print_success "appimaged is installed"
else
    print_error "appimaged is not installed"
    exit 1
fi

# Test 2: Check if Applications directory exists
print_status "Test 2: Checking if Applications directory exists..."
if [ -d ~/Applications ]; then
    print_success "Applications directory exists"
else
    print_error "Applications directory does not exist"
    exit 1
fi

# Test 3: Check if appimaged service is enabled
print_status "Test 3: Checking if appimaged service is enabled..."
if systemctl --user is-enabled appimaged &> /dev/null; then
    print_success "appimaged service is enabled"
else
    print_error "appimaged service is not enabled"
    exit 1
fi

# Test 4: Check if appimaged service is running
print_status "Test 4: Checking if appimaged service is running..."
if systemctl --user is-active appimaged &> /dev/null; then
    print_success "appimaged service is running"
else
    print_error "appimaged service is not running"
    exit 1
fi

# Test 5: Check if appimaged configuration exists
print_status "Test 5: Checking if appimaged configuration exists..."
if [ -f ~/.config/appimaged/appimaged.conf ]; then
    print_success "appimaged configuration exists"
else
    print_error "appimaged configuration does not exist"
    exit 1
fi

print_success "All tests passed successfully!"
print_warning "Remember to verify AppImages in your Applications directory" 