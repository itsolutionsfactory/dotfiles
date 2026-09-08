#!/bin/bash

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"

declare -a REQUIRED_APT_PACKAGES=(
    "stow"
    "git"
    "wget"
    "unzip"
    "fontconfig"
    "curl"
    "libfuse2t64"  # FUSE2 runtime (AppImage); renamed from libfuse2 in the t64 transition. Present on 24.04+; the old "libfuse2" stub is dropped in 26.04.
)

declare -a REQUIRED_SNAP_PACKAGES=(
    # Add snap packages here as needed
)

BASE="\033[0m"
TEXT="\033[38;2;205;214;244m"
SUBTEXT="\033[38;2;166;173;200m"
RED="\033[38;2;243;139;168m"
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
BLUE="\033[38;2;137;180;250m"
MAUVE="\033[38;2;203;166;247m"

print_success() {
    echo -e "${GREEN}[✓] $1${BASE}"
}

print_error() {
    echo -e "${RED}[✗] $1${BASE}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${BASE}"
}

print_info() {
    echo -e "${BLUE}[i] $1${BASE}"
}

print_header() {
    echo -e "\n${MAUVE}=== $1 ===${BASE}\n"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_apt() {
    local package=$1
    print_info "Installing $package via apt..."
    sudo apt-get update
    sudo apt-get install -y "$package"
    print_success "$package installed successfully"
}

install_snap() {
    local package=$1
    print_info "Installing $package via snap..."
    sudo snap install "$package"
    print_success "$package installed successfully"
}

update_apt_packages() {
    print_header "Updating APT Packages"
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get full-upgrade -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    print_success "APT packages updated"
}

update_snap_packages() {
    print_header "Updating Snap Packages"
    if command_exists snap; then
        sudo snap refresh
        print_success "Snap packages refreshed"
    else
        print_warning "snap is not installed, skipping Snap updates"
    fi
}

update_flatpak_packages() {
    print_header "Updating Flatpak Packages"
    if ! command_exists flatpak; then
        print_warning "flatpak is not installed, skipping Flatpak updates"
        return 0
    fi

    sudo flatpak update --system -y
    print_success "Flatpak packages updated"
}

update_all_packages() {
    print_header "Updating All Ubuntu Packages"
    update_apt_packages
    update_snap_packages
    update_flatpak_packages
    print_success "All Ubuntu packages updated successfully!"
}

show_help() {
    print_header "Ubuntu Dotfiles Installation Help"
    echo -e "${TEXT}Usage:${BASE}"
    echo -e "  ${BLUE}./install.sh${BASE} [options]"
    echo
    echo -e "${TEXT}Options:${BASE}"
    echo -e "  ${GREEN}--all${BASE}          Install all Ubuntu modules in predefined order without prompts"
    echo -e "  ${GREEN}--backup${BASE}       Only ensure the backup and .config directories exist"
    echo -e "  ${GREEN}--update${BASE}       Update apt, snap, and flatpak packages"
    echo -e "  ${GREEN}--help${BASE}         Show this help message"
    echo
    echo -e "${TEXT}Installation Order (--all):${BASE}"
    echo -e "  ${BLUE}1.${BASE}  apt-packages"
    echo -e "  ${BLUE}2.${BASE}  certs"
    echo -e "  ${BLUE}3.${BASE}  zsh"
    echo -e "  ${BLUE}4.${BASE}  hyfetch"
    echo -e "  ${BLUE}5.${BASE}  snap-config"
    echo -e "  ${BLUE}6.${BASE}  flatpak-config"
    echo -e "  ${BLUE}7.${BASE}  vim"
    echo -e "  ${BLUE}8.${BASE}  kitty"
    echo -e "  ${BLUE}9.${BASE}  kubectl"
    echo -e "  ${BLUE}10.${BASE} github-cli"
    echo -e "  ${BLUE}11.${BASE} slack"
    echo -e "  ${BLUE}12.${BASE} docker"
    echo -e "  ${BLUE}13.${BASE} nvm"
    echo -e "  ${BLUE}14.${BASE} gitlab-cli"
    echo -e "  ${BLUE}15.${BASE} infra-tools-kit"
    echo -e "  ${BLUE}16.${BASE} claude-code"
    exit 0
}

ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory at $BACKUP_DIR"
    fi
}

handle_config_directory() {
    local config_path="$HOME/.config"

    if [ -d "$config_path" ]; then
        print_warning "Found existing .config directory. No changes will be made to it by the main installer."
    else
        print_info "No existing .config directory found"
        mkdir -p "$config_path"
        print_success "Created new .config directory"
    fi
}

install_module() {
    local module_dir=$1
    local module_name
    module_name=$(basename "$module_dir")

    print_info "Installing $module_name configuration..."

    if [ -f "$SCRIPT_DIR/$module_dir/install.sh" ]; then
        (
            cd "$SCRIPT_DIR/$module_dir"
            bash ./install.sh
        )
        print_success "$module_name installed successfully"
    else
        print_warning "No install.sh found in $module_name"
    fi
}

install_all_modules() {
    print_header "Installing All Ubuntu Modules"

    declare -a MODULE_ORDER=(
        "apt-packages"
        "certs"
        "zsh"
        "hyfetch"
        "snap-config"
        "flatpak-config"
        "vim"
        "kitty"
        "kubectl"
        "github-cli"
        "slack"
        "docker"
        "nvm"
        "gitlab-cli"
        "infra-tools-kit"
        "claude-code"
    )

    for module in "${MODULE_ORDER[@]}"; do
        if [ -d "$SCRIPT_DIR/$module" ]; then
            install_module "$module"
        else
            print_warning "Module $module not found, skipping..."
        fi
    done
}

select_modules() {
    print_header "Available Ubuntu Modules"
    local i=1
    local modules=()

    for dir in "$SCRIPT_DIR"/*/; do
        local module_name
        module_name=$(basename "$dir")
        if [ "$module_name" != ".cursor" ] && [ "$module_name" != "backup" ] && [ -f "${dir}install.sh" ]; then
            echo -e "${TEXT}$i) ${BLUE}${module_name}${BASE}"
            modules+=("$module_name")
            ((i++))
        fi
    done

    echo -e "\n${TEXT}$i) ${GREEN}Install selected${BASE}"
    echo -e "${TEXT}$((i+1))) ${RED}Cancel${BASE}"

    local selected=()
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

    print_header "Installing Selected Ubuntu Modules"
    for module in "${selected[@]}"; do
        install_module "$module"
    done
}

show_menu() {
    print_header "Ubuntu Dotfiles Installation Menu"
    echo -e "${TEXT}1) ${GREEN}Install all modules${BASE}"
    echo -e "${TEXT}2) ${BLUE}Select modules to install${BASE}"
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

check_and_install_tools() {
    print_header "Checking Required Ubuntu Tools"

    for package in "${REQUIRED_APT_PACKAGES[@]}"; do
        if ! command_exists "$package"; then
            print_warning "$package not found"
            install_apt "$package"
        else
            print_success "$package is installed"
        fi
    done

    for package in "${REQUIRED_SNAP_PACKAGES[@]}"; do
        if ! snap list "$package" >/dev/null 2>&1; then
            print_warning "$package not found"
            install_snap "$package"
        else
            print_success "$package is installed"
        fi
    done
}

main() {
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --all)
            check_and_install_tools
            ensure_backup_dir
            handle_config_directory
            install_all_modules
            ;;
        --backup)
            ensure_backup_dir
            handle_config_directory
            ;;
        --update)
            update_all_packages
            ;;
        "")
            check_and_install_tools
            ensure_backup_dir
            handle_config_directory
            show_menu
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            ;;
    esac
}

main "$@"
