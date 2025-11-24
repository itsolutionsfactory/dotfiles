#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="powershell"

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
print_header "Installing $MODULE_NAME"

# Check if PowerShell is already installed
check_powershell_installed() {
    if command -v pwsh >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Function to check if snap is available
check_snap_available() {
    if command -v snap >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Function to install PowerShell using snap
install_powershell() {
    print_status "Installing PowerShell using snap..."
    
    # Check if snap is available
    if ! check_snap_available; then
        print_error "snap is not available. Please install snapd first."
        print_status "Install snapd with: sudo apt-get install -y snapd"
        exit 1
    fi
    
    # Install PowerShell using snap
    sudo snap install powershell --classic
    
    print_success "PowerShell installed successfully"
}

# Function to check if Exchange Online module is installed
check_exchange_online_installed() {
    if pwsh -Command "Get-Module -ListAvailable -Name ExchangeOnlineManagement" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Function to check if Microsoft Teams module is installed
check_teams_module_installed() {
    if pwsh -Command "Get-Module -ListAvailable -Name MicrosoftTeams" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Function to install Exchange Online PowerShell module
install_exchange_online_module() {
    print_status "Installing Exchange Online PowerShell module..."
    print_status "This may take a few minutes..."
    
    # Install the module
    if pwsh -Command "Install-Module ExchangeOnlineManagement" 2>&1; then
        print_success "Exchange Online PowerShell module installed successfully"
        
        # Import the module
        print_status "Importing Exchange Online PowerShell module..."
        if pwsh -Command "Import-Module ExchangeOnlineManagement" 2>&1; then
            print_success "Exchange Online PowerShell module imported successfully"
            
            # Verify installation
            if check_exchange_online_installed; then
                local module_version
                module_version=$(pwsh -Command "(Get-Module -ListAvailable -Name ExchangeOnlineManagement | Select-Object -First 1).Version" 2>/dev/null || echo "unknown")
                print_status "Module version: $module_version"
            fi
            return 0
        else
            print_warning "Module installed but failed to import (this is usually fine, module will be available in new sessions)"
            return 0
        fi
    else
        print_error "Failed to install Exchange Online PowerShell module"
        print_warning "You can try installing it manually:"
        print_warning "  pwsh -Command 'Install-Module ExchangeOnlineManagement'"
        return 1
    fi
}

# Function to install Microsoft Teams PowerShell module
install_teams_module() {
    print_status "Installing Microsoft Teams PowerShell module..."
    print_status "This may take a few minutes..."
    
    # Install the module
    if pwsh -Command "Install-Module -Name MicrosoftTeams -Force -AllowClobber" 2>&1; then
        print_success "Microsoft Teams PowerShell module installed successfully"
        
        # Import the module
        print_status "Importing Microsoft Teams PowerShell module..."
        if pwsh -Command "Import-Module MicrosoftTeams" 2>&1; then
            print_success "Microsoft Teams PowerShell module imported successfully"
            
            # Verify installation
            if check_teams_module_installed; then
                local module_version
                module_version=$(pwsh -Command "(Get-Module -ListAvailable -Name MicrosoftTeams | Select-Object -First 1).Version" 2>/dev/null || echo "unknown")
                print_status "Module version: $module_version"
            fi
            return 0
        else
            print_warning "Module installed but failed to import (this is usually fine, module will be available in new sessions)"
            return 0
        fi
    else
        print_error "Failed to install Microsoft Teams PowerShell module"
        print_warning "You can try installing it manually:"
        print_warning "  pwsh -Command 'Install-Module -Name MicrosoftTeams -Force -AllowClobber'"
        return 1
    fi
}

# Main installation process
main() {
    # Check if PowerShell is already installed
    if check_powershell_installed; then
        print_warning "PowerShell is already installed"
        local version
        version=$(pwsh --version 2>/dev/null || echo "unknown")
        print_status "Installed version: $version"
        read -p "$(echo -e "${SUBTEXT}Do you want to reinstall? [y/N]: ${BASE}")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
    fi
    
    # Install PowerShell using snap
    install_powershell
    
    # Verify installation
    if check_powershell_installed; then
        local version
        version=$(pwsh --version 2>/dev/null || echo "unknown")
        print_success "PowerShell installation completed successfully!"
        print_status "Version: $version"
        print_status "You can start PowerShell by running: ${GREEN}pwsh${BASE}"
        
        # Ask if user wants to install Exchange Online PowerShell module
        echo
        print_header "Exchange Online PowerShell Module"
        if check_exchange_online_installed; then
            print_warning "Exchange Online PowerShell module is already installed"
            read -p "$(echo -e "${SUBTEXT}Do you want to reinstall it? [y/N]: ${BASE}")" -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_exchange_online_module
            fi
        else
            read -p "$(echo -e "${SUBTEXT}Do you want to install Exchange Online PowerShell module? [Y/n]: ${BASE}")" -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                install_exchange_online_module
            else
                print_status "Skipping Exchange Online PowerShell module installation"
                print_status "You can install it later by running: ${GREEN}pwsh -Command 'Install-Module ExchangeOnlineManagement'${BASE}"
            fi
        fi
        
        # Ask if user wants to install Microsoft Teams PowerShell module
        echo
        print_header "Microsoft Teams PowerShell Module"
        if check_teams_module_installed; then
            print_warning "Microsoft Teams PowerShell module is already installed"
            read -p "$(echo -e "${SUBTEXT}Do you want to reinstall it? [y/N]: ${BASE}")" -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_teams_module
            fi
        else
            read -p "$(echo -e "${SUBTEXT}Do you want to install Microsoft Teams PowerShell module? [Y/n]: ${BASE}")" -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                install_teams_module
            else
                print_status "Skipping Microsoft Teams PowerShell module installation"
                print_status "You can install it later by running: ${GREEN}pwsh -Command 'Install-Module -Name MicrosoftTeams -Force -AllowClobber'${BASE}"
            fi
        fi
    else
        print_error "PowerShell installation failed"
        exit 1
    fi
}

# Run main function
main

