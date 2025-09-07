#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="kubectl"
CONFIG_DIR="$HOME/.config/$MODULE_NAME"

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

# Test functions
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

test_file_exists() {
    local file="$1"
    print_status "Testing file existence: $file"
    
    if [ -f "$file" ]; then
        print_success "File exists: $file"
        return 0
    else
        print_error "File does not exist: $file"
        return 1
    fi
}

test_dependency() {
    local dep="$1"
    print_status "Testing dependency: $dep"
    
    if command -v "$dep" >/dev/null 2>&1; then
        print_success "Dependency found: $dep"
        return 0
    else
        print_error "Dependency not found: $dep"
        return 1
    fi
}

# Main test execution
print_header "Testing $MODULE_NAME configuration"

# Test dependencies
test_dependency "kubectl" || exit 1
test_dependency "kubelogin" || exit 1

# Test kubectl version
print_status "Testing kubectl version"
if kubectl version --client >/dev/null 2>&1; then
    print_success "kubectl version check passed"
else
    print_error "kubectl version check failed"
    exit 1
fi

# Test kubelogin version
print_status "Testing kubelogin version"
if kubelogin version >/dev/null 2>&1; then
    print_success "kubelogin version check passed"
else
    print_error "kubelogin version check failed"
    exit 1
fi

# Test kubectl configuration
test_file_exists "$HOME/.kube/config" || exit 1

# Test kubectl config validity
print_status "Testing kubectl config validity"
if kubectl config view >/dev/null 2>&1; then
    print_success "kubectl config is valid"
else
    print_error "kubectl config is invalid"
    exit 1
fi

# Test kubectl contexts
print_status "Testing kubectl contexts"
if kubectl config get-contexts >/dev/null 2>&1; then
    print_success "kubectl contexts accessible"
else
    print_error "kubectl contexts not accessible"
    exit 1
fi

# Test kubectl completion
test_file_exists "$HOME/.config/kubectl/completion.zsh" || exit 1

# Test kubectl plugins directory
print_status "Testing kubectl plugins directory"
if [ -d "$HOME/.kube/plugins" ]; then
    print_success "kubectl plugins directory exists"
else
    print_error "kubectl plugins directory does not exist"
    exit 1
fi

# Test stow links
test_stow_link "$CONFIG_DIR" "$SCRIPT_DIR/.config/$MODULE_NAME" || exit 1
test_stow_link "$HOME/.kube" "$SCRIPT_DIR/.kube" || exit 1

# Test OIDC configuration
print_status "Testing OIDC configuration"
if kubectl config view | grep -q 'oidc-issuer-url'; then
    print_success "OIDC configuration found"
else
    print_warning "OIDC configuration not found - this might be expected"
fi

# Test cluster access
print_status "Testing cluster access..."
if kubectl cluster-info >/dev/null 2>&1; then
    print_success "Successfully connected to cluster"
else
    print_warning "Could not connect to cluster. This might be expected if you're not currently authenticated."
fi

# Test namespace access
print_status "Testing namespace access..."
if kubectl get ns >/dev/null 2>&1; then
    print_success "Successfully accessed namespaces"
else
    print_warning "Could not access namespaces. This might be expected if you're not currently authenticated."
fi

# Test kubectl aliases (if zsh is available)
if command -v zsh >/dev/null 2>&1; then
    print_status "Testing kubectl aliases..."
    # Test if the config file is being sourced by checking if aliases are available
    if zsh -c "source ~/.config/kubectl/config.zsh 2>/dev/null && alias | grep -q 'k='"; then
        print_success "kubectl aliases are properly configured"
    else
        print_warning "kubectl aliases might not be loaded. Make sure to source ~/.zshrc"
    fi
else
    print_warning "zsh not available - skipping alias test"
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Open a new terminal and test kubectl aliases (k, kg, kd, etc.)"
print_warning "2. Verify kubectl completion works with TAB key"
print_warning "3. Test cluster access and authentication"
print_warning "4. If you see warnings about cluster access, make sure you're properly authenticated with your OIDC provider" 