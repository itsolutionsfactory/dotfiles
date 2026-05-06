#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="zsh"
OS_TYPE="$(uname -s)"

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

# Function to check if a font is installed
check_font_installed() {
    local font_name="$1"
    case "$OS_TYPE" in
        Darwin)
            system_profiler SPFontsDataType 2>/dev/null | grep -i "$font_name" &> /dev/null
            ;;
        *)
            fc-list | grep -i "$font_name" &> /dev/null
            ;;
    esac
}

install_brew_package() {
    local package="$1"
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew is required to install $package on MacOS"
        exit 1
    fi

    brew install "$package"
}

install_brew_cask() {
    local cask="$1"
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew is required to install $cask on MacOS"
        exit 1
    fi

    brew install --cask "$cask"
}

# Print module header
print_header "Installing $MODULE_NAME configuration"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Install ZSH if not already installed
if ! command -v zsh &> /dev/null; then
    print_status "Installing ZSH..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        install_brew_package "zsh"
    else
        sudo apt-get update
        sudo apt-get install -y zsh
    fi
fi

# Remove Oh My Posh if installed
if command -v oh-my-posh &> /dev/null; then
    print_status "Removing Oh My Posh..."
    sudo rm -f /usr/local/bin/oh-my-posh
    rm -rf "$HOME/.poshthemes"
    print_success "Oh My Posh removed successfully"
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Catppuccin theme for Oh My Zsh
print_status "Installing Catppuccin theme..."
THEMES_DIR="$HOME/.oh-my-zsh/custom/themes"
mkdir -p "$THEMES_DIR"
git clone https://github.com/zyoNoob/catppuccin-ohmyzsh.git /tmp/catppuccin-ohmyzsh
cp /tmp/catppuccin-ohmyzsh/catppuccin.zsh-theme "$THEMES_DIR/"
mkdir -p "$THEMES_DIR/catppuccin-flavors"
cp /tmp/catppuccin-ohmyzsh/catppuccin-flavors/* "$THEMES_DIR/catppuccin-flavors/"
rm -rf /tmp/catppuccin-ohmyzsh

# Install Hack Nerd Font if not already installed
if check_font_installed "Hack Nerd Font"; then
    print_status "Hack Nerd Font is already installed"
else
    print_status "Installing Hack Nerd Font..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        install_brew_cask "font-hack-nerd-font"
    else
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip -O /tmp/hack.zip
        unzip -q /tmp/hack.zip -d /tmp/hack
        cp /tmp/hack/*.ttf "$FONT_DIR"
        rm -rf /tmp/hack /tmp/hack.zip
        fc-cache -f -v
    fi
fi

# Install ZSH plugins
print_status "Installing ZSH plugins..."
PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$PLUGINS_DIR"

# Install zsh-autosuggestions
if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    print_status "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
fi

# Install zsh-z
if [ ! -d "$PLUGINS_DIR/zsh-z" ]; then
    print_status "Installing zsh-z..."
    git clone https://github.com/agkozak/zsh-z.git "$PLUGINS_DIR/zsh-z"
fi

# Install zsh-history-substring-search
if [ ! -d "$PLUGINS_DIR/zsh-history-substring-search" ]; then
    print_status "Installing zsh-history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search.git "$PLUGINS_DIR/zsh-history-substring-search"
fi

# Install zsh-dirhistory
if [ ! -d "$PLUGINS_DIR/zsh-dirhistory" ]; then
    print_status "Installing zsh-dirhistory..."
    git clone https://github.com/robbyrussell/oh-my-zsh.git /tmp/oh-my-zsh
    cp -r /tmp/oh-my-zsh/plugins/dirhistory "$PLUGINS_DIR/zsh-dirhistory"
    rm -rf /tmp/oh-my-zsh
fi

# Install fzf (fuzzy finder)
if command -v fzf >/dev/null 2>&1; then
    print_status "fzf is already installed. Skipping installation."
else
    print_status "Installing fzf..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        install_brew_package "fzf"
    else
        if [ -d "$HOME/.fzf" ]; then
            print_warning "fzf directory already exists, removing it..."
            rm -rf "$HOME/.fzf"
        fi
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi
fi

# Set ZSH as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    print_status "Setting ZSH as default shell..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! grep -q "^$(which zsh)$" /etc/shells; then
            print_status "Adding $(which zsh) to /etc/shells..."
            echo "$(which zsh)" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$(which zsh)"
    else
        sudo chsh -s "$(which zsh)"
    fi
    print_warning "Please log out and log back in for the changes to take effect"
fi

# Handle existing .zshrc file before stowing
if [ -f "$HOME/.zshrc" ]; then
    if [ -L "$HOME/.zshrc" ]; then
        print_status "Removing existing .zshrc symlink..."
        rm "$HOME/.zshrc"
    else
        print_status "Backing up existing .zshrc file..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        mv "$HOME/.zshrc" "$BACKUP_DIR/zshrc_backup_$TIMESTAMP"
        print_success "Backup created at $BACKUP_DIR/zshrc_backup_$TIMESTAMP"
    fi
fi

# Use stow to create symlinks
print_status "Installing $MODULE_NAME configuration..."
if ! stow -t "$HOME" .; then
    print_error "Failed to install $MODULE_NAME configuration"
    exit 1
fi

print_success "$MODULE_NAME configuration installed successfully!"
print_warning "Please set your terminal emulator to use 'Hack Nerd Font' for the best experience"
print_warning "You may need to restart your terminal for the font changes to take effect"