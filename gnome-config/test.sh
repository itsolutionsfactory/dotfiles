#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="gnome-config"

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
test_workspace_shortcut() {
    local action=$1
    local workspace_num=$2
    local expected_binding=$3
    
    print_status "Testing $action workspace $workspace_num shortcut"
    
    local current_binding
    current_binding=$(dconf read "/org/gnome/desktop/wm/keybindings/${action}-${workspace_num}" 2>/dev/null || echo "[]")
    
    if [ "$current_binding" = "$expected_binding" ]; then
        print_success "$action workspace $workspace_num shortcut is correctly configured"
        return 0
    else
        print_error "$action workspace $workspace_num shortcut is not correctly configured"
        print_error "Expected: $expected_binding"
        print_error "Got: $current_binding"
        return 1
    fi
}

test_custom_shortcut() {
    local name=$1
    local expected_command=$2
    local expected_binding=$3
    
    print_status "Testing custom shortcut: $name"
    
    local binding_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/"
    
    # Check if the binding exists
    local current_command
    local current_binding
    
    current_command=$(dconf read "$binding_path/command" 2>/dev/null || echo "not_found")
    current_binding=$(dconf read "$binding_path/binding" 2>/dev/null || echo "not_found")
    
    if [ "$current_command" = "'$expected_command'" ] && [ "$current_binding" = "'$expected_binding'" ]; then
        print_success "Custom shortcut '$name' is correctly configured"
        return 0
    else
        print_error "Custom shortcut '$name' is not correctly configured"
        print_error "Expected command: '$expected_command'"
        print_error "Got command: $current_command"
        print_error "Expected binding: '$expected_binding'"
        print_error "Got binding: $current_binding"
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

test_gnome_environment() {
    print_status "Testing GNOME environment"
    
    if [ -z "$XDG_CURRENT_DESKTOP" ]; then
        print_warning "XDG_CURRENT_DESKTOP is not set"
        return 1
    fi
    
    if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
        print_success "Running in GNOME environment: $XDG_CURRENT_DESKTOP"
        return 0
    else
        print_warning "Not running in GNOME environment: $XDG_CURRENT_DESKTOP"
        return 1
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

# Test GNOME environment
test_gnome_environment

# Test dependencies
test_dependency "dconf"

# Test workspace navigation shortcuts
print_header "Testing Workspace Navigation Shortcuts"

for i in {1..9}; do
    test_workspace_shortcut "switch-to-workspace" $i "['<Super>$i']"
done

# Test window movement shortcuts
print_header "Testing Window Movement Shortcuts"

for i in {1..9}; do
    test_workspace_shortcut "move-to-workspace" $i "['<Super><Shift>$i']"
done

# Test Kitty shortcut if Kitty is installed
if command -v kitty >/dev/null 2>&1; then
    print_header "Testing Kitty Terminal Shortcut"
    KITTY_PATH=$(which kitty)
    test_custom_shortcut "kitty" "$KITTY_PATH" "<Super>t"
else
    print_status "Kitty not installed, skipping Kitty shortcut test"
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Test Super+Number shortcuts for workspace navigation"
print_warning "2. Test Super+Shift+Number shortcuts for moving windows"
print_warning "3. Test Super+T shortcut for Kitty terminal (if installed)"
print_warning "4. Check that no existing shortcuts were broken"
print_warning "5. Verify shortcuts work in different applications"
print_warning "6. Test shortcuts with multiple workspaces open" 