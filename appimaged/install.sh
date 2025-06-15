#!/bin/bash

set -e

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

# Check if we're in a container
if [ -f /.dockerenv ]; then
    print_warning "Running in a container environment"
    print_warning "Skipping appimaged installation as it's not supported in containers"
    exit 0
fi

print_header "Installing appimaged configuration"

# Check if appimaged is installed
if ! command -v appimaged &> /dev/null; then
    print_status "Installing appimaged..."
    # Download and install appimaged
    wget -c https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimaged-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2) -P ~/Applications/
    chmod +x ~/Applications/appimaged-*.AppImage
    ~/Applications/appimaged-*.AppImage
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p ~/.config/appimaged
mkdir -p ~/.local/share/appimaged

# Create systemd user service directory if it doesn't exist
mkdir -p ~/.config/systemd/user

# Create the systemd service file
print_status "Creating systemd service file..."
cat > ~/.config/systemd/user/appimaged.service << EOL
[Unit]
Description=AppImage daemon
After=network.target

[Service]
ExecStart=/usr/bin/appimaged
Restart=on-failure
RestartSec=5
Environment=APPIMAGED_APPLICATIONS_DIR=\${HOME}/Applications

[Install]
WantedBy=default.target
EOL

# Enable and start the service
print_status "Enabling and starting appimaged service..."
systemctl --user daemon-reload
systemctl --user enable appimaged
systemctl --user start appimaged

# Launch appimaged
print_status "Launching appimaged..."
~/Applications/appimaged-*.AppImage &

# Create symlinks
print_status "Creating symlinks..."
stow -t ~ -d "$(dirname "$0")" .

print_success "appimaged configuration installed successfully!"
print_warning "Please restart your session for all changes to take effect"
print_warning "AppImages will be installed in ~/Applications directory" 