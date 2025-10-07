#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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

# Test functions
test_command_available() {
    local command="$1"
    print_status "Testing command availability: $command"
    
    if command -v "$command" >/dev/null 2>&1; then
        print_success "$command is available"
        return 0
    else
        print_error "$command is not available"
        return 1
    fi
}

test_slack_installation() {
    print_status "Testing Slack installation..."
    
    # Test if slack command is available
    if command -v slack >/dev/null 2>&1; then
        print_success "Slack command is available"
        
        # Test version command
        if slack --version >/dev/null 2>&1; then
            print_success "Slack version command works"
            print_status "Slack version:"
            slack --version
        else
            print_warning "Slack version command failed, but command is available"
        fi
    else
        print_error "Slack command is not available"
        return 1
    fi
}

test_slack_desktop_file() {
    print_status "Testing Slack desktop file..."
    
    local desktop_file="/usr/share/applications/slack.desktop"
    if [ -f "$desktop_file" ]; then
        print_success "Slack desktop file exists"
    else
        print_warning "Slack desktop file not found at $desktop_file"
    fi
}

test_slack_binary() {
    print_status "Testing Slack binary..."
    
    local slack_binary="/usr/bin/slack"
    if [ -f "$slack_binary" ]; then
        print_success "Slack binary exists"
        if [ -x "$slack_binary" ]; then
            print_success "Slack binary is executable"
        else
            print_error "Slack binary is not executable"
            return 1
        fi
    else
        print_error "Slack binary not found at $slack_binary"
        return 1
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

# Test command availability
test_command_available "slack"

# Test Slack installation
test_slack_installation

# Test desktop file
test_slack_desktop_file

# Test binary
test_slack_binary

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Launch Slack: slack"
print_warning "2. Test workspace connection"
print_warning "3. Verify notifications work"
print_warning "4. Test file sharing functionality"
