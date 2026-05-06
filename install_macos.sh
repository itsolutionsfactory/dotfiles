#!/bin/bash

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
BREWFILE="$SCRIPT_DIR/Brewfile"

BASE="\033[0m"
TEXT="\033[38;2;205;214;244m"
SUBTEXT="\033[38;2;166;173;200m"
RED="\033[38;2;243;139;168m"
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
BLUE="\033[38;2;137;180;250m"
MAUVE="\033[38;2;203;166;247m"

declare -a MACOS_MODULE_ORDER=(
    "zsh"
    "certs"
    "hyfetch"
    "vim"
    "kitty"
    "kubectl"
    "github-cli"
    "gitlab-cli"
    "nvm"
)

declare -a MACOS_SKIP_MODULES=(
    "apt-packages"
    "snap-config"
    "flatpak-config"
    "appimaged"
    "docker"
    "slack"
    "powershell"
)

print_success() {
    echo -e "${GREEN}[✓]${BASE} $1"
}

print_error() {
    echo -e "${RED}[✗]${BASE} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${BASE} $1"
}

print_info() {
    echo -e "${BLUE}[i]${BASE} $1"
}

print_header() {
    echo -e "\n${MAUVE}=== $1 ===${BASE}\n"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_skipped_module() {
    local module=$1
    local skipped

    for skipped in "${MACOS_SKIP_MODULES[@]}"; do
        if [ "$module" = "$skipped" ]; then
            return 0
        fi
    done

    return 1
}

ensure_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        print_error "This installer is for MacOS only. Use install_ubuntu.sh on Ubuntu."
        exit 1
    fi
}

ensure_homebrew() {
    print_header "Checking Homebrew"

    if command_exists brew; then
        print_success "Homebrew is installed"
        return 0
    fi

    print_warning "Homebrew is not installed"
    print_info "Installing Homebrew from the official installer..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command_exists brew; then
        print_error "Homebrew installation completed, but brew is not available in PATH"
        print_warning "Open a new terminal or add Homebrew to your shell profile, then rerun this script"
        exit 1
    fi

    print_success "Homebrew installed successfully"
}

install_homebrew_bundle() {
    print_header "Installing MacOS Packages"

    if [ ! -f "$BREWFILE" ]; then
        print_error "Brewfile not found at $BREWFILE"
        exit 1
    fi

    brew bundle --file="$BREWFILE"
    print_success "Homebrew bundle completed"
}

update_homebrew_packages() {
    print_header "Updating Homebrew Packages"
    ensure_homebrew
    brew update
    brew upgrade
    brew upgrade --cask --greedy || true
    brew cleanup
    print_success "Homebrew packages updated"
}

ensure_directories() {
    mkdir -p "$BACKUP_DIR" "$HOME/.config"
    print_success "Ensured backup and .config directories exist"
}

install_module() {
    local module=$1
    local module_dir="$SCRIPT_DIR/$module"

    if is_skipped_module "$module"; then
        print_warning "Skipping MacOS-incompatible module: $module"
        return 0
    fi

    if [ ! -f "$module_dir/install.sh" ]; then
        print_warning "No install.sh found for module $module"
        return 0
    fi

    print_info "Installing $module module..."
    (
        cd "$module_dir"
        bash ./install.sh
    )
    print_success "$module installed successfully"
}

install_all_modules() {
    print_header "Installing All MacOS Modules"

    local module
    for module in "${MACOS_MODULE_ORDER[@]}"; do
        if [ -d "$SCRIPT_DIR/$module" ]; then
            install_module "$module"
        else
            print_warning "Module $module not found, skipping..."
        fi
    done
}

select_modules() {
    print_header "Available MacOS Modules"
    local i=1
    local modules=()
    local dir module

    for dir in "$SCRIPT_DIR"/*/; do
        module=$(basename "$dir")
        if [ -f "${dir}install.sh" ] && ! is_skipped_module "$module"; then
            echo -e "${TEXT}$i) ${BLUE}${module}${BASE}"
            modules+=("$module")
            ((i++))
        fi
    done

    echo -e "\n${TEXT}$i) ${GREEN}Install selected${BASE}"
    echo -e "${TEXT}$((i+1))) ${RED}Cancel${BASE}"

    local selected=()
    local choice
    while true; do
        read -r -p "$(echo -e "${SUBTEXT}Select a module number (or $i to install, $((i+1)) to cancel): ${BASE}")" choice

        if [ "$choice" -eq "$i" ]; then
            break
        elif [ "$choice" -eq "$((i+1))" ]; then
            print_info "Installation cancelled"
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
            selected+=("${modules[$((choice-1))]}")
            print_success "Module ${modules[$((choice-1))]} selected"
        else
            print_error "Invalid option"
        fi
    done

    print_header "Installing Selected MacOS Modules"
    for module in "${selected[@]}"; do
        install_module "$module"
    done
}

show_menu() {
    print_header "MacOS Dotfiles Installation Menu"
    echo -e "${TEXT}1) ${GREEN}Install all MacOS modules${BASE}"
    echo -e "${TEXT}2) ${BLUE}Select MacOS modules to install${BASE}"
    echo -e "${TEXT}3) ${RED}Exit${BASE}"

    read -r -p "$(echo -e "${SUBTEXT}Choose an option [1-3]: ${BASE}")" choice

    case $choice in
        1) install_all_modules ;;
        2) select_modules ;;
        3)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option. Exiting..."
            exit 1
            ;;
    esac
}

show_help() {
    print_header "MacOS Dotfiles Installation Help"
    echo -e "${TEXT}Usage:${BASE}"
    echo -e "  ${BLUE}./install.sh${BASE} [options]"
    echo
    echo -e "${TEXT}Options:${BASE}"
    echo -e "  ${GREEN}--all${BASE}          Install Homebrew packages and all MacOS modules"
    echo -e "  ${GREEN}--backup${BASE}       Only ensure backup and .config directories exist"
    echo -e "  ${GREEN}--update${BASE}       Update Homebrew packages"
    echo -e "  ${GREEN}--help${BASE}         Show this help message"
    echo
    echo -e "${TEXT}MacOS modules:${BASE} ${BLUE}${MACOS_MODULE_ORDER[*]}${BASE}"
    echo -e "${TEXT}Skipped Linux-only modules:${BASE} ${YELLOW}${MACOS_SKIP_MODULES[*]}${BASE}"
    exit 0
}

main() {
    ensure_macos

    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --all)
            ensure_homebrew
            install_homebrew_bundle
            ensure_directories
            install_all_modules
            ;;
        --backup)
            ensure_directories
            ;;
        --update)
            update_homebrew_packages
            ;;
        "")
            ensure_homebrew
            install_homebrew_bundle
            ensure_directories
            show_menu
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            ;;
    esac
}

main "$@"
