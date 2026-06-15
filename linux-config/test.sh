#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="linux-config"
BIN_DIR="$HOME/.local/bin"

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

# Verify that a script is linked into BIN_DIR (without the .sh extension) and
# that the symlink resolves back to the module's source script.
test_command_link() {
    local source="$1"
    local command_name
    command_name="$(basename "${source%.sh}")"
    local target="$BIN_DIR/$command_name"

    print_status "Testing command link: $command_name"

    if [ ! -L "$target" ]; then
        print_error "$target is not a symbolic link"
        return 1
    fi

    local abs_source
    abs_source="$(cd "$(dirname "$source")" && pwd)/$(basename "$source")"
    local abs_target
    abs_target="$(readlink -f "$target")"

    if [ "$abs_target" != "$abs_source" ]; then
        print_error "$target does not point to $abs_source (got: $abs_target)"
        return 1
    fi

    if [ ! -x "$target" ]; then
        print_error "$command_name is not executable"
        return 1
    fi

    if ! command -v "$command_name" >/dev/null 2>&1; then
        print_error "$command_name is not resolvable from PATH"
        return 1
    fi

    print_success "$command_name is correctly linked and on PATH"
    return 0
}

print_header "Testing $MODULE_NAME configuration"

failures=0
for script in "$SCRIPT_DIR"/*.sh; do
    [ -e "$script" ] || continue
    script_name="$(basename "$script")"
    if [ "$script_name" = "install.sh" ] || [ "$script_name" = "test.sh" ]; then
        continue
    fi
    test_command_link "$script" || failures=$((failures + 1))
done

if [ "$failures" -ne 0 ]; then
    print_error "$failures command(s) failed verification"
    exit 1
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Open a new terminal and run a tool by name (e.g. diag-network-report)"
print_warning "2. Ensure \$HOME/.local/bin is on your PATH"
