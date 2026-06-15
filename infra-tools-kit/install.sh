#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="infra-tools-kit"
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

# Print module header
print_header "Installing $MODULE_NAME configuration"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Ensure the local bin directory exists and is on PATH
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
    print_success "Created $BIN_DIR"
fi

case ":$PATH:" in
    *":$BIN_DIR:"*)
        print_status "$BIN_DIR is already on your PATH"
        ;;
    *)
        print_warning "$BIN_DIR is not on your PATH"
        print_warning "Add this line to your shell config (e.g. ~/.zshrc or ~/.bashrc):"
        print_warning "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        ;;
esac

# Create a symlink in BIN_DIR (named without the .sh extension) for every
# script in the module. Existing real files are backed up first; symlinks are
# refreshed in place. No file is ever copied.
link_count=0
for script in "$SCRIPT_DIR"/*.sh; do
    [ -e "$script" ] || continue

    script_name="$(basename "$script")"

    # Skip the module's own management scripts
    if [ "$script_name" = "install.sh" ] || [ "$script_name" = "test.sh" ]; then
        continue
    fi

    command_name="${script_name%.sh}"
    target="$BIN_DIR/$command_name"

    # Make sure the source script is executable
    chmod +x "$script"

    if [ -L "$target" ]; then
        # Existing symlink: refresh it to point at the current location
        ln -sfn "$script" "$target"
        print_success "Linked $command_name -> $script"
    elif [ -e "$target" ]; then
        # A real file/dir exists: back it up before replacing it
        local_timestamp="$(date +%Y%m%d_%H%M%S)"
        backup_path="$BACKUP_DIR/modules/$MODULE_NAME/$local_timestamp"
        mkdir -p "$backup_path"
        mv "$target" "$backup_path/"
        print_warning "Backed up existing $command_name to $backup_path"
        ln -sfn "$script" "$target"
        print_success "Linked $command_name -> $script"
    else
        ln -sfn "$script" "$target"
        print_success "Linked $command_name -> $script"
    fi

    link_count=$((link_count + 1))
done

if [ "$link_count" -eq 0 ]; then
    print_warning "No scripts found to link in $SCRIPT_DIR"
else
    print_success "$MODULE_NAME configuration installed successfully! ($link_count command(s) available)"
    print_status "You can now run the tools directly, e.g.: diag-network-report"
fi
