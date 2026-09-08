#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="claude-code"

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

print_header "Testing $MODULE_NAME installation"

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    # Portable mode (CI): the module installs a binary rather than stowing
    # configuration, so there is nothing filesystem-local to verify here.
    print_success "Portable $MODULE_NAME tests completed"
    exit 0
fi

CLAUDE_BIN="$HOME/.local/bin/claude"
FAILED=0

if command -v claude >/dev/null 2>&1; then
    print_success "Claude Code is on PATH ($(command -v claude))"
elif [ -x "$CLAUDE_BIN" ]; then
    print_warning "Claude Code is installed at $CLAUDE_BIN but not on PATH - restart your shell"
else
    print_error "Claude Code is not installed"
    FAILED=1
fi

if [ "$FAILED" -eq 0 ]; then
    if command -v claude >/dev/null 2>&1; then
        RESOLVED_BIN="$(command -v claude)"
    else
        RESOLVED_BIN="$CLAUDE_BIN"
    fi

    # "2.1.263 (Claude Code)" -> "2.1.263"
    CLAUDE_VERSION="$("$RESOLVED_BIN" --version 2>/dev/null | awk 'NR==1 {print $1}')"
    if [ -n "$CLAUDE_VERSION" ]; then
        print_success "Claude Code version: $CLAUDE_VERSION"
    else
        print_error "Could not read the Claude Code version"
        FAILED=1
    fi

    if [ -d "$HOME/.claude" ]; then
        print_success "Claude Code data directory present (~/.claude)"
    else
        print_warning "No ~/.claude directory yet - run 'claude' once to complete setup"
    fi
fi

if [ "$FAILED" -ne 0 ]; then
    print_error "Testing failed!"
    exit 1
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Run 'claude' and confirm you can sign in"
print_warning "2. Run 'claude doctor' to check the installation health"
