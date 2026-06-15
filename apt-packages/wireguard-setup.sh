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

# Ask user if they want to set up WireGuard
print_status "This script will set up WireGuard VPN configuration for ITSF."
echo
read -p "$(echo -e "${YELLOW}Do you want to set up WireGuard VPN? (y/N): ${BASE}")" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "WireGuard setup skipped by user."
    exit 0
fi

# Check if WireGuard is installed
if ! command -v wg >/dev/null 2>&1; then
    print_error "WireGuard is not installed. Please install it first."
    exit 1
fi

# Check if we have sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges. You may be prompted for your password."
fi

# Create WireGuard directory if it doesn't exist
WIREGUARD_DIR="/etc/wireguard"
if [ ! -d "$WIREGUARD_DIR" ]; then
    print_status "Creating WireGuard directory..."
    sudo mkdir -p "$WIREGUARD_DIR"
    sudo chmod 700 "$WIREGUARD_DIR"
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
    sudo mkdir -p "$key_dir"
    sudo chmod 700 "$key_dir"
    
    # Generate private key
    print_status "Creating private key file..."
    sudo touch "$key_dir/private.key"
    sudo chmod 600 "$key_dir/private.key"
    
    print_status "Generating private key..."
    if ! wg genkey | sudo tee "$key_dir/private.key" > /dev/null; then
        print_error "Failed to generate private key"
        exit 1
    fi
    
    print_status "Generating public key..."
    # Read the private key and generate public key
    local private_key_content
    if ! private_key_content=$(sudo cat "$key_dir/private.key"); then
        print_error "Failed to read private key"
        exit 1
    fi
    
    if ! echo "$private_key_content" | wg pubkey | sudo tee "$key_dir/pub.key" > /dev/null; then
        print_error "Failed to generate public key"
        exit 1
    fi
    
    # Set proper permissions on public key
    sudo chmod 644 "$key_dir/pub.key"
    
    print_success "Keys generated for ITSF WireGuard"
    print_status "Private key: $(sudo cat "$key_dir/private.key")"
    print_status "Public key: $(sudo cat "$key_dir/pub.key")"
}

# Function to create ITSF WireGuard configuration
create_itsf_config() {
    local config_file="$WIREGUARD_DIR/itsf.conf"
    
    print_status "Creating ITSF WireGuard configuration"
    
    # Get the private key
    local private_key
    if ! private_key=$(sudo cat "$WIREGUARD_DIR/keys/private.key"); then
        print_error "Failed to read private key"
        exit 1
    fi
    
    # Get IP address from user
    local ip_address
    ip_address=$(get_ip_address)
    
    # Create ITSF configuration
    sudo tee "$config_file" > /dev/null << EOF
[Interface]
PrivateKey = $private_key
Address = $ip_address
DNS = 10.195.28.20, 10.195.28.50

[Peer]
PublicKey = 9gPxIUJ1AZS0pgmKw6ulHH4y28CANsqWHzpS3azpVVo=
AllowedIPs = 10.195.0.0/16, 172.16.0.0/12, 192.168.66.0/24, 195.78.27.214/32, 195.78.28.87/32, 195.78.28.79/32, 51.83.80.113/32
Endpoint = vpn-user.itsf.io:5544
EOF
    
    sudo chmod 600 "$config_file"
    print_success "ITSF configuration file created: $config_file"
}

# Function to import WireGuard connection to NetworkManager
import_networkmanager_connection() {
    print_status "Importing WireGuard connection to NetworkManager"
    
    # Check if connection already exists
    if sudo nmcli connection show itsf >/dev/null 2>&1; then
        print_warning "Connection 'itsf' already exists. Removing it first..."
        sudo nmcli connection delete itsf >/dev/null 2>&1 || true
    fi
    
    # Import the configuration to NetworkManager
    sudo nmcli connection import type wireguard file /etc/wireguard/itsf.conf
    
    # Disable autoconnect to prevent VPN from starting at boot
    sudo nmcli connection modify itsf connection.autoconnect no
    
    print_success "WireGuard connection imported to NetworkManager"
    print_warning "You can now manage the connection through NetworkManager"
}

# Function to install dispatcher script for auto VPN management
install_dispatcher_script() {
    print_status "Installing dispatcher script for auto VPN management..."
    DISPATCHER_SCRIPT="/etc/NetworkManager/dispatcher.d/20-itsf-vpn"
    sudo tee "$DISPATCHER_SCRIPT" > /dev/null << 'DISPATCHER_EOF'
#!/bin/bash
IFACE=$1
EVENT=$2
VPN_NAME="itsf"
CORP_SSID="ITSF-Wifi"
CORP_DNS_1="10.195.28.20"
CORP_DNS_2="10.195.28.50"
MAX_WAIT=8

wait_for_ip() {
    local attempt=0
    while [[ $attempt -lt $MAX_WAIT ]]; do
        ip addr show "$IFACE" | grep -q 'inet ' && return 0
        sleep 0.5
        (( attempt++ ))
    done
    logger -t nm-dispatcher "itsf-vpn: timeout waiting for IP on $IFACE"
    return 1
}

wait_for_dns() {
    local attempt=0
    while [[ $attempt -lt $MAX_WAIT ]]; do
        timeout 2 resolvectl query --interface="$IFACE" gitlab.steelhome.internal &>/dev/null && return 0
        sleep 0.5
        (( attempt++ ))
    done
    logger -t nm-dispatcher "itsf-vpn: timeout waiting for DNS on $IFACE"
    return 1
}

is_on_corp_network() {
    local active_dns
    active_dns=$(nmcli dev show "$IFACE" 2>/dev/null | grep 'IP4.DNS' | awk '{print $2}')
    echo "$active_dns" | grep -qE "^($CORP_DNS_1|$CORP_DNS_2)$"
}

case "$EVENT" in
    up)
        [[ "$IFACE" =~ ^wl ]] || exit 0
        CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2) || true
        if [[ "$CURRENT_SSID" == "$CORP_SSID" ]] || is_on_corp_network; then
            logger -t nm-dispatcher "itsf-vpn: corporate network detected, VPN skipped"
            exit 0
        fi
        wait_for_ip || logger -t nm-dispatcher "itsf-vpn: IP timeout, continuant"
        wait_for_dns || logger -t nm-dispatcher "itsf-vpn: DNS timeout, continuant"
        if nmcli connection show --active | grep -q "$VPN_NAME"; then
            logger -t nm-dispatcher "itsf-vpn: VPN déjà actif, skipping"
            exit 0
        fi
        nmcli connection up "$VPN_NAME"
        logger -t nm-dispatcher "itsf-vpn: VPN $VPN_NAME started on $IFACE (SSID: $CURRENT_SSID)"
        ;;
    down)
        if nmcli connection show --active | grep -q "$VPN_NAME"; then
            nmcli connection down "$VPN_NAME"
            logger -t nm-dispatcher "itsf-vpn: VPN $VPN_NAME arrêté après WiFi down"
        fi
        ;;
esac

exit 0
DISPATCHER_EOF
    sudo chmod 700 "$DISPATCHER_SCRIPT"
    sudo chown root:root "$DISPATCHER_SCRIPT"
    print_success "Dispatcher script installed: $DISPATCHER_SCRIPT"
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

# Generate keys if the private key doesn't exist, or just install the dispatcher if it does
if sudo [ -f "$WIREGUARD_DIR/keys/private.key" ]; then
    print_warning "Keys already exist. Skipping key generation..."
    print_status "Updating dispatcher script and NetworkManager connection only..."
    import_networkmanager_connection
    install_dispatcher_script
else
    generate_keys
    
    # Create ITSF configuration
    create_itsf_config
    
    # Import to NetworkManager
    import_networkmanager_connection
    
    # Install dispatcher script
    install_dispatcher_script
fi

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
print_success "$(sudo cat $WIREGUARD_DIR/keys/pub.key)"
