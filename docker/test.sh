#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
PINK="\033[38;2;245;194;231m"     # Pink
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

# Test functions
test_command_available() {
    local command="$1"
    print_status "Testing command availability: $command"
    
    if command -v "$command" >/dev/null 2>&1; then
        print_success "$command is available"
        return 0
    else
        print_error "$command is not available"
        return 1
    fi
}

test_package_installed() {
    local package="$1"
    print_status "Testing package installation: $package"
    
    if dpkg -l | grep -q "^ii  $package "; then
        print_success "$package is installed"
        return 0
    else
        print_error "$package is not installed"
        return 1
    fi
}

test_docker_version() {
    print_status "Testing Docker version..."
    
    if command -v docker >/dev/null 2>&1; then
        local docker_version
        docker_version=$(docker --version 2>/dev/null || echo "unknown")
        print_success "Docker version: $docker_version"
        return 0
    else
        print_error "Docker command not found"
        return 1
    fi
}

test_docker_compose_version() {
    print_status "Testing Docker Compose version..."
    
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker compose version 2>/dev/null || echo "unknown")
        print_success "Docker Compose version: $compose_version"
        return 0
    else
        print_error "Docker Compose not available"
        return 1
    fi
}

test_docker_daemon() {
    print_status "Testing Docker daemon status..."
    
    if sudo systemctl is-active --quiet docker; then
        print_success "Docker daemon is running"
        return 0
    else
        print_error "Docker daemon is not running"
        return 1
    fi
}

test_docker_repository() {
    print_status "Testing Docker repository configuration..."
    
    if [ -f /etc/apt/sources.list.d/docker.list ]; then
        print_success "Docker repository is configured"
        return 0
    else
        print_error "Docker repository is not configured"
        return 1
    fi
}

test_docker_gpg_key() {
    print_status "Testing Docker GPG key..."
    
    if [ -f /etc/apt/keyrings/docker.gpg ]; then
        print_success "Docker GPG key is present"
        return 0
    else
        print_error "Docker GPG key is not present"
        return 1
    fi
}

test_docker_hello_world() {
    print_status "Testing Docker with hello-world image..."
    
    if sudo docker run --rm hello-world >/dev/null 2>&1; then
        print_success "Docker hello-world test passed"
        return 0
    else
        print_warning "Docker hello-world test failed (this may be expected if image needs to be pulled)"
        return 1
    fi
}

test_docker_group() {
    print_status "Testing Docker group membership..."
    
    if groups | grep -q docker; then
        print_success "Current user is in the docker group"
        return 0
    else
        print_warning "Current user is not in the docker group"
        print_warning "Run: sudo usermod -aG docker $USER"
        return 1
    fi
}

test_stow_link() {
    local target="$1"
    local source="$2"
    
    print_status "Testing stow link: $target"
    
    # Check if the target is a symbolic link
    if [ ! -L "$target" ]; then
        print_error "$target is not a symbolic link"
        return 1
    fi
    
    # Get the absolute path of the source
    local abs_source="$(cd "$(dirname "$source")" && pwd)/$(basename "$source")"
    
    # Get the absolute path of the target's link
    local abs_target="$(readlink -f "$target")"
    
    # Compare the paths
    if [ "$abs_target" = "$abs_source" ]; then
        print_success "$target is properly linked by stow"
        return 0
    else
        print_error "$target is not properly linked by stow"
        print_error "Expected: $abs_source"
        print_error "Got: $abs_target"
        return 1
    fi
}

test_docker_config() {
    print_status "Testing Docker configuration..."
    
    # Test if .docker directory exists
    if [ ! -d "$HOME/.docker" ]; then
        print_error ".docker directory does not exist"
        return 1
    fi
    
    # Test if .docker is NOT a symlink (it should be a regular directory)
    if [ -L "$HOME/.docker" ]; then
        print_error ".docker should be a directory, not a symlink"
        return 1
    else
        print_success ".docker is a directory (not a symlink)"
    fi
    
    # Test if config.json exists
    if [ ! -f "$HOME/.docker/config.json" ]; then
        print_error "Docker config.json does not exist"
        return 1
    fi
    
    print_success "Docker config.json exists"
    
    # Test if config.json is a symlink (stow link)
    if [ -L "$HOME/.docker/config.json" ]; then
        print_success "config.json is a symbolic link (stow link)"
        test_stow_link "$HOME/.docker/config.json" "$SCRIPT_DIR/.docker/config.json"
    else
        print_warning "config.json exists but is not a symlink"
    fi
    
    # Check if config.json is readable
    if [ -r "$HOME/.docker/config.json" ]; then
        print_success "Docker config.json is readable"
    else
        print_error "Docker config.json is not readable"
        return 1
    fi
    
    # Check if config contains JFrog configuration
    if grep -q "jfrog-artifactory.steelhome.internal:443" "$HOME/.docker/config.json" 2>/dev/null; then
        print_success "Docker config.json contains JFrog Artifactory configuration"
    else
        print_warning "Docker config.json does not contain JFrog Artifactory configuration"
    fi
    
    return 0
}

test_docker_info() {
    print_status "Testing Docker system information..."
    
    if sudo docker info >/dev/null 2>&1; then
        print_success "Docker system information accessible"
        return 0
    else
        print_error "Cannot access Docker system information"
        return 1
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

# Test command availability
test_command_available "docker"

# Test package installations
test_package_installed "docker-ce"
test_package_installed "docker-ce-cli"
test_package_installed "containerd.io"
test_package_installed "docker-buildx-plugin"
test_package_installed "docker-compose-plugin"

# Test Docker versions
test_docker_version
test_docker_compose_version

# Test Docker daemon
test_docker_daemon

# Test repository configuration
test_docker_repository
test_docker_gpg_key

# Test Docker functionality
test_docker_info
test_docker_hello_world

# Test Docker group
test_docker_group

# Test Docker configuration
test_docker_config

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Update JFrog Artifactory token in Docker config:"
print_warning "   Edit $HOME/.docker/config.json"
print_warning "   Replace 'token from jfrog' with your actual token"
print_warning "2. Test Docker without sudo (after adding user to docker group):"
print_warning "   docker run hello-world"
print_warning "3. Test Docker Compose:"
print_warning "   docker compose version"
print_warning "4. Test Docker build:"
print_warning "   docker build --help"
print_warning "5. Check Docker system information:"
print_warning "   docker info"
print_warning "6. List Docker images:"
print_warning "   docker images"

