#!/bin/bash

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASE="\033[0m"
RED="\033[38;2;243;139;168m"
BLUE="\033[38;2;137;180;250m"
GREEN="\033[38;2;166;227;161m"

print_info() {
    echo -e "${BLUE}[i]${BASE} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${BASE} $1"
}

print_error() {
    echo -e "${RED}[✗]${BASE} $1"
}

case "$(uname -s)" in
    Linux)
        print_info "Detected Linux, using Ubuntu installer"
        exec bash "$SCRIPT_DIR/install_ubuntu.sh" "$@"
        ;;
    Darwin)
        print_info "Detected MacOS, using Homebrew installer"
        exec bash "$SCRIPT_DIR/install_macos.sh" "$@"
        ;;
    *)
        print_error "Unsupported operating system: $(uname -s)"
        exit 1
        ;;
esac
