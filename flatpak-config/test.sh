#!/bin/bash

# Exit on error
set -e

# Module info
MODULE_NAME="flatpak-config"
TEAMS_APP_ID="com.github.IsmaelMartinez.teams_for_linux"
FLATHUB_REMOTE_NAME="flathub"

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

is_docker() {
    [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup
}

test_dependency() {
    local dep="$1"
    print_status "Testing dependency: $dep"

    if command -v "$dep" >/dev/null 2>&1; then
        print_success "Dependency found: $dep"
        return 0
    fi

    print_error "Dependency not found: $dep"
    return 1
}

test_flathub_remote() {
    print_status "Testing system Flathub remote"

    if flatpak remotes --system --columns=name 2>/dev/null | awk -v remote="$FLATHUB_REMOTE_NAME" '$1 == remote { found=1 } END { exit found ? 0 : 1 }'; then
        print_success "System Flathub remote is configured"
        return 0
    fi

    print_error "System Flathub remote is not configured"
    return 1
}

test_teams_installation() {
    print_status "Testing Teams for Linux Flatpak installation"

    if flatpak info --system "$TEAMS_APP_ID" >/dev/null 2>&1; then
        print_success "Teams for Linux Flatpak is installed"
        return 0
    fi

    print_error "Teams for Linux Flatpak is not installed"
    return 1
}

print_header "Testing $MODULE_NAME configuration"

if is_docker; then
    print_warning "Running in Docker environment. Skipping Flatpak tests."
    print_success "Testing completed with Docker skip."
    exit 0
fi

test_dependency "flatpak"
test_flathub_remote
test_teams_installation

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Launch Teams with: flatpak run $TEAMS_APP_ID"
print_warning "2. Sign in and verify notifications after a session restart"
