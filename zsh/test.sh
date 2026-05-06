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

# Function to test Oh My Zsh configuration
test_oh_my_zsh_config() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_error "Oh My Zsh is not installed"
        return 1
    fi

    if [ ! -f "$HOME/.oh-my-zsh/custom/themes/catppuccin.zsh-theme" ]; then
        print_error "Catppuccin theme is not installed"
        return 1
    fi

    if [ ! -f "$HOME/.oh-my-zsh/custom/themes/catppuccin-flavors/catppuccin-mocha.zsh" ]; then
        print_error "Catppuccin Mocha flavor file is not installed"
        return 1
    fi

    if grep -q 'ZSH_THEME="catppuccin"' "$HOME/.zshrc" && \
       grep -q 'CATPPUCCIN_FLAVOR="mocha"' "$HOME/.zshrc" && \
       grep -q 'CATPPUCCIN_SHOW_TIME=true' "$HOME/.zshrc"; then
        print_success "Catppuccin theme is properly configured in .zshrc"
        return 0
    else
        print_error "Catppuccin theme is not properly configured in .zshrc"
        print_error "Please check ZSH_THEME, CATPPUCCIN_FLAVOR, and CATPPUCCIN_SHOW_TIME settings"
        return 1
    fi
}

print_header "Testing $MODULE_NAME configuration"
TEST_FAILURES=0

if [ "${DOTFILES_TEST_MODE:-0}" = "1" ]; then
    # shellcheck source=../scripts/test-lib.sh
    . "$SCRIPT_DIR/../scripts/test-lib.sh"
    test_stow_link_portable "$HOME/.zshrc" "$SCRIPT_DIR/.zshrc" || TEST_FAILURES=$((TEST_FAILURES + 1))
    grep -q 'brew --prefix nvm' "$HOME/.zshrc" || {
        print_error ".zshrc does not include the Homebrew NVM fallback"
        TEST_FAILURES=$((TEST_FAILURES + 1))
    }

    if [ "$TEST_FAILURES" -gt 0 ]; then
        print_error "$TEST_FAILURES test(s) failed"
        exit 1
    fi

    print_success "Portable $MODULE_NAME tests completed"
    exit 0
fi

# Test basic installations
if command -v zsh &> /dev/null; then
    print_success "ZSH is installed"
else
    print_error "ZSH is not installed"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

# Test HyFetch installation
if command -v hyfetch &> /dev/null; then
    print_success "hyfetch is installed"
    if [ -f "$HOME/.config/hyfetch.json" ]; then
        print_success "hyfetch configuration is installed"
    else
        print_error "hyfetch configuration is not installed"
        TEST_FAILURES=$((TEST_FAILURES + 1))
    fi
else
    print_error "hyfetch is not installed"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

# Test Oh My Zsh installation and configuration
test_oh_my_zsh_config || TEST_FAILURES=$((TEST_FAILURES + 1))

# Test font installation
FONT_DIR="$HOME/.local/share/fonts"
if [ -d "$FONT_DIR" ]; then
    print_success "Font directory exists"
else
    print_error "Font directory does not exist"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

if fc-list | grep -i "Hack Nerd Font" &> /dev/null; then
    print_success "Hack Nerd Font is installed"
else
    print_error "Hack Nerd Font is not installed"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

# Test ZSH plugins
PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
if [ -d "$PLUGINS_DIR" ]; then
    print_success "Custom plugins directory exists"
else
    print_error "Custom plugins directory does not exist"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

# Test each plugin
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-z zsh-history-substring-search zsh-dirhistory; do
    if [ -d "$PLUGINS_DIR/$plugin" ]; then
        print_success "$plugin is installed"
    else
        print_error "$plugin is not installed"
        TEST_FAILURES=$((TEST_FAILURES + 1))
    fi
done

# Test configuration files
if [ -f "$HOME/.zshrc" ]; then
    print_success ".zshrc exists"
else
    print_error ".zshrc does not exist"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

test_stow_link "$HOME/.zshrc" "$SCRIPT_DIR/.zshrc" || TEST_FAILURES=$((TEST_FAILURES + 1))

# Test if ZSH is the default shell
if [ "$SHELL" = "$(which zsh)" ]; then
    print_success "ZSH is set as default shell"
else
    print_warning "ZSH is not set as default shell"
fi

if [ "$TEST_FAILURES" -gt 0 ]; then
    print_error "$TEST_FAILURES test(s) failed"
    exit 1
fi

print_success "Testing completed!"
print_warning "Please verify the following manually:"
print_warning "1. Open a new terminal and check if Catppuccin Mocha theme is displayed correctly"
print_warning "2. Verify that the system information display shows correctly with HyFetch logo and system specs"
print_warning "3. Try the following commands to verify functionality:"
print_warning "   - Type 'cd' and press TAB to test autocomplete"
print_warning "   - Type a command and press right arrow to test autosuggestions"
print_warning "   - Press Ctrl+T to test fuzzy finder"
print_warning "   - Use 'z' command to test smart directory jumping"
print_warning "   - Use 'd' and 'f' to test directory history" 