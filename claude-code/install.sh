#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="claude-code"
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


# Official Anthropic installer. It downloads the release binary, verifies its
# checksum and runs "claude install" to set up the launcher in ~/.local/bin.
CLAUDE_INSTALLER_URL="https://claude.ai/install.sh"

# Print module header
print_header "Installing $MODULE_NAME"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# The installer itself refuses to run under sudo: it installs into $HOME, which
# under sudo resolves to root's home, leaving 'claude' missing from your shell.
if [ -n "${SUDO_USER:-}" ]; then
    print_error "Do not run this module through sudo - Claude Code installs into \$HOME"
    exit 1
fi

# Resolve the claude launcher: PATH first, then the install location, which is
# where it lands before the shell is restarted.
claude_bin_path() {
    if command -v claude >/dev/null 2>&1; then
        command -v claude
    elif [ -x "$HOME/.local/bin/claude" ]; then
        printf '%s\n' "$HOME/.local/bin/claude"
    else
        return 1
    fi
}

# "2.1.263 (Claude Code)" -> "2.1.263"
get_claude_version() {
    local bin
    bin="$(claude_bin_path)" || return 1
    "$bin" --version 2>/dev/null | awk 'NR==1 {print $1}'
}

install_claude_code() {
    # curl is the only hard requirement; the installer uses jq/zstd when present
    if ! command -v curl >/dev/null 2>&1; then
        if [ "$OS_TYPE" = "Darwin" ]; then
            print_error "curl is required to install Claude Code"
            exit 1
        fi
        print_status "Installing curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi

    local previous_version
    previous_version="$(get_claude_version || true)"
    if [ -n "$previous_version" ]; then
        print_status "Claude Code $previous_version is installed - re-running the installer to update..."
    else
        print_status "Installing Claude Code from $CLAUDE_INSTALLER_URL..."
    fi

    # pipefail so a failed download is not silently piped into bash
    if ! (set -o pipefail; curl -fsSL "$CLAUDE_INSTALLER_URL" | bash); then
        print_error "Claude Code installation failed"
        exit 1
    fi

    local installed_version
    installed_version="$(get_claude_version || true)"

    if [ -z "$installed_version" ]; then
        print_error "Claude Code does not appear to be installed - 'claude' not found"
        exit 1
    fi

    if [ -n "$previous_version" ] && [ "$previous_version" = "$installed_version" ]; then
        print_success "Claude Code $installed_version is already up to date"
    else
        print_success "Claude Code $installed_version installed"
    fi

    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) print_warning "$HOME/.local/bin is not in the current PATH - restart your shell to use 'claude'" ;;
    esac
}

install_claude_code

print_success "$MODULE_NAME installed successfully!"
print_warning "Run 'claude' once to sign in and complete the setup"
