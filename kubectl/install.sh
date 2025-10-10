#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="kubectl"

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

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        OS=$(uname -s)
    fi
    echo "$OS"
}

# Function to detect architecture
detect_arch() {
    local arch
    arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        armv7l)
            echo "arm"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Function to install kubectl
install_kubectl() {
    local OS=$(detect_os)
    print_status "Installing kubectl for $OS..."
    
    # Create temporary directory
    local TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download latest stable kubectl
    print_status "Downloading latest stable kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Make it executable
    chmod +x kubectl
    
    # Move to system directory
    print_status "Installing kubectl to system..."
    sudo mv kubectl /usr/local/bin/
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    # Verify installation
    if command -v kubectl &> /dev/null; then
        print_success "kubectl installed successfully!"
        kubectl version --client
    else
        print_error "Failed to install kubectl"
        exit 1
    fi
}

# Function to install kubelogin
install_kubelogin() {
    local OS=$(detect_os)
    local ARCH=$(detect_arch)
    print_status "Installing kubelogin for $OS..."
    
    # Create temporary directory
    local TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get latest version
    local LATEST_VERSION=$(curl -s https://api.github.com/repos/int128/kubelogin/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Download kubelogin
    print_status "Downloading kubelogin version $LATEST_VERSION..."
    curl -LO "https://github.com/int128/kubelogin/releases/download/${LATEST_VERSION}/kubelogin_linux_${ARCH}.zip"
    
    # Unzip and install
    print_status "Installing kubelogin..."
    unzip "kubelogin_linux_${ARCH}.zip"
    chmod +x kubelogin
    
    # Create krew bin directory for int128
    print_status "Creating krew bin directory for int128..."
    mkdir -p "$HOME/.krew/bin/int128"
    
    # Move kubelogin to krew bin directory
    mv kubelogin "$HOME/.krew/bin/int128/"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    # Verify installation
    if [ -f "$HOME/.krew/bin/int128/kubelogin" ]; then
        print_success "kubelogin installed successfully!"
        "$HOME/.krew/bin/int128/kubelogin" version
    else
        print_error "Failed to install kubelogin"
        exit 1
    fi
}

# Function to backup existing config
backup_config() {
    if [ -f ~/.kube/config ]; then
        local BACKUP_DIR="$SCRIPT_DIR/../backup/modules/$MODULE_NAME"
        local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        local BACKUP_FILE="$BACKUP_DIR/$TIMESTAMP"
        
        print_status "Backing up existing kubectl config..."
        mkdir -p "$BACKUP_DIR"
        cp ~/.kube/config "$BACKUP_FILE"
        print_success "Backup created at $BACKUP_FILE"
    fi
}

# Print module header
print_header "Installing $MODULE_NAME configuration"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_warning "kubectl is not installed."
    install_kubectl
fi

# Check if kubelogin is installed
if [ ! -f "$HOME/.krew/bin/int128/kubelogin" ]; then
    print_warning "kubelogin is not installed."
    install_kubelogin
fi

# Create necessary directories
print_status "Creating kubectl configuration directories..."
mkdir -p ~/.kube/plugins
mkdir -p ~/.kube

# Backup existing config if it exists
backup_config

# Install kubectl completion for ZSH
print_status "Installing kubectl completion for ZSH..."
mkdir -p ~/.config/kubectl
kubectl completion zsh > ~/.config/kubectl/completion.zsh

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME/.config" .config; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

# Also stow the .kube directory
if ! stow -t "$HOME" .; then
    print_error "Failed to install $MODULE_NAME .kube configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Add krew bin to your PATH if not already done:"
print_warning "   echo 'export PATH=\"\$PATH:\$HOME/.krew/bin\"' >> ~/.zshrc"
print_warning "2. Restart your shell or run 'source ~/.zshrc' to apply changes"
print_warning "3. Test kubelogin: $HOME/.krew/bin/int128/kubelogin version" 