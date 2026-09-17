#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="defguard"
DEFGUARD_GROUP="defguard"
DEFGUARD_SERVICE="defguard-service"
DEFGUARD_SOCKET="/var/run/defguard.socket"
DEFGUARD_APP="/Applications/Defguard.app"
DEFGUARD_MACOS_TEAM_ID="82GZ7KN29J"

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
test_package_installed() {
    local version
    print_status "Testing package: defguard-client"

    version="$(dpkg-query -W -f='${db:Status-Status} ${Version}\n' defguard-client 2>/dev/null | awk '$1 == "installed" {print $2}')"
    if [ -n "$version" ]; then
        print_success "defguard-client $version is installed"
        return 0
    else
        print_error "defguard-client is not installed"
        return 1
    fi
}

test_dependency() {
    local dep="$1"
    print_status "Testing dependency: $dep"

    if command -v "$dep" >/dev/null 2>&1; then
        print_success "Dependency found: $dep"
        return 0
    else
        print_error "Dependency not found: $dep"
        return 1
    fi
}

test_service_active() {
    print_status "Testing service: $DEFGUARD_SERVICE"

    if systemctl is-active --quiet "$DEFGUARD_SERVICE"; then
        print_success "$DEFGUARD_SERVICE is running"
        return 0
    else
        print_error "$DEFGUARD_SERVICE is not running"
        return 1
    fi
}

test_socket() {
    print_status "Testing socket: $DEFGUARD_SOCKET"

    if [ ! -S "$DEFGUARD_SOCKET" ]; then
        print_error "$DEFGUARD_SOCKET is not a socket"
        return 1
    fi

    if [ "$(stat -c %G "$DEFGUARD_SOCKET")" = "$DEFGUARD_GROUP" ]; then
        print_success "$DEFGUARD_SOCKET belongs to the $DEFGUARD_GROUP group"
        return 0
    else
        print_error "$DEFGUARD_SOCKET does not belong to the $DEFGUARD_GROUP group"
        return 1
    fi
}

test_group_membership() {
    local user
    user="$(id -un)"
    print_status "Testing group membership: $user in $DEFGUARD_GROUP"

    if id -nG "$user" | tr ' ' '\n' | grep -qx "$DEFGUARD_GROUP"; then
        print_success "$user is a member of the $DEFGUARD_GROUP group"
    else
        print_error "$user is not a member of the $DEFGUARD_GROUP group"
        return 1
    fi

    # Without a user name, id shows the groups of the current session
    if id -nG | tr ' ' '\n' | grep -qx "$DEFGUARD_GROUP"; then
        print_success "The current session carries the $DEFGUARD_GROUP group"
    else
        print_warning "The current session does not carry the $DEFGUARD_GROUP group yet"
        print_warning "Run ./install.sh again: it tells whether a reboot is required"
    fi
}

test_macos_app() {
    local version
    local team_id
    print_status "Testing application: $DEFGUARD_APP"

    if [ ! -d "$DEFGUARD_APP" ]; then
        print_error "$DEFGUARD_APP is not installed"
        return 1
    fi

    version="$(defaults read "$DEFGUARD_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || true)"
    if [ -f "$DEFGUARD_APP/Contents/_MASReceipt/receipt" ]; then
        print_success "Defguard $version is installed (App Store)"
    else
        print_success "Defguard $version is installed"
    fi

    if ! codesign --verify --deep --strict "$DEFGUARD_APP" 2>/dev/null; then
        print_error "Invalid code signature on $DEFGUARD_APP"
        return 1
    fi
    team_id="$(codesign -dv "$DEFGUARD_APP" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
    if [ "$team_id" = "$DEFGUARD_MACOS_TEAM_ID" ]; then
        print_success "Signed by Apple Developer team $team_id"
    else
        print_error "Signed by team '$team_id', expected $DEFGUARD_MACOS_TEAM_ID"
        return 1
    fi
}

test_macos_extension() {
    print_status "Testing VPN extension"

    # The GitHub DMG build ships a system extension; the App Store build an app extension instead
    if [ ! -d "$DEFGUARD_APP/Contents/Library/SystemExtensions" ]; then
        print_success "No system extension to approve for this build"
        return 0
    fi

    if systemextensionsctl list 2>/dev/null | grep "net.defguard.VPNExtension" | grep -q "activated enabled"; then
        print_success "The Defguard VPN system extension is activated and enabled"
    else
        print_warning "The Defguard VPN system extension is not approved yet"
        print_warning "Launch Defguard and allow its VPN extension when MacOS asks"
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    # No stowed payload: there is nothing to check outside a real Ubuntu host
    print_success "Portable $MODULE_NAME tests completed (no stowed files)"
    exit 0
fi

if [ "$(uname -s)" = "Darwin" ]; then
    test_macos_app
    test_macos_extension
    print_success "Testing completed!"
    print_warning "Please verify the following manually:"
    print_warning "1. Launch Defguard and connect to your location"
    exit 0
fi

if [ -f /.dockerenv ]; then
    print_warning "The Defguard client is only installed on a real Ubuntu host, skipping"
    exit 0
fi

test_package_installed
test_dependency "defguard-client"
test_dependency "dg"
test_service_active
test_socket
test_group_membership

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Launch Defguard and connect to your location"
print_warning "2. Check that 'ping' to the gateway address of the location answers through the tunnel"
