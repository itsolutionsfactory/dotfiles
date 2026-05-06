#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="gitlab-cli"
CONFIG_DIR="$HOME/.config/glab"

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
test_stow_link() {
    local target="$1"
    local source="$2"
    
    print_status "Testing stow link: $target"
    
    # Check if the target is a symbolic link
    if [ ! -L "$target" ]; then
        print_error "$target is not a symbolic link"
        return 1
    fi
    
    # Get the absolute path of the source
    local abs_source="$(cd "$(dirname "$source")" && pwd)/$(basename "$source")"
    
    # Get the absolute path of the target's link
    local abs_target="$(readlink -f "$target")"
    
    # Compare the paths
    if [ "$abs_target" = "$abs_source" ]; then
        print_success "$target is properly linked by stow"
        return 0
    else
        print_error "$target is not properly linked by stow"
        print_error "Expected: $abs_source"
        print_error "Got: $abs_target"
        return 1
    fi
}

test_file_exists() {
    local file="$1"
    print_status "Testing file existence: $file"
    
    if [ -f "$file" ]; then
        print_success "File exists: $file"
        return 0
    else
        print_error "File does not exist: $file"
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

# Main test execution
print_header "Testing $MODULE_NAME configuration"

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    # shellcheck source=../scripts/test-lib.sh
    . "$SCRIPT_DIR/../scripts/test-lib.sh"
    test_stow_link_portable "$CONFIG_DIR" "$SCRIPT_DIR/.config/glab"
    test_file_exists "$CONFIG_DIR/config.yml"
    print_success "Portable $MODULE_NAME tests completed"
    exit 0
fi

# Test stow links
test_stow_link "$CONFIG_DIR" "$SCRIPT_DIR/.config/glab"

# Test configuration files
test_file_exists "$CONFIG_DIR/config.yml"

# Test dependencies
test_dependency "glab"

# Test glab functionality (if authenticated)
print_status "Testing GitLab CLI functionality..."
if glab auth status >/dev/null 2>&1; then
    print_success "GitLab CLI is authenticated"
    print_status "GitLab CLI version:"
    glab version
else
    print_warning "GitLab CLI is not authenticated"
    print_warning "Run 'glab auth login' to authenticate"
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Run 'glab auth login' to authenticate with GitLab"
print_warning "2. Test with 'glab issue list' or 'glab mr list'"
print_warning "3. Configure your GitLab host if using self-hosted GitLab"
