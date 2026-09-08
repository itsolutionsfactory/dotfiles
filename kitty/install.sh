#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="kitty"
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

# Print module header
print_header "Installing $MODULE_NAME configuration"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup existing configuration if it exists
if [ -d "$HOME/.config/kitty" ]; then
    print_status "Backing up existing Kitty configuration..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    tar -czf "$BACKUP_DIR/kitty_backup_$TIMESTAMP.tar.gz" -C "$HOME" .config/kitty
    print_success "Backup created at $BACKUP_DIR/kitty_backup_$TIMESTAMP.tar.gz"

    # Remove existing configuration after backup
    print_status "Removing existing Kitty configuration..."
    rm -rf "$HOME/.config/kitty"
    print_success "Existing configuration removed"
fi

# Upstream binary install location used by the official kitty installer
KITTY_APP_DIR="$HOME/.local/kitty.app"
KITTY_VERSION_URL="https://sw.kovidgoyal.net/kitty/current-version.txt"
KITTY_INSTALLER_URL="https://sw.kovidgoyal.net/kitty/installer.sh"

# Latest released version according to upstream
get_latest_kitty_version() {
    curl -fsSL --max-time 20 "$KITTY_VERSION_URL" 2>/dev/null | tr -d '[:space:]'
}

# Version reported by a kitty binary, e.g. "kitty 0.48.2 created by ..." -> "0.48.2"
get_kitty_version() {
    "$1" --version 2>/dev/null | awk 'NR==1 {print $2}'
}

# Put kitty/kitten on PATH and register the desktop entries, as documented at
# https://sw.kovidgoyal.net/kitty/binary/
link_kitty_launchers() {
    print_status "Linking Kitty binaries into ~/.local/bin..."
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.config"
    ln -sf "$KITTY_APP_DIR/bin/kitty" "$KITTY_APP_DIR/bin/kitten" "$HOME/.local/bin/"

    local desktop_file
    for desktop_file in kitty.desktop kitty-open.desktop; do
        if [ -f "$KITTY_APP_DIR/share/applications/$desktop_file" ]; then
            cp "$KITTY_APP_DIR/share/applications/$desktop_file" "$HOME/.local/share/applications/"
            sed -i "s|Icon=kitty|Icon=$KITTY_APP_DIR/share/icons/hicolor/256x256/apps/kitty.png|g" \
                "$HOME/.local/share/applications/$desktop_file"
            sed -i "s|Exec=kitty|Exec=$KITTY_APP_DIR/bin/kitty|g" \
                "$HOME/.local/share/applications/$desktop_file"
        fi
    done

    # Make desktop environments that honour xdg-terminal-exec use Kitty
    echo 'kitty.desktop' > "$HOME/.config/xdg-terminals.list"
    print_success "Kitty launchers and desktop entries registered"

    # An apt-managed Kitty would be an older build; ~/.local/bin wins in PATH,
    # but leaving it installed is confusing so point it out.
    if command -v dpkg >/dev/null 2>&1 && dpkg -s kitty >/dev/null 2>&1; then
        print_warning "An apt-managed 'kitty' package is still installed and is older than the upstream build"
        print_warning "Remove it with: sudo apt-get remove -y kitty"
    fi

    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) print_warning "$HOME/.local/bin is not in the current PATH - restart your shell before running kitty" ;;
    esac
}

# Install or upgrade to the latest upstream Kitty release. The distro packages
# lag well behind upstream, so the official installer is used instead of apt.
install_kitty_linux() {
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl is required to install Kitty from upstream"
        exit 1
    fi
    if ! command -v tar >/dev/null 2>&1 || ! command -v xz >/dev/null 2>&1; then
        print_status "Installing Kitty installer dependencies (tar, xz-utils)..."
        sudo apt-get update
        sudo apt-get install -y tar xz-utils
    fi

    local latest_version installed_version
    latest_version="$(get_latest_kitty_version)"
    if [ -z "$latest_version" ]; then
        print_warning "Could not determine the latest Kitty version from $KITTY_VERSION_URL"
        print_warning "Falling back to whatever the installer considers current"
    else
        print_status "Latest upstream Kitty release: $latest_version"
    fi

    if [ -x "$KITTY_APP_DIR/bin/kitty" ]; then
        installed_version="$(get_kitty_version "$KITTY_APP_DIR/bin/kitty")"
        if [ -n "$latest_version" ] && [ "$installed_version" = "$latest_version" ]; then
            print_success "Kitty $installed_version is already up to date"
            link_kitty_launchers
            return 0
        fi
        print_status "Upgrading Kitty ${installed_version:-unknown} -> ${latest_version:-latest}..."
    else
        print_status "Installing Kitty ${latest_version:-latest}..."
    fi

    local temp_dir
    temp_dir="$(mktemp -d)"
    if ! curl -fsSL --max-time 60 -o "$temp_dir/installer.sh" "$KITTY_INSTALLER_URL"; then
        print_error "Failed to download the Kitty installer from $KITTY_INSTALLER_URL"
        rm -rf "$temp_dir"
        exit 1
    fi

    # launch=n keeps the installer headless; pinning the version we reported
    # above keeps the install reproducible within a single run.
    local -a installer_args=("launch=n")
    if [ -n "$latest_version" ]; then
        installer_args+=("installer=version-$latest_version")
    fi

    if ! sh "$temp_dir/installer.sh" "${installer_args[@]}"; then
        print_error "The Kitty installer failed"
        rm -rf "$temp_dir"
        exit 1
    fi
    rm -rf "$temp_dir"

    link_kitty_launchers

    installed_version="$(get_kitty_version "$KITTY_APP_DIR/bin/kitty")"
    if [ -n "$installed_version" ]; then
        print_success "Kitty $installed_version installed in $KITTY_APP_DIR"
    else
        print_error "Kitty does not appear to be installed in $KITTY_APP_DIR"
        exit 1
    fi
}

# Install or upgrade to the latest Kitty cask on MacOS. Homebrew auto-updates
# its taps on install/upgrade, so the cask is always the current release.
install_kitty_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        print_warning "Homebrew is unavailable - skipping Kitty installation"
        return 0
    fi

    if brew list --cask kitty >/dev/null 2>&1; then
        print_status "Upgrading Kitty to the latest cask release..."
        if ! brew upgrade --cask kitty; then
            print_warning "Kitty is already at the latest cask release"
        fi
    else
        print_status "Installing Kitty via Homebrew..."
        brew install --cask kitty
    fi

    local kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
    if [ -x "$kitty_bin" ]; then
        print_success "Kitty $(get_kitty_version "$kitty_bin") installed"
    fi
}

# Check if running in Docker
if [ -f /.dockerenv ]; then
    print_warning "Running in Docker environment - skipping Kitty installation"
    print_warning "Kitty requires a desktop environment and cannot be installed in Docker"
elif [ "$OS_TYPE" = "Darwin" ]; then
    install_kitty_macos
else
    install_kitty_linux
fi

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config" .config; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"
if [ ! -f /.dockerenv ]; then
    print_warning "Please restart Kitty for the changes to take effect"
fi
