#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="github-cli"
CONFIG_DIR="$HOME/.config/gh"
OS_TYPE="$(uname -s)"

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

# shellcheck source=../scripts/test-lib.sh
. "$SCRIPT_DIR/../scripts/test-lib.sh"

# Test functions
test_stow_link() {
    local target="$1"
    local source="$2"

    test_stow_link_portable "$target" "$source"
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

test_directory_exists() {
    local dir="$1"
    print_status "Testing directory existence: $dir"
    
    if [ -d "$dir" ]; then
        print_success "Directory exists: $dir"
        return 0
    else
        print_error "Directory does not exist: $dir"
        return 1
    fi
}

test_file_permissions() {
    local file="$1"
    local expected_perms="$2"
    print_status "Testing file permissions: $file"

    local actual_perms
    file="$(resolve_path_portable "$file")"

    if [ "$OS_TYPE" = "Darwin" ]; then
        actual_perms=$(stat -f "%Lp" "$file")
    else
        actual_perms=$(stat -c "%a" "$file")
    fi
    if [ "$actual_perms" = "$expected_perms" ]; then
        print_success "File permissions correct: $file ($expected_perms)"
        return 0
    else
        print_error "File permissions incorrect: $file"
        print_error "Expected: $expected_perms"
        print_error "Got: $actual_perms"
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

test_package_installed() {
    local package="$1"
    print_status "Testing package installation: $package"

    if [ "$OS_TYPE" = "Darwin" ]; then
        if brew list "$package" >/dev/null 2>&1; then
            print_success "Package installed: $package"
            return 0
        fi
    elif dpkg -l "$package" &>/dev/null; then
        print_success "Package installed: $package"
        return 0
    fi

    print_error "Package not installed: $package"
    return 1
}

test_github_cli_version() {
    print_status "Testing GitHub CLI version"
    
    if command -v gh >/dev/null 2>&1; then
        local version=$(gh version)
        print_success "GitHub CLI version: $version"
        return 0
    else
        print_error "GitHub CLI not found"
        return 1
    fi
}

test_github_cli_help() {
    print_status "Testing GitHub CLI help command"
    
    if gh --help >/dev/null 2>&1; then
        print_success "GitHub CLI help command works"
        return 0
    else
        print_error "GitHub CLI help command failed"
        return 1
    fi
}

test_apt_repository() {
    print_status "Testing GitHub CLI apt repository"

    if [ "$OS_TYPE" != "Linux" ]; then
        print_warning "APT repository check is Linux-only, skipping"
        return 0
    fi

    if [ -f "/etc/apt/sources.list.d/github-cli.list" ]; then
        print_success "GitHub CLI apt repository configured"
        return 0
    else
        print_warning "GitHub CLI apt repository not found (may be installed manually)"
        return 0
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    # shellcheck source=../scripts/test-lib.sh
    . "$SCRIPT_DIR/../scripts/test-lib.sh"
    test_stow_link_portable "$CONFIG_DIR" "$SCRIPT_DIR/.config/gh"
    test_file_exists "$CONFIG_DIR/config.yml"
    print_success "Portable $MODULE_NAME tests completed"
    exit 0
fi

# Test dependencies
test_dependency "gh"
test_dependency "curl"
test_package_installed "gh"

# Test apt repository configuration
test_apt_repository

# Test GitHub CLI functionality
test_github_cli_version
test_github_cli_help

# Test configuration directory
test_directory_exists "$CONFIG_DIR"

# Test stow links
test_stow_link "$CONFIG_DIR/config.yml" "$SCRIPT_DIR/.config/gh/config.yml"

if [ -f "$SCRIPT_DIR/.config/gh/hosts.yml" ]; then
    test_stow_link "$CONFIG_DIR/hosts.yml" "$SCRIPT_DIR/.config/gh/hosts.yml"
else
    print_warning "hosts.yml is not managed by this module; skipping stow link check"
fi

# Test configuration files if they exist
if [ -f "$CONFIG_DIR/config.yml" ]; then
    test_file_exists "$CONFIG_DIR/config.yml"
    test_file_permissions "$CONFIG_DIR/config.yml" "644"
fi

if [ -f "$CONFIG_DIR/hosts.yml" ]; then
    test_file_exists "$CONFIG_DIR/hosts.yml"
    test_file_permissions "$CONFIG_DIR/hosts.yml" "644"
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Run 'gh auth status' to check authentication"
print_warning "2. Test GitHub CLI commands like 'gh repo view'"
print_warning "3. Verify your GitHub configuration with 'gh config list'"
print_warning "4. Test repository operations if authenticated" 