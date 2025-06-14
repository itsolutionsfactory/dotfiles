#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
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
        print_status "kubectl installed successfully!"
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
    sudo mv kubelogin /usr/local/bin/
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    # Verify installation
    if command -v kubelogin &> /dev/null; then
        print_status "kubelogin installed successfully!"
        kubelogin version
    else
        print_error "Failed to install kubelogin"
        exit 1
    fi
}

# Function to backup existing config
backup_config() {
    if [ -f ~/.kube/config ]; then
        local BACKUP_DIR=~/dotfiles/backup
        local BACKUP_FILE="$BACKUP_DIR/kube_config_$(date +%Y%m%d_%H%M%S)"
        
        print_status "Backing up existing kubectl config..."
        mkdir -p "$BACKUP_DIR"
        cp ~/.kube/config "$BACKUP_FILE"
        print_status "Backup created at $BACKUP_FILE"
    fi
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_warning "kubectl is not installed."
    install_kubectl
fi

# Check if kubelogin is installed
if ! command -v kubelogin &> /dev/null; then
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

# Create symlinks using stow
print_status "Creating symlinks..."
stow -t ~ .

print_status "Kubectl configuration installed successfully!"
print_status "Please restart your shell or run 'source ~/.zshrc' to apply changes." 