#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="apt-packages"

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
PINK="\033[38;2;245;194;231m"     # Pink
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
test_package_installed() {
    local package="$1"
    print_status "Testing package installation: $package"
    
    if dpkg -l | grep -q "^ii  $package "; then
        print_success "$package is installed"
        return 0
    else
        print_error "$package is not installed"
        return 1
    fi
}

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

test_wireguard_functionality() {
    print_status "Testing WireGuard functionality..."
    
    # Test if wg command is available
    if command -v wg >/dev/null 2>&1; then
        print_success "WireGuard (wg) command is available"
        
        # Test if wg-quick is available
        if command -v wg-quick >/dev/null 2>&1; then
            print_success "WireGuard quick (wg-quick) command is available"
        else
            print_error "WireGuard quick (wg-quick) command is not available"
            return 1
        fi
    else
        print_error "WireGuard (wg) command is not available"
        return 1
    fi
}

test_net_tools_functionality() {
    print_status "Testing net-tools functionality..."
    
    # Test netstat
    if command -v netstat >/dev/null 2>&1; then
        print_success "netstat command is available"
    else
        print_error "netstat command is not available"
        return 1
    fi
    
    # Test ifconfig
    if command -v ifconfig >/dev/null 2>&1; then
        print_success "ifconfig command is available"
    else
        print_error "ifconfig command is not available"
        return 1
    fi
    
    # Test route
    if command -v route >/dev/null 2>&1; then
        print_success "route command is available"
    else
        print_error "route command is not available"
        return 1
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

# Test package installations
test_package_installed "wireguard"
test_package_installed "net-tools"
test_package_installed "git-flow"

# Test command availability
test_command_available "wg"
test_command_available "wg-quick"
test_command_available "netstat"
test_command_available "ifconfig"
test_command_available "route"
test_command_available "git-flow"

# Test functionality
test_wireguard_functionality
test_net_tools_functionality

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Test WireGuard key generation: wg genkey"
print_warning "2. Test network tools: netstat -tuln"
print_warning "3. Test network interface info: ifconfig"
print_warning "4. Test routing table: route -n"
print_warning "5. Test git-flow: git flow version"
