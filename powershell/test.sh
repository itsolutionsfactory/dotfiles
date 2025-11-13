#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="powershell"

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
test_command_exists() {
    local cmd=$1
    print_status "Testing if $cmd command exists..."
    
    if command -v "$cmd" >/dev/null 2>&1; then
        print_success "$cmd command found"
        return 0
    else
        print_error "$cmd command not found"
        return 1
    fi
}

test_powershell_version() {
    print_status "Testing PowerShell version..."
    
    if command -v pwsh >/dev/null 2>&1; then
        local version
        version=$(pwsh --version 2>/dev/null || echo "unknown")
        print_success "PowerShell version: $version"
        return 0
    else
        print_error "PowerShell is not installed"
        return 1
    fi
}

test_powershell_execution() {
    print_status "Testing PowerShell execution..."
    
    if command -v pwsh >/dev/null 2>&1; then
        if pwsh -Command "Write-Host 'PowerShell is working'" >/dev/null 2>&1; then
            print_success "PowerShell execution test passed"
            return 0
        else
            print_error "PowerShell execution test failed"
            return 1
        fi
    else
        print_error "PowerShell is not installed"
        return 1
    fi
}

test_snap_installation() {
    print_status "Testing snap installation..."
    
    if command -v snap >/dev/null 2>&1; then
        if snap list powershell >/dev/null 2>&1; then
            local snap_version
            snap_version=$(snap list powershell | grep powershell | awk '{print $3}' || echo "unknown")
            print_success "PowerShell is installed via snap"
            print_status "Snap version: $snap_version"
            return 0
        else
            print_warning "PowerShell snap package not found in snap list"
            return 0
        fi
    else
        print_warning "snap is not available (PowerShell may be installed via other method)"
        return 0
    fi
}

test_exchange_online_module() {
    print_status "Testing Exchange Online PowerShell module..."
    
    if command -v pwsh >/dev/null 2>&1; then
        if pwsh -Command "Get-Module -ListAvailable -Name ExchangeOnlineManagement" >/dev/null 2>&1; then
            local module_version
            module_version=$(pwsh -Command "(Get-Module -ListAvailable -Name ExchangeOnlineManagement | Select-Object -First 1).Version" 2>/dev/null || echo "unknown")
            print_success "Exchange Online PowerShell module is installed"
            print_status "Module version: $module_version"
            return 0
        else
            print_warning "Exchange Online PowerShell module is not installed"
            print_status "You can install it by running: pwsh -Command 'Install-Module -Name ExchangeOnlineManagement -Force -Scope CurrentUser'"
            return 0
        fi
    else
        print_error "PowerShell is not installed"
        return 1
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

# Test if pwsh command exists
if ! test_command_exists "pwsh"; then
    print_error "PowerShell is not installed. Please run ./install.sh first."
    exit 1
fi

# Test PowerShell version
test_powershell_version

# Test PowerShell execution
test_powershell_execution

# Test snap installation
test_snap_installation

# Test Exchange Online module (optional)
test_exchange_online_module

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Run 'pwsh' to start PowerShell interactively"
print_warning "2. Test PowerShell commands and scripts"
print_warning "3. Verify PowerShell modules can be installed"
print_warning "4. If Exchange Online module is installed, test connection: Connect-ExchangeOnline"

