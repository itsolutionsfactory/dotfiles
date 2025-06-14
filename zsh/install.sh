#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
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

# Function to check if a font is installed
check_font_installed() {
    local font_name="$1"
    if fc-list | grep -i "$font_name" &> /dev/null; then
        return 0
    else
        return 1
    fi
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
    sudo apt-get update
    sudo apt-get install -y zsh
fi

# Install Oh My Posh if not already installed
if ! command -v oh-my-posh &> /dev/null; then
    print_status "Installing Oh My Posh..."
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
fi

# Install Hack Nerd Font if not already installed
if check_font_installed "Hack Nerd Font"; then
    print_status "Hack Nerd Font is already installed"
else
    print_status "Installing Hack Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip -O /tmp/hack.zip
    unzip -q /tmp/hack.zip -d /tmp/hack
    cp /tmp/hack/*.ttf "$FONT_DIR"
    rm -rf /tmp/hack /tmp/hack.zip
    fc-cache -f -v
fi

# Install ZSH plugins
print_status "Installing ZSH plugins..."
PLUGINS_DIR="$HOME/.zsh/plugins"
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

# Install zsh-z (smarter cd command)
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
    if [ -d "$HOME/.fzf" ]; then
        print_warning "fzf directory already exists, removing it..."
        rm -rf "$HOME/.fzf"
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# Set ZSH as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    print_status "Setting ZSH as default shell..."
    sudo chsh -s "$(which zsh)"
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