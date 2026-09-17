#!/bin/bash

# Exit on any error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="defguard"
OS_TYPE="$(uname -s)"

# Defguard desktop client, pinned release. To upgrade: bump the version and copy the sha256
# digests of the two "ubuntu-22-04-lts" .deb assets and of the universal .dmg from the GitHub
# release page. The unsuffixed "_amd64.deb" asset targets Debian 13, not Ubuntu.
DEFGUARD_VERSION="2.1.0"
DEFGUARD_SHA256_AMD64="060723b5c606a22bcbccee0b244dfeecbedaecdf7a10b626038b4e386e0ec0cd"
DEFGUARD_SHA256_ARM64="01b5c7aab3c84e493868fff33dbf7cbbf3a9f2e4f9b008c28fa20b3383889ffd"
DEFGUARD_SHA256_DMG="fda54789cce9986b8899e1d8dcafce77bfc5756b8c61e097e4e28337932f6bed"
DEFGUARD_RELEASE_URL="https://github.com/DefGuard/client/releases/download/v${DEFGUARD_VERSION}"

# MacOS: the Homebrew cask is stuck on 1.5.x, so the notarized universal DMG is used. Both the
# DMG and the App Store builds are signed by the vendor's Apple Developer team below.
DEFGUARD_MACOS_TEAM_ID="82GZ7KN29J"
DEFGUARD_MACOS_MIN_VERSION="13.5"
DEFGUARD_APP="/Applications/Defguard.app"

# What the package sets up: the client talks to the service through a socket owned by the group
DEFGUARD_GROUP="defguard"
DEFGUARD_SERVICE="defguard-service"
DEFGUARD_SOCKET="/var/run/defguard.socket"
DEFGUARD_ENROLLMENT_URL="https://defguard.itsf.io"

CURRENT_USER="$(id -un)"
REBOOT_REQUIRED=0
TMP_DIR=""
DMG_MOUNT_DIR=""

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
print_header "Installing $MODULE_NAME"

if [ -f /.dockerenv ]; then
    print_warning "Docker environment detected, skipping the Defguard client (desktop app and system service)"
    exit 0
fi

if [ "$(id -u)" -eq 0 ]; then
    print_error "Run this script as your own user, not as root: the group check applies to the user running it"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

cleanup() {
    if [ -n "$DMG_MOUNT_DIR" ]; then
        hdiutil detach -quiet "$DMG_MOUNT_DIR" || true
    fi
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

check_dependencies() {
    local cmd
    print_status "Checking dependencies..."
    for cmd in curl dpkg dpkg-query apt-get sha256sum getent pgrep systemctl; do
        if ! command_exists "$cmd"; then
            print_error "$cmd is not available. Please install it first."
            exit 1
        fi
    done
    print_success "All dependencies are available"
}

detect_package() {
    local arch
    arch="$(dpkg --print-architecture)"
    case "$arch" in
        amd64) DEFGUARD_SHA256="$DEFGUARD_SHA256_AMD64" ;;
        arm64) DEFGUARD_SHA256="$DEFGUARD_SHA256_ARM64" ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    DEFGUARD_DEB="defguard-client${DEFGUARD_VERSION}_${arch}_ubuntu-22-04-lts.deb"
}

installed_version() {
    dpkg-query -W -f='${db:Status-Status} ${Version}\n' defguard-client 2>/dev/null | awk '$1 == "installed" {print $2}'
}

install_client() {
    TMP_DIR="$(mktemp -d)"
    # apt reads local packages as the unprivileged _apt user
    chmod 755 "$TMP_DIR"

    print_status "Downloading $DEFGUARD_DEB..."
    curl -fL --retry 3 -o "$TMP_DIR/$DEFGUARD_DEB" "$DEFGUARD_RELEASE_URL/$DEFGUARD_DEB"
    chmod 644 "$TMP_DIR/$DEFGUARD_DEB"

    print_status "Verifying sha256 checksum..."
    if ! echo "$DEFGUARD_SHA256  $TMP_DIR/$DEFGUARD_DEB" | sha256sum -c --quiet -; then
        print_error "Checksum mismatch for $DEFGUARD_DEB, aborting"
        exit 1
    fi
    print_success "Checksum verified"

    # apt resolves the dependencies (webkit2gtk, appindicator). The package postinst creates the
    # defguard group, adds the sudo user to it, then enables and starts the service.
    print_status "Installing the Defguard client $DEFGUARD_VERSION..."
    sudo apt-get update
    sudo apt-get install -y "$TMP_DIR/$DEFGUARD_DEB"
    print_success "Defguard client $DEFGUARD_VERSION installed"
}

ensure_group_membership() {
    # With a user name, id reads the group database, not the groups of the current session
    if id -nG "$CURRENT_USER" | tr ' ' '\n' | grep -qx "$DEFGUARD_GROUP"; then
        print_success "$CURRENT_USER is a member of the $DEFGUARD_GROUP group"
    else
        print_status "Adding $CURRENT_USER to the $DEFGUARD_GROUP group..."
        sudo usermod -aG "$DEFGUARD_GROUP" "$CURRENT_USER"
        print_success "$CURRENT_USER added to the $DEFGUARD_GROUP group"
    fi
}

check_service() {
    if systemctl is-active --quiet "$DEFGUARD_SERVICE"; then
        print_success "$DEFGUARD_SERVICE is running"
    else
        print_status "Enabling and starting $DEFGUARD_SERVICE..."
        sudo systemctl enable --now "$DEFGUARD_SERVICE"
        print_success "$DEFGUARD_SERVICE started"
    fi

    if [ -S "$DEFGUARD_SOCKET" ]; then
        print_success "Socket $DEFGUARD_SOCKET is present (group $(stat -c %G "$DEFGUARD_SOCKET"))"
    else
        print_warning "Socket $DEFGUARD_SOCKET not found: check 'systemctl status $DEFGUARD_SERVICE'"
    fi
}

check_dns_tooling() {
    if command_exists resolvconf; then
        print_success "resolvconf is available (the client applies the DNS servers of a location with it)"
    else
        print_warning "resolvconf not found: the DNS servers pushed by a Defguard location will not be applied"
        print_warning "Check with the Infra team before installing a resolvconf provider"
    fi
}

# Succeeds when version $1 is greater than or equal to version $2
version_at_least() {
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" = "$2" ]
}

install_macos_client() {
    local macos_version
    local installed=""
    local dmg="Defguard_${DEFGUARD_VERSION}_universal.dmg"
    local mount_dir
    local team_id

    macos_version="$(sw_vers -productVersion)"
    if ! version_at_least "$macos_version" "$DEFGUARD_MACOS_MIN_VERSION"; then
        print_error "The Defguard client needs MacOS $DEFGUARD_MACOS_MIN_VERSION or later (this Mac runs $macos_version)"
        exit 1
    fi

    if [ -d "$DEFGUARD_APP" ]; then
        installed="$(defaults read "$DEFGUARD_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || true)"
        if [ -f "$DEFGUARD_APP/Contents/_MASReceipt/receipt" ]; then
            print_success "Defguard $installed is installed from the App Store, which keeps it up to date"
            return 0
        fi
        if [ -n "$installed" ] && version_at_least "$installed" "$DEFGUARD_VERSION"; then
            print_success "Defguard $installed is already installed"
            return 0
        fi
    fi

    if pgrep -x defguard-client >/dev/null 2>&1; then
        print_error "Defguard is running: quit it from its menu bar icon, then run this script again"
        exit 1
    fi

    TMP_DIR="$(mktemp -d)"
    mount_dir="$TMP_DIR/mnt"
    mkdir -p "$mount_dir"

    print_status "Downloading $dmg..."
    curl -fL --retry 3 -o "$TMP_DIR/$dmg" "$DEFGUARD_RELEASE_URL/$dmg"

    print_status "Verifying sha256 checksum..."
    if ! echo "$DEFGUARD_SHA256_DMG  $TMP_DIR/$dmg" | shasum -a 256 -c --quiet -; then
        print_error "Checksum mismatch for $dmg, aborting"
        exit 1
    fi
    print_success "Checksum verified"

    hdiutil attach -nobrowse -readonly -noautoopen -mountpoint "$mount_dir" "$TMP_DIR/$dmg" >/dev/null
    DMG_MOUNT_DIR="$mount_dir"

    print_status "Verifying the code signature..."
    if ! codesign --verify --deep --strict "$mount_dir/Defguard.app"; then
        print_error "Invalid code signature on Defguard.app, aborting"
        exit 1
    fi
    team_id="$(codesign -dv "$mount_dir/Defguard.app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
    if [ "$team_id" != "$DEFGUARD_MACOS_TEAM_ID" ]; then
        print_error "Defguard.app is signed by team '$team_id', expected $DEFGUARD_MACOS_TEAM_ID, aborting"
        exit 1
    fi
    if ! spctl --assess --type execute "$mount_dir/Defguard.app" 2>/dev/null; then
        print_error "Gatekeeper rejects Defguard.app (not notarized?), aborting"
        exit 1
    fi
    print_success "Signed by Apple Developer team $team_id and accepted by Gatekeeper"

    if [ -n "$installed" ]; then
        print_status "Replacing Defguard $installed with $DEFGUARD_VERSION..."
    fi
    if [ -w /Applications ]; then
        rm -rf "$DEFGUARD_APP"
        ditto "$mount_dir/Defguard.app" "$DEFGUARD_APP"
    else
        print_warning "/Applications is not writable by $CURRENT_USER. You may be prompted for your password."
        sudo rm -rf "$DEFGUARD_APP"
        sudo ditto "$mount_dir/Defguard.app" "$DEFGUARD_APP"
    fi
    print_success "Defguard $DEFGUARD_VERSION installed in /Applications"
}

# Prints the Groups line of /proc/<pid>/status and succeeds when it holds the given gid
process_has_gid() {
    local pid="$1"
    local gid="$2"
    local groups

    groups="$(grep '^Groups:' "/proc/$pid/status" 2>/dev/null)" || return 1
    print_status "PID $pid ($(cat "/proc/$pid/comm" 2>/dev/null)) $groups"
    echo "$groups" | tr -s '\t ' '\n' | grep -qx "$gid"
}

check_reboot_required() {
    local gid
    local manager_pid
    local client_pid

    print_header "Checking whether a reboot is required"

    gid="$(getent group "$DEFGUARD_GROUP" | cut -d: -f3)"
    if [ -z "$gid" ]; then
        print_error "The $DEFGUARD_GROUP group does not exist, the package installation did not complete"
        exit 1
    fi

    # Desktop apps are started by the user's systemd manager, which keeps the groups it had when
    # it started. It can outlive a logout, which is why a logout and login is not always enough.
    manager_pid="$(pgrep -u "$(id -u)" -x systemd | head -1)"
    client_pid="$(pgrep -u "$(id -u)" -x defguard-client | head -1)"

    if [ -n "$manager_pid" ]; then
        process_has_gid "$manager_pid" "$gid" || REBOOT_REQUIRED=1
    else
        process_has_gid "$$" "$gid" || REBOOT_REQUIRED=1
    fi

    if [ "$REBOOT_REQUIRED" = "1" ]; then
        print_warning "Your session does not carry the $DEFGUARD_GROUP group yet: the client cannot reach $DEFGUARD_SERVICE"
        print_warning "A reboot is required"
    elif [ -n "$client_pid" ] && ! process_has_gid "$client_pid" "$gid"; then
        print_warning "The running Defguard client was started before the group change"
        print_warning "Quit it from its tray icon and launch it again, no reboot needed"
    else
        print_success "No reboot required: your session carries the $DEFGUARD_GROUP group"
    fi
}

ask_reboot() {
    local answer=""

    # No prompt during ./install.sh --all, which runs without questions
    if [ -t 0 ] && [ "${DOTFILES_INSTALL_ALL:-0}" != "1" ]; then
        read -r -p "$(echo -e "${SUBTEXT}Reboot now? [y/N]: ${BASE}")" answer || true
    fi

    case "$answer" in
        [yY]|[yY][eE][sS])
            print_status "Rebooting..."
            sudo systemctl reboot
            ;;
        *)
            print_warning "Reboot before using Defguard (once the installation is over), then run this script again to confirm the group is active"
            ;;
    esac
}

# Main installation process
if [ "$OS_TYPE" = "Darwin" ]; then
    install_macos_client

    print_success "$MODULE_NAME installation completed successfully!"

    # Display next steps
    print_header "Next Steps"
    print_warning "Please complete the following manually:"
    print_warning "1. Launch Defguard from /Applications"
    print_warning "2. Allow its VPN extension and VPN configuration when MacOS asks"
    print_warning "3. Choose 'Add instance' and paste the enrollment URL and token you received ($DEFGUARD_ENROLLMENT_URL)"
    print_warning "4. Connect to your location and enter the MFA code (TOTP or e-mail, as enabled on your account)"
    exit 0
fi

# Check if we have sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges. You may be prompted for your password."
fi

check_dependencies
detect_package

CURRENT_VERSION="$(installed_version)"
if [ "$CURRENT_VERSION" = "$DEFGUARD_VERSION" ]; then
    print_success "Defguard client $DEFGUARD_VERSION is already installed"
elif [ -n "$CURRENT_VERSION" ] && dpkg --compare-versions "$CURRENT_VERSION" gt "$DEFGUARD_VERSION"; then
    print_warning "Defguard client $CURRENT_VERSION is newer than the pinned $DEFGUARD_VERSION, keeping it"
else
    if [ -n "$CURRENT_VERSION" ]; then
        print_status "Upgrading the Defguard client from $CURRENT_VERSION to $DEFGUARD_VERSION"
    fi
    install_client
fi

ensure_group_membership
check_service
check_dns_tooling
check_reboot_required

print_success "$MODULE_NAME installation completed successfully!"

# Display next steps
print_header "Next Steps"
print_warning "Please complete the following manually:"
print_warning "1. Reboot if requested above, then check that 'id' lists the $DEFGUARD_GROUP group"
print_warning "2. Launch Defguard, choose 'Add instance' and paste the enrollment URL and token you received ($DEFGUARD_ENROLLMENT_URL)"
print_warning "3. Connect to your location and enter the MFA code (TOTP or e-mail, as enabled on your account)"
print_warning "4. 'Failed to establish VPN connection' right after a valid code means the session lacks the $DEFGUARD_GROUP group: run this script again"

if [ "$REBOOT_REQUIRED" = "1" ]; then
    ask_reboot
fi
