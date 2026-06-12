#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/../backup"
MODULE_NAME="linux-config"
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

# Print module header
print_header "Upgrading WiFi configuration"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Improve WiFi Framework (Intel or MediaTek) - Ubuntu 24.04
# Compatible : Intel AX200/AX210/AX211, MediaTek RZ616/RZ608/RZ717

# Identify WiFi interface via /sys
WIFI_IF=$(ls /sys/class/ieee80211/*/device/net/ 2>/dev/null | head -1)
if [ -z "$WIFI_IF" ]; then
    print_error "No WiFi interface detected."
    exit 1
fi
print_status "WiFi interface detected : $WIFI_IF"

# Detect the WiFi chipset
print_status "Detection of the WiFi chipset"
WIFI_PCI=$(lspci | grep -i "network\|wireless")
print_status "$WIFI_PCI"

# Detect the dynamically loaded driver
DRIVER=$(basename "$(readlink /sys/class/net/$WIFI_IF/device/driver/module)" 2>/dev/null)
print_status "Loaded driver : $DRIVER"

if echo "$WIFI_PCI" | grep -qi "mediatek\|mt79\|RZ616\|RZ608\|RZ717\|0616\|0717"; then
    CHIPSET="mediatek"
    # The driver can be mt7921e, mt7925e, or other mt79xx variant
    if [ -z "$DRIVER" ] || ! echo "$DRIVER" | grep -q "mt79"; then
        print_error "MediaTek driver not detected (driver found : $DRIVER)"
        print_warning "Check that the WiFi card is properly recognized."
        exit 1
    fi
    # Extract the module prefix (mt7921, mt7925, etc.)
    # mt7921e → mt7921, mt7925e → mt7925
    MT_PREFIX=$(echo "$DRIVER" | sed 's/e$//')
    print_status "→ Detected chipset : MediaTek (driver: $DRIVER, prefix: $MT_PREFIX)"
elif echo "$WIFI_PCI" | grep -qi "intel\|AX210\|AX211\|AX200\|AX201"; then
    CHIPSET="intel"
    DRIVER="iwlwifi"
    print_status "→ Detected chipset : Intel (driver: $DRIVER)"
else
    print_error "WiFi chipset not recognized."
    print_warning "lspci output : $WIFI_PCI"
    print_warning "Detected driver : $DRIVER"
    print_warning "This script supports only Intel (iwlwifi) and MediaTek (mt79xx)."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup existing configuration if it exists
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/modules/$MODULE_NAME/wifi-backup_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR/modules/$MODULE_NAME"

tar -czf "$BACKUP_FILE" -C / \
    $( [ -f /etc/modprobe.d/wifi-fix.conf ] && echo etc/modprobe.d/wifi-fix.conf ) \
    $( [ -f /etc/NetworkManager/conf.d/wifi-powersave.conf ] && echo etc/NetworkManager/conf.d/wifi-powersave.conf ) \
    2>/dev/null || true

print_header "Current state"
print_status "--- WiFi card ---"
print_status "$WIFI_PCI"
print_status "--- Loaded driver ---"
ls -l /sys/class/net/"$WIFI_IF"/device/driver/module 2>/dev/null || print_warning "Driver not identified"
if [ "$CHIPSET" = "mediatek" ]; then
    print_status "--- Loaded MediaTek modules ---"
    lsmod | grep mt79 || print_warning "No mt79 module loaded"
    print_status "--- Firmware MediaTek ---"
    ls -la /lib/firmware/mediatek/WIFI_MT79* 2>/dev/null || print_warning "MediaTek firmware not found"
else
    print_status "--- Loaded Intel module ---"
    modinfo iwlwifi 2>/dev/null | grep -E "version|filename" || print_warning " iwlwifi module not loaded"
fi
print_status "--- Kernel ---"
uname -r
    print_status "--- Current power save ---"
cat /sys/class/net/"$WIFI_IF"/power/control 2>/dev/null || print_warning "Not available"
print_status "--- Current connection ---"
nmcli -t -f GENERAL.STATE,WIFI.FREQ,WIFI.SIGNAL,WIFI.SSID device show "$WIFI_IF" 2>/dev/null || print_warning "Not connected"

print_header "Update firmware and kernel HWE"
sudo apt update
sudo apt install -y linux-firmware linux-generic-hwe-24.04

echo ""
print_header "Configure module driver"
if [ "$CHIPSET" = "mediatek" ]; then
    # MediaTek RZ616 (mt7921e) / RZ717 (mt7925e) / etc.
    # power_save=0 : disable the power save of the module
    #   → the MediaTek power save is more aggressive than the Intel one
    #   → cause direct of the collapsed throughput
    # Configure the specific driver + the common modules
    cat << MODULE_EOF | sudo tee /etc/modprobe.d/wifi-fix.conf
options ${DRIVER} power_save=0
options ${MT_PREFIX}_common power_save=0
options mt792x_lib power_save=0
MODULE_EOF
else
    # Intel AX210 / AX211
    # power_scheme=1 : max performance mode
    #   → 1 = performance, 2 = balanced, 3 = economy
    sudo tee /etc/modprobe.d/wifi-fix.conf << 'EOF'
options iwlmvm power_scheme=1
EOF
fi
print_status "Module $DRIVER configured :"
cat /etc/modprobe.d/wifi-fix.conf

print_header "Disable WiFi power save (NetworkManager)"
# wifi.powersave=2 : disable (1 = default, 3 = enable)
#   → double protection with the module option
sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf << 'EOF'
[connection]
wifi.powersave=2
EOF
print_success "Power save NetworkManager disabled"

print_header "Apply the changes"
sudo systemctl restart NetworkManager
sleep 3

print_header "Post-configuration checks"
print_status "--- Chipset : $CHIPSET (driver: $DRIVER) ---"
print_status "--- Connection ---"
nmcli -t -f WIFI.FREQ,WIFI.SIGNAL,WIFI.SSID device show "$WIFI_IF" 2>/dev/null || echo "Reconnection in progress..."
print_status "--- Created files ---"
ls -la /etc/modprobe.d/wifi-fix.conf
ls -la /etc/NetworkManager/conf.d/wifi-powersave.conf
print_success "WiFi configuration upgraded successfully"
