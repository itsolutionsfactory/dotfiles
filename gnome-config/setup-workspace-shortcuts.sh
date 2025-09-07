#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="gnome-workspace-shortcuts"

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create backup of GNOME settings
create_backup() {
    local backup_timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$BACKUP_DIR/modules/$MODULE_NAME/$backup_timestamp"
    
    print_status "Creating backup of GNOME settings..."
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Backup workspace keybindings
    dconf dump /org/gnome/desktop/wm/keybindings/ > "$backup_path/workspace-keybindings.dconf" 2>/dev/null || true
    
    # Backup custom keybindings
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$backup_path/custom-keybindings.dconf" 2>/dev/null || true
    
    print_success "Backup created at: $backup_path"
}

# Function to check if a shortcut is set correctly
check_shortcut() {
    local action=$1
    local workspace_num=$2
    local expected_binding=$3
    local current_binding
    
    # Use dconf instead of gsettings for more reliable output
    current_binding=$(dconf read "/org/gnome/desktop/wm/keybindings/${action}-${workspace_num}" 2>/dev/null || echo "[]")
    
    if [ "$current_binding" = "$expected_binding" ]; then
        print_success "${action} ${workspace_num} shortcut is correctly set"
        return 0
    else
        print_warning "${action} ${workspace_num} shortcut is not set correctly"
        print_status "  Current: ${current_binding}"
        print_status "  Expected: ${expected_binding}"
        return 1
    fi
}

# Function to set a shortcut safely
set_shortcut() {
    local action=$1
    local workspace_num=$2
    local binding=$3
    
    if dconf write "/org/gnome/desktop/wm/keybindings/${action}-${workspace_num}" "$binding" 2>/dev/null; then
        print_success "Set ${action} ${workspace_num} shortcut to ${binding}"
        return 0
    else
        print_error "Failed to set ${action} ${workspace_num} shortcut"
        return 1
    fi
}

# Function to safely add custom shortcut
add_custom_shortcut() {
    local name=$1
    local command=$2
    local binding=$3
    
    print_status "Setting up custom shortcut: $name"
    
    # Get current custom keybindings
    local current_bindings
    current_bindings=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings 2>/dev/null || echo "[]")
    
    # Check if the shortcut already exists
    if [[ "$current_bindings" != *"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/"* ]]; then
        # Create new binding path
        local new_binding="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/"
        
        # Add to custom keybindings array
        if [ "$current_bindings" = "[]" ]; then
            # Empty array, create new one
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "[$new_binding]"
        else
            # Add to existing array
            local new_array="${current_bindings%]}, $new_binding]"
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$new_array"
        fi
        
        # Set the shortcut properties
        dconf write "$new_binding/name" "'$name'"
        dconf write "$new_binding/command" "'$command'"
        dconf write "$new_binding/binding" "'$binding'"
        
        print_success "Custom shortcut '$name' added successfully"
    else
        print_status "Custom shortcut '$name' already exists"
    fi
}

# Function to verify custom shortcut
verify_custom_shortcut() {
    local name=$1
    local expected_command=$2
    local expected_binding=$3
    
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
        print_warning "Custom shortcut '$name' is not correctly configured"
        print_status "  Expected command: '$expected_command'"
        print_status "  Current command: $current_command"
        print_status "  Expected binding: '$expected_binding'"
        print_status "  Current binding: $current_binding"
        return 1
    fi
}

# Main execution
print_header "GNOME Workspace Shortcuts Configuration"

# Check if we're running in a GNOME session
if [ -z "$XDG_CURRENT_DESKTOP" ] || [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
    print_warning "This script is designed for GNOME desktop environment"
    print_status "Current desktop: $XDG_CURRENT_DESKTOP"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborted by user"
        exit 1
    fi
fi

# Create backup before making changes
create_backup

# Check and set workspace navigation shortcuts
print_header "Workspace Navigation Shortcuts"

needs_fix=0
for i in {1..9}; do
    if ! check_shortcut "switch-to-workspace" $i "['<Super>$i']"; then
        needs_fix=1
    fi
done

# Check and set window movement shortcuts
print_header "Window Movement Shortcuts"

for i in {1..9}; do
    if ! check_shortcut "move-to-workspace" $i "['<Super><Shift>$i']"; then
        needs_fix=1
    fi
done

# Apply fixes if needed
if [ $needs_fix -eq 1 ]; then
    print_header "Applying Workspace Shortcuts"
    
    for i in {1..9}; do
        set_shortcut "switch-to-workspace" $i "['<Super>$i']"
        set_shortcut "move-to-workspace" $i "['<Super><Shift>$i']"
    done
    
    print_success "All workspace shortcuts have been configured:"
    print_status "- Super+Number: Switch to workspace"
    print_status "- Super+Shift+Number: Move window to workspace"
else
    print_success "All workspace shortcuts are correctly configured!"
fi

# Check if Kitty is installed
# print_header "Kitty Terminal Integration"

# if ! command_exists kitty; then
#     print_warning "Kitty is not installed or not in PATH"
#     print_status "Skipping Kitty shortcut setup"
#     print_status "To install Kitty: sudo apt install kitty"
# else
#     print_success "Kitty is installed"
#     KITTY_PATH=$(which kitty)
#     print_status "Kitty path: $KITTY_PATH"
    
    # Set up Kitty terminal shortcut
#     add_custom_shortcut "kitty" "$KITTY_PATH" "<Super>t"
# fi

# Final verification
print_header "Verification"

print_status "Verifying workspace navigation shortcuts:"
for i in {1..9}; do
    check_shortcut "switch-to-workspace" $i "['<Super>$i']"
done

print_status "Verifying window movement shortcuts:"
for i in {1..9}; do
    check_shortcut "move-to-workspace" $i "['<Super><Shift>$i']"
done

if command_exists kitty; then
    print_status "Verifying Kitty shortcut:"
    verify_custom_shortcut "kitty" "$KITTY_PATH" "<Super>t"
fi

print_success "GNOME workspace shortcuts configuration completed!"
print_warning "Please verify the following manually:"
print_warning "1. Test Super+Number shortcuts for workspace navigation"
print_warning "2. Test Super+Shift+Number shortcuts for moving windows"
print_warning "3. Test Super+T shortcut for Kitty terminal (if installed)"
print_warning "4. Check that no existing shortcuts were broken" 