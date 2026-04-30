#!/bin/bash

# Exit on any error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/backup"

# Dependencies
declare -a REQUIRED_APT_PACKAGES=(
    "stow"
    "git"
    "wget"
    "unzip"
    "fontconfig"
    "curl"
    "libfuse2"
)

declare -a REQUIRED_SNAP_PACKAGES=(
    # Add snap packages here as needed
)

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

# Function to print with colors
print_text() {
    echo -e "${TEXT}$1${BASE}"
}

print_subtext() {
    echo -e "${SUBTEXT}$1${BASE}"
}

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a package using apt
install_apt() {
    local package=$1
    print_info "Installing $package via apt..."
    sudo apt-get update
    sudo apt-get install -y "$package"
    print_success "$package installed successfully"
}

# Function to install a package using snap
install_snap() {
    local package=$1
    print_info "Installing $package via snap..."
    sudo snap install "$package"
    print_success "$package installed successfully"
}

# Function to update all apt packages
update_apt_packages() {
    print_header "Updating APT Packages"
    print_info "Updating package lists..."
    sudo apt-get update
    print_success "Package lists updated"
    
    print_info "Upgrading all installed packages..."
    sudo apt-get upgrade -y
    print_success "All packages upgraded"
    
    print_info "Performing full system upgrade (if available)..."
    sudo apt-get full-upgrade -y
    print_success "Full system upgrade completed"
    
    print_info "Cleaning up unused packages..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    print_success "Cleanup completed"
}

# Function to update all snap packages
update_snap_packages() {
    print_header "Updating Snap Packages"
    print_info "Refreshing all snap packages..."
    sudo snap refresh
    print_success "All snap packages refreshed"
}

# Function to update all flatpak packages
update_flatpak_packages() {
    print_header "Updating Flatpak Packages"

    if ! command_exists flatpak; then
        print_warning "flatpak is not installed, skipping Flatpak updates"
        return 0
    fi

    print_info "Updating all system Flatpak packages..."
    sudo flatpak update --system -y
    print_success "All system Flatpak packages updated"
}

# Function to update all packages (apt, snap, and flatpak)
update_all_packages() {
    print_header "Updating All System Packages"
    update_apt_packages
    update_snap_packages
    update_flatpak_packages
    print_success "All packages updated successfully!"
}

# Function to show help
show_help() {
    print_header "Dotfiles Installation Help"
    echo -e "${TEXT}Usage:${BASE}"
    echo -e "  ${BLUE}./install.sh${BASE} [options]"
    echo
    echo -e "${TEXT}Options:${BASE}"
    echo -e "  ${GREEN}--all${BASE}          Install all modules in predefined order without prompts"
    echo -e "  ${GREEN}--backup${BASE}       Only handle backup of existing .config"
    echo -e "  ${GREEN}--update${BASE}       Update all apt, snap, and flatpak packages"
    echo -e "  ${GREEN}--help${BASE}         Show this help message"
    echo
    echo -e "${TEXT}Installation Order (--all):${BASE}"
    echo -e "  ${BLUE}1.${BASE}  apt-packages    # System packages and WireGuard VPN"
    echo -e "  ${BLUE}2.${BASE}  certs          # SSL/TLS certificates"
    echo -e "  ${BLUE}3.${BASE}  zsh            # Enhanced shell configuration"
    echo -e "  ${BLUE}4.${BASE}  hyfetch        # System information display"
    echo -e "  ${BLUE}5.${BASE}  snap-config    # Snap package management"
    echo -e "  ${BLUE}6.${BASE}  flatpak-config # Flatpak package management and Teams"
    echo -e "  ${BLUE}7.${BASE}  vim            # Neovim text editor"
    echo -e "  ${BLUE}8.${BASE}  kitty          # Terminal emulator"
    echo -e "  ${BLUE}9.${BASE}  kubectl        # Kubernetes CLI tools"
    echo -e "  ${BLUE}10.${BASE} github-cli     # GitHub command-line interface"
    echo -e "  ${BLUE}11.${BASE} slack          # Slack desktop application"
    echo -e "  ${BLUE}12.${BASE} docker         # Docker configuration"
    echo -e "  ${BLUE}13.${BASE} nvm            # Node Version Manager"
    echo -e "  ${BLUE}14.${BASE} gitlab-cli     # GitLab command-line interface"
    echo
    echo -e "${TEXT}Examples:${BASE}"
    echo -e "  ${BLUE}./install.sh${BASE}           # Interactive installation"
    echo -e "  ${BLUE}./install.sh --all${BASE}     # Install everything in order"
    echo -e "  ${BLUE}./install.sh --backup${BASE}  # Only handle backup"
    echo -e "  ${BLUE}./install.sh --update${BASE}  # Update all apt, snap, and flatpak packages"
    exit 0
}

# Function to ensure backup directory exists
ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory at $BACKUP_DIR"
    fi
}

# Function to handle .config directory
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

# Function to display and handle menu
show_menu() {
    print_header "Dotfiles Installation Menu"
    echo -e "${TEXT}1) ${GREEN}Install all modules${BASE}"
    echo -e "${TEXT}2) ${BLUE}Select modules to install${BASE}"
    echo -e "${TEXT}3) ${RED}Exit${BASE}"
    
    read -p "$(echo -e "${SUBTEXT}Choose an option [1-3]: ${BASE}")" choice
    
    case $choice in
        1)
            install_all_modules
            ;;
        2)
            select_modules
            ;;
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

# Function to install all modules in specific order
install_all_modules() {
    print_header "Installing All Modules"
    
    # Define installation order
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
    )
    
    # Install modules in the specified order
    for module in "${MODULE_ORDER[@]}"; do
        if [ -d "$module" ]; then
            install_module "$module/"
        else
            print_warning "Module $module not found, skipping..."
        fi
    done
}

# Function to select specific modules
select_modules() {
    print_header "Available Modules"
    local i=1
    local modules=()
    
    for dir in */; do
        if [ "$dir" != ".cursor/" ] && [ "$dir" != "backup/" ] && [ -d "$dir" ]; then
            echo -e "${TEXT}$i) ${BLUE}${dir%/}${BASE}"
            modules+=("$dir")
            ((i++))
        fi
    done
    
    echo -e "\n${TEXT}$i) ${GREEN}Install selected${BASE}"
    echo -e "${TEXT}$((i+1))) ${RED}Cancel${BASE}"
    
    local selected=()
    while true; do
        read -p "$(echo -e "${SUBTEXT}Select a module number (or $i to install, $((i+1)) to cancel): ${BASE}")" choice
        
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
    
    print_header "Installing Selected Modules"
    for module in "${selected[@]}"; do
        install_module "$module"
    done
}

# Function to install a module
install_module() {
    local module_dir=$1
    local module_name=$(basename "$module_dir")
    
    print_info "Installing $module_name configuration..."
    
    if [ -f "$module_dir/install.sh" ]; then
        cd "$module_dir"
        ./install.sh
        cd "$SCRIPT_DIR"
        print_success "$module_name installed successfully"
    else
        print_warning "No install.sh found in $module_name"
    fi
}

# Function to check and install required tools
check_and_install_tools() {
    print_header "Checking Required Tools"
    
    # Check and install apt packages
    for package in "${REQUIRED_APT_PACKAGES[@]}"; do
        if ! command_exists "$package"; then
            print_warning "$package not found"
            install_apt "$package"
        else
            print_success "$package is installed"
        fi
    done
    
    # Check and install snap packages
    for package in "${REQUIRED_SNAP_PACKAGES[@]}"; do
        if ! snap list "$package" &> /dev/null; then
            print_warning "$package not found"
            install_snap "$package"
        else
            print_success "$package is installed"
        fi
    done
}

# Main installation process
main() {
    # Show help if requested
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
    fi
    
    # Check for --all parameter
    if [ "$1" = "--all" ]; then
        check_and_install_tools
        handle_config_directory
        install_all_modules
        exit 0
    fi
    
    # Check for --backup parameter
    if [ "$1" = "--backup" ]; then
        handle_config_directory
        exit 0
    fi
    
    # Check for --update parameter
    if [ "$1" = "--update" ]; then
        update_all_packages
        exit 0
    fi
    
    # Normal interactive mode
    check_and_install_tools
    handle_config_directory
    show_menu
}

# Run the main function
main "$@" 
