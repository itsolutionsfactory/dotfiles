#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="docker"

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

# Check if we have sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges. You may be prompted for your password."
fi

# Function to check if Docker is properly installed from official repository
check_docker_properly_installed() {
    # Check if docker-ce package is installed (official Docker package)
    if dpkg -l | grep -q "^ii  docker-ce "; then
        return 0
    fi
    return 1
}

# Function to check if Docker is already installed
check_docker_installed() {
    if command -v docker >/dev/null 2>&1; then
        local docker_version
        docker_version=$(docker --version 2>/dev/null || echo "unknown")
        print_warning "Docker appears to be already installed: $docker_version"
        
        # Check if it's properly installed from official repository
        if check_docker_properly_installed; then
            print_success "Docker is properly installed from official repository"
            print_warning "This script will upgrade Docker if a newer version is available."
        else
            print_warning "Docker is installed but not from official repository"
            print_warning "Old versions will be removed and Docker will be reinstalled from official repository."
        fi
        return 0
    fi
    return 1
}

# Function to uninstall old versions
uninstall_old_versions() {
    # Only remove old versions if Docker is NOT properly installed
    if check_docker_properly_installed; then
        print_status "Docker is properly installed from official repository, skipping old version removal"
        return 0
    fi
    
    print_status "Docker is not properly installed, removing old Docker versions..."
    
    # Remove old versions of docker, docker.io, docker-doc, docker-compose, etc.
    if sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null; then
        print_success "Old Docker versions removed"
    else
        print_status "No old Docker versions found to remove"
    fi
}

# Function to set up Docker's apt repository
setup_docker_repository() {
    print_status "Setting up Docker's apt repository..."
    
    # Install prerequisites
    print_status "Installing prerequisites..."
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    print_status "Adding Docker's official GPG key..."
    if [ ! -d /etc/apt/keyrings ]; then
        sudo install -m 0755 -d /etc/apt/keyrings
    fi
    
    # Remove old key if exists
    if [ -f /etc/apt/keyrings/docker.gpg ]; then
        sudo rm -f /etc/apt/keyrings/docker.gpg
    fi
    
    # Download and add GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    print_status "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    print_success "Docker repository configured"
}

# Function to install Docker Engine
install_docker_engine() {
    print_status "Installing Docker Engine, CLI, containerd, and Docker Compose..."
    
    # Update apt package index
    sudo apt-get update
    
    # Install Docker Engine, CLI, containerd, and Docker Compose
    if sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin; then
        print_success "Docker Engine installed successfully"
    else
        print_error "Failed to install Docker Engine"
        exit 1
    fi
}

# Function to verify Docker installation
verify_docker_installation() {
    print_status "Verifying Docker installation..."
    
    # Check if docker command is available
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker command not found"
        return 1
    fi
    
    # Check Docker version
    local docker_version
    docker_version=$(docker --version 2>/dev/null || echo "unknown")
    print_success "Docker version: $docker_version"
    
    # Check Docker Compose version
    if command -v docker compose >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker compose version 2>/dev/null || echo "unknown")
        print_success "Docker Compose version: $compose_version"
    fi
    
    # Check if Docker daemon is running
    if sudo systemctl is-active --quiet docker; then
        print_success "Docker daemon is running"
    else
        print_warning "Docker daemon is not running, attempting to start..."
        if sudo systemctl start docker; then
            print_success "Docker daemon started"
        else
            print_error "Failed to start Docker daemon"
            return 1
        fi
    fi
    
    # Enable Docker to start on boot
    if sudo systemctl enable docker >/dev/null 2>&1; then
        print_success "Docker enabled to start on boot"
    fi
    
    # Test Docker with hello-world
    print_status "Testing Docker installation with hello-world image..."
    if sudo docker run --rm hello-world >/dev/null 2>&1; then
        print_success "Docker installation verified successfully"
    else
        print_warning "Docker hello-world test failed, but Docker may still be functional"
    fi
}

# Function to check if user should be added to docker group
check_docker_group() {
    print_status "Checking Docker group configuration..."
    
    if groups | grep -q docker; then
        print_success "Current user is already in the docker group"
    else
        print_warning "Current user is not in the docker group"
        print_warning "To run Docker commands without sudo, add your user to the docker group:"
        print_warning "  sudo usermod -aG docker $USER"
        print_warning "Then log out and log back in for the changes to take effect."
    fi
}

# Function to backup existing Docker configuration
backup_docker_config() {
    print_status "Checking for existing Docker configuration..."
    
    # Ensure backup directory exists
    if [ ! -d "$BACKUP_DIR/modules/$MODULE_NAME" ]; then
        mkdir -p "$BACKUP_DIR/modules/$MODULE_NAME"
    fi
    
    # Ensure .docker directory exists (but don't make it a symlink)
    if [ ! -d "$HOME/.docker" ]; then
        print_status "Creating .docker directory..."
        mkdir -p "$HOME/.docker"
    elif [ -L "$HOME/.docker" ]; then
        print_warning ".docker is a symlink, removing it to create directory..."
        rm "$HOME/.docker"
        mkdir -p "$HOME/.docker"
    fi
    
    # Backup existing config.json if it exists
    if [ -f "$HOME/.docker/config.json" ]; then
        if [ -L "$HOME/.docker/config.json" ]; then
            print_status "Removing existing config.json symlink..."
            rm "$HOME/.docker/config.json"
        else
            print_status "Backing up existing config.json file..."
            TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
            BACKUP_PATH="$BACKUP_DIR/modules/$MODULE_NAME/$TIMESTAMP"
            mkdir -p "$BACKUP_PATH"
            cp "$HOME/.docker/config.json" "$BACKUP_PATH/config.json"
            print_success "Backup created at $BACKUP_PATH/config.json"
            
            # Remove existing file to allow stow to create symlink
            rm -f "$HOME/.docker/config.json"
        fi
    fi
}

# Function to install Docker configuration using stow
install_docker_config() {
    print_status "Installing Docker configuration..."
    
    # Ensure .docker directory exists
    mkdir -p "$HOME/.docker"
    
    # Change to script directory for stow
    cd "$SCRIPT_DIR" || exit 1
    
    # Use stow to create symlink for config.json only
    # This will create $HOME/.docker/config.json -> docker/.docker/config.json
    if ! stow -t "$HOME/.docker" -d "$SCRIPT_DIR" .docker; then
        print_error "Failed to install Docker configuration"
        exit 1
    fi
    
    print_success "Docker configuration installed successfully"
    print_warning "Please update the JFrog Artifactory token in $HOME/.docker/config.json"
    print_warning "Replace 'token from jfrog' with your actual token"
}

# Main installation process
print_status "Starting Docker installation..."

# Check if Docker is already installed
if check_docker_installed; then
    print_status "Docker is already installed, proceeding with upgrade..."
fi

# Uninstall old versions
uninstall_old_versions

# Set up Docker repository
setup_docker_repository

# Install Docker Engine
install_docker_engine

# Verify installation
verify_docker_installation

# Check docker group
check_docker_group

# Backup and install Docker configuration
backup_docker_config
install_docker_config

print_success "$MODULE_NAME installation completed successfully!"

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Add your user to the docker group (if not already done):"
print_warning "   sudo usermod -aG docker $USER"
print_warning "   Then log out and log back in"
print_warning "2. Update JFrog Artifactory token in Docker config:"
print_warning "   Edit $HOME/.docker/config.json"
print_warning "   Replace 'token from jfrog' with your actual token"
print_warning "3. Test Docker without sudo:"
print_warning "   docker run hello-world"
print_warning "4. Verify Docker Compose:"
print_warning "   docker compose version"
print_warning "5. For post-installation steps, see:"
print_warning "   https://docs.docker.com/engine/install/linux-postinstall/"

