#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="hyfetch"
OS_TYPE="$(uname -s)"
HYFETCH_CONFIG="$HOME/.config/hyfetch.json"
NEOWOFETCH_CONFIG="$HOME/.config/neowofetch/config.conf"
LEGACY_NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"

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

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Install HyFetch if not already installed
if ! command -v hyfetch &> /dev/null; then
    print_status "Installing hyfetch..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            print_error "Homebrew is required to install hyfetch on MacOS"
            exit 1
        fi
        brew install hyfetch
    else
        sudo apt-get update
        sudo apt-get install -y hyfetch
    fi
    print_success "hyfetch installed successfully"
else
    print_status "hyfetch is already installed"
fi

# Install Hack Nerd Font if not already installed
if [ "$OS_TYPE" = "Darwin" ]; then
    font_installed() {
        system_profiler SPFontsDataType 2>/dev/null | grep -i "Hack Nerd Font" &> /dev/null
    }
else
    font_installed() {
        fc-list | grep -i "Hack Nerd Font" &> /dev/null
    }
fi

if ! font_installed; then
    print_status "Installing Hack Nerd Font..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            print_error "Homebrew is required to install fonts on MacOS"
            exit 1
        fi
        brew install --cask font-hack-nerd-font
    else
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip -O /tmp/hack.zip
        unzip -q /tmp/hack.zip -d /tmp/hack
        cp /tmp/hack/*.ttf "$FONT_DIR"
        rm -rf /tmp/hack /tmp/hack.zip
        fc-cache -f -v
    fi
    print_success "Hack Nerd Font installed successfully"
else
    print_status "Hack Nerd Font is already installed"
fi

resolve_link_target() {
    local link_path="$1"
    local link_target
    link_target="$(readlink "$link_path" || true)"

    case "$link_target" in
        /*) printf '%s\n' "$link_target" ;;
        *)
            (
                cd "$(dirname "$link_path")"
                cd "$(dirname "$link_target")"
                printf '%s/%s\n' "$(pwd -P)" "$(basename "$link_target")"
            )
            ;;
    esac
}

backup_existing_config() {
    local config_path="$1"
    local backup_name="$2"

    if [ -e "$config_path" ] || [ -L "$config_path" ]; then
        if [ -L "$config_path" ]; then
            local symlink_target
            symlink_target="$(resolve_link_target "$config_path")"

            case "$symlink_target" in
                "$SCRIPT_DIR"/*)
                    print_status "Removing existing symlink: $config_path"
                    rm "$config_path"
                    ;;
                *)
                    print_error "Refusing to remove user-managed symlink: $config_path -> $symlink_target"
                    print_error "Please back it up or remove it manually before installing $MODULE_NAME"
                    exit 1
                    ;;
            esac
            return 0
        fi

        print_status "Backing up existing configuration: $config_path"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        mkdir -p "$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP"
        mv "$config_path" "$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP/$backup_name"
        print_success "Backup created at $BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP/$backup_name"
    fi
}

backup_existing_config "$HYFETCH_CONFIG" "hyfetch.json"
backup_existing_config "$NEOWOFETCH_CONFIG" "config.conf"

# Remove the old stowed Neofetch symlink if this repository installed it previously.
if [ -L "$LEGACY_NEOFETCH_CONFIG" ]; then
    legacy_target="$(readlink "$LEGACY_NEOFETCH_CONFIG" || true)"
    case "$legacy_target" in
        "$SCRIPT_DIR"/*|"$SCRIPT_DIR/../neofetch"/*)
            print_status "Removing legacy neofetch configuration symlink..."
            rm "$LEGACY_NEOFETCH_CONFIG"
            ;;
        *)
            print_warning "Legacy neofetch configuration symlink points outside this module, leaving it unchanged"
            ;;
    esac
elif [ -f "$LEGACY_NEOFETCH_CONFIG" ]; then
    print_warning "Existing neofetch configuration found and left unchanged: $LEGACY_NEOFETCH_CONFIG"
fi

# Create target directories if they do not exist
print_status "Creating target directories..."
mkdir -p "$HOME/.config" "$HOME/.config/neowofetch"

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config" .config; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

if command -v neofetch &> /dev/null; then
    print_warning "The discontinued neofetch command is still installed. HyFetch will be used by this dotfiles setup."
fi

print_success "$MODULE_NAME configuration installed successfully!"
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Open a new terminal and verify HyFetch displays correctly"
print_warning "2. Run 'hyfetch -c' if you want to customize the color preset"