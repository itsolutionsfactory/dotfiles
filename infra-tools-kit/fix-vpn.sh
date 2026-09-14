#!/bin/bash

# Keep the ITSF WireGuard VPN up while working from the office.
#
# The NetworkManager dispatcher installed by apt-packages/wireguard-setup.sh
# (/etc/NetworkManager/dispatcher.d/20-itsf-vpn) deliberately skips the VPN
# when the laptop is on the corporate WiFi (ITSF-Wifi), and stops it whenever
# the WiFi goes down. From the office, some Monaco Telecom services are only
# reachable through the tunnel (they allow the VPN exit IP, not the office
# one), so a newcomer sitting at the office still needs the VPN.
#
# This script turns the laptop into an "always on" VPN client:
#   1. Removes the dispatcher, so nothing stops the tunnel on its own.
#   2. Adds PersistentKeepalive = 25 to the peer if it is missing, so the NAT
#      mapping survives idle periods (wireguard-setup.sh now sets it too).
#   3. Re-enables connection.autoconnect on the "itsf" connection, so the VPN
#      comes back by itself after a reboot or a WiFi change.
#
# Whether the dispatcher should skip the VPN on ITSF-Wifi at all is an open
# question with the Infra team; until it is settled, run this once on a
# laptop that needs the VPN at the office:  fix-vpn
#
# Every file it changes is backed up under ~/.vpn-fix-backup/<timestamp>/.

set -e

VPN_NAME="itsf"
DISPATCHER="/etc/NetworkManager/dispatcher.d/20-itsf-vpn"
WG_CONF="/etc/wireguard/itsf.conf"
BACKUP_DIR="$HOME/.vpn-fix-backup/$(date +%Y%m%d_%H%M%S)"

# Catppuccin Mocha
BASE="\033[0m"
RED="\033[38;2;243;139;168m"
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
BLUE="\033[38;2;137;180;250m"
MAUVE="\033[38;2;203;166;247m"

print_status()  { echo -e "${BLUE}[i]${BASE} $1"; }
print_success() { echo -e "${GREEN}[✓]${BASE} $1"; }
print_error()   { echo -e "${RED}[✗]${BASE} $1"; }
print_warning() { echo -e "${YELLOW}[!]${BASE} $1"; }
print_header()  { echo -e "\n${MAUVE}=== $1 ===${BASE}\n"; }

print_header "Fixing ITSF VPN disconnections"

# Preconditions
if [ "$EUID" -eq 0 ]; then
    print_error "Do not run this as root - it calls sudo where needed"
    exit 1
fi

if [ "$(uname -s)" != "Linux" ]; then
    print_error "Linux only (detected: $(uname -s))"
    exit 1
fi

if ! command -v nmcli >/dev/null 2>&1; then
    print_error "nmcli not found - is NetworkManager installed?"
    exit 1
fi

if ! nmcli -g NAME connection show | grep -qx "$VPN_NAME"; then
    print_error "No '$VPN_NAME' connection in NetworkManager"
    print_warning "Set the VPN up first: apt-packages/wireguard-setup.sh in the dotfiles repository"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
print_status "Backups will be written to $BACKUP_DIR"

# 1. Remove the dispatcher that tears the tunnel down
print_header "1/3 - Removing the VPN dispatcher"

if [ -f "$DISPATCHER" ]; then
    sudo cp -a "$DISPATCHER" "$BACKUP_DIR/20-itsf-vpn"
    sudo rm -f "$DISPATCHER"
    print_success "Removed $DISPATCHER"
else
    print_status "Already absent: $DISPATCHER"
fi

# 2. Keep the tunnel alive through office NAT
print_header "2/3 - Enabling PersistentKeepalive"

if [ ! -f "$WG_CONF" ]; then
    print_warning "$WG_CONF not found - skipping keepalive"
elif sudo grep -qi '^\s*PersistentKeepalive' "$WG_CONF"; then
    print_status "PersistentKeepalive already set in $WG_CONF"
else
    sudo cp -a "$WG_CONF" "$BACKUP_DIR/itsf.conf"
    echo "PersistentKeepalive = 25" | sudo tee -a "$WG_CONF" >/dev/null
    print_success "Added PersistentKeepalive = 25 to $WG_CONF"

    # NetworkManager keeps its own copy of the peer, so re-import it
    print_status "Re-importing the connection into NetworkManager..."
    sudo nmcli connection delete "$VPN_NAME" >/dev/null 2>&1 || true
    sudo nmcli connection import type wireguard file "$WG_CONF"
    print_success "Connection '$VPN_NAME' re-imported"
fi

# 3. Let the VPN come back up on its own
print_header "3/3 - Re-enabling autoconnect"

sudo nmcli connection modify "$VPN_NAME" connection.autoconnect yes
print_success "connection.autoconnect=yes on '$VPN_NAME'"

# Apply and bring the tunnel back
print_header "Applying"

sudo systemctl restart NetworkManager
sleep 3

if nmcli connection show --active | grep -q "$VPN_NAME"; then
    print_success "VPN '$VPN_NAME' is up"
else
    print_status "Bringing the VPN up..."
    if nmcli connection up "$VPN_NAME" >/dev/null 2>&1; then
        print_success "VPN '$VPN_NAME' is up"
    else
        print_warning "Could not bring the VPN up automatically"
        print_warning "Try manually: nmcli connection up $VPN_NAME"
    fi
fi

print_header "Done"
print_status "Check the tunnel:  sudo wg show"
print_status "Check the state:   nmcli connection show --active | grep $VPN_NAME"
print_success "The VPN should no longer drop on its own"
