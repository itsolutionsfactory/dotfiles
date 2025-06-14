#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="zsh"

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

# Function to test if a file is properly linked by stow
test_stow_link() {
    local target="$1"
    local source="$2"
    
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

# Function to test Oh My Posh configuration
test_oh_my_posh_config() {
    if grep -q "eval \"\$(oh-my-posh init zsh --config \$HOME/.poshthemes/catppuccin.omp.json)\"" "$HOME/.zshrc"; then
        print_success "Oh My Posh is properly configured in .zshrc"
        return 0
    else
        print_error "Oh My Posh is not properly configured in .zshrc"
        return 1
    fi
}

print_header "Testing $MODULE_NAME configuration"

# Test basic installations
if command -v zsh &> /dev/null; then
    print_success "ZSH is installed"
else
    print_error "ZSH is not installed"
fi

if command -v oh-my-posh &> /dev/null; then
    print_success "Oh My Posh is installed"
else
    print_error "Oh My Posh is not installed"
fi

# Test font installation
FONT_DIR="$HOME/.local/share/fonts"
if [ -d "$FONT_DIR" ]; then
    print_success "Font directory exists"
else
    print_error "Font directory does not exist"
fi

if fc-list | grep -i "Hack Nerd Font" &> /dev/null; then
    print_success "Hack Nerd Font is installed"
else
    print_error "Hack Nerd Font is not installed"
fi

# Test ZSH plugins
PLUGINS_DIR="$HOME/.zsh/plugins"
if [ -d "$PLUGINS_DIR" ]; then
    print_success "Plugins directory exists"
else
    print_error "Plugins directory does not exist"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete zsh-z zsh-history-substring-search zsh-dirhistory; do
    if [ -d "$PLUGINS_DIR/$plugin" ]; then
        print_success "$plugin is installed"
    else
        print_error "$plugin is not installed"
    fi
done

# Test configuration files
if [ -f "$HOME/.zshrc" ]; then
    print_success ".zshrc exists"
else
    print_error ".zshrc does not exist"
fi

test_stow_link "$HOME/.zshrc" "$SCRIPT_DIR/.zshrc"

# Test Oh My Posh configuration
test_oh_my_posh_config

# Test if ZSH is the default shell
if [ "$SHELL" = "$(which zsh)" ]; then
    print_success "ZSH is set as default shell"
else
    print_warning "ZSH is not set as default shell"
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Open a new terminal and check if Catppuccin theme is displayed correctly"
print_warning "2. Try the following commands to verify functionality:"
print_warning "   - Type 'cd' and press TAB to test autocomplete"
print_warning "   - Type a command and press right arrow to test autosuggestions"
print_warning "   - Press Ctrl+T to test fuzzy finder"
print_warning "   - Use 'z' command to test smart directory jumping"
print_warning "   - Use 'd' and 'f' to test directory history" 