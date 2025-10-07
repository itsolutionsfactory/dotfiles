#!/bin/bash

# Exit on any error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
print_header "WireGuard Setup and Configuration"

# Check if WireGuard is installed
if ! command -v wg >/dev/null 2>&1; then
    print_error "WireGuard is not installed. Please install it first."
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root or with sudo"
    exit 1
fi

# Create WireGuard directory if it doesn't exist
WIREGUARD_DIR="/etc/wireguard"
if [ ! -d "$WIREGUARD_DIR" ]; then
    print_status "Creating WireGuard directory..."
    mkdir -p "$WIREGUARD_DIR"
    chmod 700 "$WIREGUARD_DIR"
    print_success "WireGuard directory created"
fi

# Function to get IP address from user
get_ip_address() {
    while true; do
        read -p "Entrez le dernier digit de l'adresse IP (par exemple, 101 pour 192.168.66.101) : " LAST_DIGIT

        # Vérifie que l'entrée est un chiffre valide
        if [[ $LAST_DIGIT =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Erreur : Veuillez entrer un nombre valide."
        fi
    done
    
    echo "192.168.66.$LAST_DIGIT/32"
}

# Function to generate WireGuard keys
generate_keys() {
    local key_dir="$WIREGUARD_DIR/keys"
    
    print_status "Generating keys for ITSF WireGuard"
    
    # Create keys directory
    mkdir -p "$key_dir"
    chmod 700 "$key_dir"
    
    # Generate private key
    touch "$key_dir/private.key"
    chmod 600 "$key_dir/private.key"
    wg genkey > "$key_dir/private.key"
    wg pubkey < "$key_dir/private.key" > "$key_dir/pub.key"
    
    print_success "Keys generated for ITSF WireGuard"
    print_status "Private key: $(cat "$key_dir/private.key")"
    print_status "Public key: $(cat "$key_dir/pub.key")"
}

# Function to create ITSF WireGuard configuration
create_itsf_config() {
    local config_file="$WIREGUARD_DIR/itsf.conf"
    
    print_status "Creating ITSF WireGuard configuration"
    
    # Get the private key
    local private_key
    private_key=$(cat "$WIREGUARD_DIR/keys/private.key")
    
    # Get IP address from user
    local ip_address
    ip_address=$(get_ip_address)
    
    # Create ITSF configuration
    cat > "$config_file" << EOF
[Interface]
PrivateKey = $private_key
Address = $ip_address
DNS = 10.195.28.20, 10.195.28.50

[Peer]
PublicKey = 9gPxIUJ1AZS0pgmKw6ulHH4y28CANsqWHzpS3azpVVo=
AllowedIPs = 10.195.0.0/16, 172.16.0.0/12, 192.168.66.0/24, 195.78.27.214/32, 195.78.28.87/32, 195.78.28.79/32, 51.83.80.113/32
Endpoint = vpn-user.itsf.io:5544
EOF
    
    chmod 600 "$config_file"
    print_success "ITSF configuration file created: $config_file"
}

# Function to import WireGuard connection to NetworkManager
import_networkmanager_connection() {
    print_status "Importing WireGuard connection to NetworkManager"
    
    # Import the configuration to NetworkManager
    nmcli connection import type wireguard file /etc/wireguard/itsf.conf
    
    print_success "WireGuard connection imported to NetworkManager"
    print_warning "You can now manage the connection through NetworkManager"
}

# Function to show WireGuard status
show_wireguard_status() {
    print_status "WireGuard status:"
    if wg show >/dev/null 2>&1; then
        wg show
    else
        print_warning "No WireGuard interfaces are currently active"
    fi
}

# Main setup process
print_status "Starting ITSF WireGuard setup..."

# Generate keys
generate_keys

# Create ITSF configuration
create_itsf_config

# Import to NetworkManager
import_networkmanager_connection

# Show status
show_wireguard_status

print_success "ITSF WireGuard setup completed!"

# Display next steps
print_header "Next Steps"
print_warning "Your ITSF WireGuard configuration is ready!"
print_warning "1. Connect to the VPN:"
print_warning "   - Use NetworkManager GUI or:"
print_warning "   - nmcli connection up itsf"
print_warning "2. Check connection status:"
print_warning "   sudo wg show"
print_warning "3. Disconnect when needed:"
print_warning "   nmcli connection down itsf"
print_warning "4. Your public key for server configuration:"
print_success "$(cat $WIREGUARD_DIR/keys/pub.key)"
