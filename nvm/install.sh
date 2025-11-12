#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="nvm"

# NVM version to install (latest stable)
NVM_VERSION="v0.40.3"

# Node.js version to install (LTS)
NODE_VERSION="lts/*"

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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Determine NVM directory
if [ -z "${XDG_CONFIG_HOME-}" ]; then
    NVM_DIR="$HOME/.nvm"
else
    NVM_DIR="$XDG_CONFIG_HOME/nvm"
fi

# Function to check if NVM is already installed
check_nvm_installed() {
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        return 0
    fi
    return 1
}

# Function to check if Node.js is installed via NVM
check_node_installed() {
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
        if command -v node >/dev/null 2>&1 && [ -n "$(nvm current 2>/dev/null)" ] && [ "$(nvm current)" != "none" ]; then
            return 0
        fi
    fi
    return 1
}

# Function to install NVM
install_nvm() {
    print_status "Installing NVM..."
    
    # Check if curl or wget is available
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        print_error "curl or wget is required to install NVM"
        print_status "Installing curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi
    
    # Install NVM using the official install script
    if command -v curl >/dev/null 2>&1; then
        print_status "Downloading and installing NVM using curl..."
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    elif command -v wget >/dev/null 2>&1; then
        print_status "Downloading and installing NVM using wget..."
        wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    else
        print_error "Neither curl nor wget is available"
        exit 1
    fi
    
    # Verify installation
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        print_success "NVM installed successfully"
    else
        print_error "NVM installation failed"
        exit 1
    fi
}

# Function to source NVM in shell configuration
setup_shell_config() {
    print_status "Setting up shell configuration for NVM..."
    
    # Determine which shell config file to use
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        else
            SHELL_CONFIG="$HOME/.bashrc"
        fi
    else
        SHELL_CONFIG="$HOME/.profile"
    fi
    
    # NVM configuration snippet
    NVM_SNIPPET="export NVM_DIR=\"\$([ -z \"\${XDG_CONFIG_HOME-}\" ] && printf %s \"\${HOME}/.nvm\" || printf %s \"\${XDG_CONFIG_HOME}/nvm\")\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\" # This loads nvm
[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\" # This loads nvm bash_completion"
    
    # Check if NVM is already configured
    if [ -f "$SHELL_CONFIG" ] && grep -q "NVM_DIR" "$SHELL_CONFIG" && grep -q "nvm.sh" "$SHELL_CONFIG"; then
        print_status "NVM is already configured in $SHELL_CONFIG"
    else
        print_status "Adding NVM configuration to $SHELL_CONFIG..."
        
        # Backup existing shell config
        if [ -f "$SHELL_CONFIG" ]; then
            TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
            BACKUP_PATH="$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP"
            mkdir -p "$BACKUP_PATH"
            cp "$SHELL_CONFIG" "$BACKUP_PATH/$(basename "$SHELL_CONFIG")"
            print_success "Backup created at $BACKUP_PATH/$(basename "$SHELL_CONFIG")"
        fi
        
        # Append NVM configuration
        echo "" >> "$SHELL_CONFIG"
        echo "# NVM configuration" >> "$SHELL_CONFIG"
        echo "$NVM_SNIPPET" >> "$SHELL_CONFIG"
        print_success "NVM configuration added to $SHELL_CONFIG"
    fi
}

# Function to install Node.js
install_node() {
    print_status "Installing Node.js using NVM..."
    
    # Source NVM
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    else
        print_error "NVM is not available"
        exit 1
    fi
    
    # Install Node.js LTS
    print_status "Installing Node.js $NODE_VERSION..."
    if nvm install "$NODE_VERSION"; then
        print_success "Node.js installed successfully"
        
        # Set as default
        print_status "Setting Node.js as default..."
        nvm alias default "$NODE_VERSION"
        nvm use default
        
        # Display versions
        local node_version
        local npm_version
        node_version=$(node --version 2>/dev/null || echo "unknown")
        npm_version=$(npm --version 2>/dev/null || echo "unknown")
        print_success "Node.js version: $node_version"
        print_success "npm version: $npm_version"
    else
        print_error "Failed to install Node.js"
        exit 1
    fi
}

# Function to backup and install .npmrc configuration
install_npmrc() {
    print_status "Installing .npmrc configuration..."
    
    # Ensure backup directory exists
    if [ ! -d "$BACKUP_DIR/modules/$MODULE_NAME" ]; then
        mkdir -p "$BACKUP_DIR/modules/$MODULE_NAME"
    fi
    
    # Backup existing .npmrc if it exists
    if [ -f "$HOME/.npmrc" ]; then
        if [ -L "$HOME/.npmrc" ]; then
            print_status "Removing existing .npmrc symlink..."
            rm "$HOME/.npmrc"
        else
            print_status "Backing up existing .npmrc file..."
            TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
            BACKUP_PATH="$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP"
            mkdir -p "$BACKUP_PATH"
            cp "$HOME/.npmrc" "$BACKUP_PATH/.npmrc"
            print_success "Backup created at $BACKUP_PATH/.npmrc"
            
            # Remove existing file to allow stow to create symlink
            rm -f "$HOME/.npmrc"
        fi
    fi
    
    # Change to script directory for stow
    cd "$SCRIPT_DIR" || exit 1
    
    # Use stow to create symlink for .npmrc
    # This will create $HOME/.npmrc -> nvm/.npmrc
    if ! stow -t "$HOME" .; then
        print_error "Failed to install .npmrc configuration"
        exit 1
    fi
    
    print_success ".npmrc configuration installed successfully"
    print_warning "Please update the following placeholders in $HOME/.npmrc:"
    print_warning "  - Replace 'your.email@itsf.io' with your actual ITSF email"
    print_warning "  - Replace 'YOUR_BASE64_ENCODED_CREDENTIALS' with your base64-encoded credentials"
    print_warning "  - Replace '/home/YOUR_USERNAME/.certs/root-ca.crt' with your actual certificate path"
    print_warning "  - Replace 'YOUR_JWT_TOKEN' with your actual JWT token from JFrog Artifactory"
}

# Main installation process
print_status "Starting NVM installation..."

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR/modules/$MODULE_NAME"

# Check if NVM is already installed
if check_nvm_installed; then
    print_status "NVM is already installed"
else
    # Install NVM
    install_nvm
fi

# Setup shell configuration
setup_shell_config

# Source NVM for current session
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
else
    print_error "Failed to source NVM"
    exit 1
fi

# Check if Node.js is already installed
if check_node_installed; then
    print_status "Node.js is already installed via NVM"
    local current_version
    current_version=$(nvm current 2>/dev/null || echo "unknown")
    print_success "Current Node.js version: $current_version"
    
    # Check if we should update to latest LTS
    print_status "Checking for latest LTS version..."
    nvm install "$NODE_VERSION" --reinstall-packages-from=default
    nvm alias default "$NODE_VERSION"
    nvm use default
else
    # Install Node.js
    install_node
fi

# Install .npmrc configuration
install_npmrc

print_success "$MODULE_NAME installation completed successfully!"

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Reload your shell configuration:"
print_warning "   source ~/.zshrc  # or ~/.bashrc if using bash"
print_warning "2. Or simply open a new terminal window"
print_warning "3. Verify NVM installation:"
print_warning "   nvm --version"
print_warning "4. Verify Node.js installation:"
print_warning "   node --version"
print_warning "   npm --version"
print_warning "5. To install additional Node.js versions:"
print_warning "   nvm install <version>"
print_warning "   nvm use <version>"
print_warning "6. To list available Node.js versions:"
print_warning "   nvm ls-remote"
print_warning "7. Update .npmrc configuration with your credentials:"
print_warning "   Edit $HOME/.npmrc and replace all placeholders"

