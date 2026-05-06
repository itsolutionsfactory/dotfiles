#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="nvm"

# Determine NVM directory
if [ -z "${XDG_CONFIG_HOME-}" ]; then
    NVM_DIR="$HOME/.nvm"
else
    NVM_DIR="$XDG_CONFIG_HOME/nvm"
fi

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

# Source NVM if available
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
fi

# Test functions
test_nvm_directory() {
    print_status "Testing NVM directory..."
    
    if [ -d "$NVM_DIR" ]; then
        print_success "NVM directory exists: $NVM_DIR"
        return 0
    else
        print_error "NVM directory does not exist: $NVM_DIR"
        return 1
    fi
}

test_nvm_script() {
    print_status "Testing NVM script..."
    
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        print_success "NVM script exists: $NVM_DIR/nvm.sh"
        return 0
    else
        print_error "NVM script does not exist: $NVM_DIR/nvm.sh"
        return 1
    fi
}

test_nvm_command() {
    print_status "Testing NVM command..."
    
    if command -v nvm >/dev/null 2>&1 || [ -s "$NVM_DIR/nvm.sh" ]; then
        # Source NVM if not already sourced
        if ! command -v nvm >/dev/null 2>&1; then
            # shellcheck source=/dev/null
            . "$NVM_DIR/nvm.sh"
        fi
        
        if command -v nvm >/dev/null 2>&1 || type nvm >/dev/null 2>&1; then
            local nvm_version
            nvm_version=$(nvm --version 2>/dev/null || echo "unknown")
            print_success "NVM is available (version: $nvm_version)"
            return 0
        else
            print_error "NVM command is not available"
            return 1
        fi
    else
        print_error "NVM is not installed"
        return 1
    fi
}

test_shell_config() {
    print_status "Testing shell configuration..."
    
    # Determine which shell config file to check
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
    
    if [ -f "$SHELL_CONFIG" ]; then
        print_success "Shell configuration file exists: $SHELL_CONFIG"
        
        if grep -q "NVM_DIR" "$SHELL_CONFIG" && grep -q "nvm.sh" "$SHELL_CONFIG"; then
            print_success "NVM is configured in $SHELL_CONFIG"
            return 0
        else
            print_warning "NVM is not configured in $SHELL_CONFIG"
            print_warning "You may need to reload your shell configuration"
            return 1
        fi
    else
        print_warning "Shell configuration file does not exist: $SHELL_CONFIG"
        return 1
    fi
}

test_node_installed() {
    print_status "Testing Node.js installation..."
    
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null || echo "unknown")
        print_success "Node.js is installed: $node_version"
        
        # Check if it's managed by NVM
        if [ -n "$(nvm current 2>/dev/null)" ] && [ "$(nvm current)" != "none" ]; then
            local nvm_current
            nvm_current=$(nvm current 2>/dev/null || echo "none")
            print_success "Node.js is managed by NVM: $nvm_current"
            return 0
        else
            print_warning "Node.js is installed but may not be managed by NVM"
            return 1
        fi
    else
        print_error "Node.js is not installed"
        return 1
    fi
}

test_npm_installed() {
    print_status "Testing npm installation..."
    
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    if command -v npm >/dev/null 2>&1; then
        local npm_version
        npm_version=$(npm --version 2>/dev/null || echo "unknown")
        print_success "npm is installed: $npm_version"
        return 0
    else
        print_error "npm is not installed"
        return 1
    fi
}

test_nvm_default_version() {
    print_status "Testing NVM default version..."
    
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    local default_version
    default_version=$(nvm alias default 2>/dev/null | awk '{print $3}' || echo "none")
    
    if [ -n "$default_version" ] && [ "$default_version" != "none" ]; then
        print_success "NVM default version is set: $default_version"
        return 0
    else
        print_warning "NVM default version is not set"
        return 1
    fi
}

test_nvm_list_versions() {
    print_status "Testing NVM version listing..."
    
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    if nvm ls >/dev/null 2>&1; then
        print_success "NVM can list installed versions"
        return 0
    else
        print_warning "NVM cannot list installed versions"
        return 1
    fi
}

test_node_functionality() {
    print_status "Testing Node.js functionality..."
    
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    if command -v node >/dev/null 2>&1; then
        # Test simple Node.js command
        if node -e "console.log('Node.js is working')" >/dev/null 2>&1; then
            print_success "Node.js is functional"
            return 0
        else
            print_error "Node.js is not functional"
            return 1
        fi
    else
        print_error "Node.js command not found"
        return 1
    fi
}

test_npm_functionality() {
    print_status "Testing npm functionality..."
    
    # Source NVM if available
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    if command -v npm >/dev/null 2>&1; then
        # Test npm command
        if npm --version >/dev/null 2>&1; then
            print_success "npm is functional"
            return 0
        else
            print_error "npm is not functional"
            return 1
        fi
    else
        print_error "npm command not found"
        return 1
    fi
}

test_npmrc_file() {
    print_status "Testing .npmrc file..."
    
    if [ -f "$HOME/.npmrc" ]; then
        print_success ".npmrc file exists: $HOME/.npmrc"
        
        # Check if it's a symlink (stow link)
        if [ -L "$HOME/.npmrc" ]; then
            print_success ".npmrc is a symbolic link (stow link)"
            test_stow_link "$HOME/.npmrc" "$SCRIPT_DIR/.npmrc"
        else
            print_warning ".npmrc exists but is not a symlink"
        fi
        
        # Check if it contains required configuration
        if grep -q "registry=https://jfrog-artifactory.steelhome.internal" "$HOME/.npmrc" 2>/dev/null; then
            print_success ".npmrc contains JFrog Artifactory registry configuration"
        else
            print_warning ".npmrc does not contain JFrog Artifactory registry configuration"
        fi
        
        # Check for placeholders that need to be replaced
        if grep -q "YOUR_BASE64_ENCODED_CREDENTIALS\|YOUR_USERNAME\|YOUR_JWT_TOKEN\|your.email@itsf.io" "$HOME/.npmrc" 2>/dev/null; then
            print_warning ".npmrc contains placeholders that need to be replaced"
            print_warning "Please update the following in $HOME/.npmrc:"
            print_warning "  - Replace 'your.email@itsf.io' with your actual ITSF email"
            print_warning "  - Replace 'YOUR_BASE64_ENCODED_CREDENTIALS' with your base64-encoded credentials"
            print_warning "  - Replace '/home/YOUR_USERNAME/.certs/root-ca.crt' with your actual certificate path"
            print_warning "  - Replace 'YOUR_JWT_TOKEN' with your actual JWT token"
        else
            print_success ".npmrc appears to be configured (no placeholders found)"
        fi
        
        return 0
    else
        print_error ".npmrc file does not exist: $HOME/.npmrc"
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

# Main test execution
print_header "Testing $MODULE_NAME configuration"

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    # shellcheck source=../scripts/test-lib.sh
    . "$SCRIPT_DIR/../scripts/test-lib.sh"
    test_stow_link_portable "$HOME/.npmrc" "$SCRIPT_DIR/.npmrc"

    if grep -q "registry=https://jfrog-artifactory.steelhome.internal" "$HOME/.npmrc" 2>/dev/null; then
        print_success ".npmrc contains JFrog Artifactory registry configuration"
    else
        print_error ".npmrc does not contain JFrog Artifactory registry configuration"
        exit 1
    fi

    print_success "Portable $MODULE_NAME tests completed"
    exit 0
fi

# Test NVM installation
test_nvm_directory
test_nvm_script
test_nvm_command

# Test shell configuration
test_shell_config

# Test Node.js and npm
test_node_installed
test_npm_installed
test_nvm_default_version
test_nvm_list_versions

# Test functionality
test_node_functionality
test_npm_functionality

# Test .npmrc configuration
test_npmrc_file

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Reload your shell configuration if NVM is not working:"
print_warning "   source ~/.zshrc  # or ~/.bashrc if using bash"
print_warning "2. Verify NVM is working:"
print_warning "   nvm --version"
print_warning "   nvm ls"
print_warning "3. Verify Node.js and npm:"
print_warning "   node --version"
print_warning "   npm --version"
print_warning "4. Test Node.js with a simple script:"
print_warning "   node -e \"console.log('Hello from Node.js')\""
print_warning "5. Test npm with a simple command:"
print_warning "   npm list -g --depth=0"
print_warning "6. Verify .npmrc configuration:"
print_warning "   cat ~/.npmrc"
print_warning "   Make sure all placeholders are replaced with actual values"

