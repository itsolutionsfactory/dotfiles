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

# Function to show help
show_help() {
    print_header "Dotfiles Installation Help"
    echo -e "${TEXT}Usage:${BASE}"
    echo -e "  ${BLUE}./install.sh${BASE} [options]"
    echo
    echo -e "${TEXT}Options:${BASE}"
    echo -e "  ${GREEN}--all${BASE}          Install all modules without prompts"
    echo -e "  ${GREEN}--backup${BASE}       Only handle backup of existing .config"
    echo -e "  ${GREEN}--help${BASE}         Show this help message"
    echo
    echo -e "${TEXT}Examples:${BASE}"
    echo -e "  ${BLUE}./install.sh${BASE}           # Interactive installation"
    echo -e "  ${BLUE}./install.sh --all${BASE}     # Install everything"
    echo -e "  ${BLUE}./install.sh --backup${BASE}  # Only handle backup"
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

# Function to install all modules
install_all_modules() {
    print_header "Installing All Modules"
    for dir in */; do
        if [ "$dir" != ".cursor/" ] && [ "$dir" != "backup/" ] && [ -d "$dir" ]; then
            install_module "$dir"
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
    
    # Normal interactive mode
    check_and_install_tools
    handle_config_directory
    show_menu
}

# Run the main function
main "$@" 