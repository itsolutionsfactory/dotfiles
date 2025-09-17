#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}Success:${NC} $1"
}

# Function to check if Brave is installed
check_brave() {
    if ! command -v brave >/dev/null 2>&1; then
        print_error "Brave browser is not installed. Please install it first."
        exit 1
    fi
}

# Function to find Brave's profile directory
find_brave_profile_dir() {
    # Get the latest snap revision
    local latest_rev=$(ls -v /home/$USER/snap/brave/ | tail -n 1)
    local profile_dir="/home/$USER/snap/brave/$latest_rev/.config/BraveSoftware/Brave-Browser"
    
    if [ -d "$profile_dir" ]; then
        print_status "Found Brave profile directory at: $profile_dir"
        echo "$profile_dir"
        return 0
    else
        print_error "Could not find Brave profile directory at: $profile_dir"
        return 1
    fi
}

# Function to check if a profile exists
check_profile() {
    local profile_name="$1"
    local profiles_dir="$2"
    local local_state="$profiles_dir/Local State"
    
    print_status "Checking for profile '$profile_name' in $profiles_dir"
    
    if [ ! -f "$local_state" ]; then
        print_warning "Local State file not found at: $local_state"
        return 1
    fi
    
    if grep -q "\"$profile_name\"" "$local_state"; then
        print_status "Found profile '$profile_name'"
        return 0
    else
        print_warning "Profile '$profile_name' not found in Local State"
        return 1
    fi
}

# Function to pre-create profile entry in Local State
pre_create_profile_entry() {
    local profile_name="$1"
    local profiles_dir="$2"
    local local_state="$profiles_dir/Local State"
    
    print_status "Pre-creating profile entry for '$profile_name' in Local State"
    
    # Create a backup of Local State
    if [ -f "$local_state" ]; then
        cp "$local_state" "$local_state.backup"
    fi
    
    # Create a temporary profile entry
    local temp_profile_dir="$profiles_dir/$profile_name"
    mkdir -p "$temp_profile_dir"
    
    # Create basic profile files
    echo '{"profile":{"name":"'$profile_name'","user_name":"'$profile_name'"}}' > "$temp_profile_dir/Preferences"
    
    print_status "Profile entry pre-created for '$profile_name'"
}

# Function to set Qwant as default search engine in Preferences file
set_qwant_in_preferences() {
    local profile_name="$1"
    local profiles_dir="$2"
    local preferences_file="$profiles_dir/$profile_name/Preferences"
    
    print_status "Setting Qwant as default search engine in Preferences for profile '$profile_name'"
    
    # Create backup of existing Preferences file
    if [ -f "$preferences_file" ]; then
        cp "$preferences_file" "$preferences_file.backup"
    fi
    
    # Create or update Preferences file with Qwant as default search engine
    cat > "$preferences_file" << 'EOF'
{
  "profile": {
    "name": "'$profile_name'",
    "user_name": "'$profile_name'"
  },
  "search": {
    "default_search_provider": {
      "enabled": true,
      "search_url": "https://www.qwant.com/?q={searchTerms}&t=web",
      "suggest_url": "https://api.qwant.com/api/suggest/?q={searchTerms}&client=opensearch",
      "keyword": "qwant.com",
      "name": "Qwant",
      "prepopulate_id": 0
    },
    "default_search_provider_encodings": ["UTF-8"],
    "search_provider_overrides": []
  },
  "browser": {
    "window_placement": {
      "maximized": false
    }
  },
  "session": {
    "restore_on_startup": 4
  }
}
EOF
    
    print_status "Qwant search engine configured for profile '$profile_name'"
}

# Function to create a profile and set Qwant as default
create_profile() {
    local profile_name="$1"
    local profiles_dir="$2"
    print_status "Creating profile: $profile_name"
    
    # Pre-create the profile entry
    pre_create_profile_entry "$profile_name" "$profiles_dir"
    
    # Set Qwant as default search engine in Preferences
    set_qwant_in_preferences "$profile_name" "$profiles_dir"
    
    # Launch Brave to initialize the profile
    brave \
        --profile-directory="$profile_name" \
        --no-first-run \
        --no-default-browser-check \
        --disable-background-timer-throttling \
        --disable-backgrounding-occluded-windows \
        --disable-renderer-backgrounding \
        --start-maximized &
    
    # Wait for profile initialization
    sleep 8
    
    # Close the browser more reliably
    pkill -f "brave.*$profile_name" || true
    sleep 2
    
    # Double-check if browser is closed
    if pgrep -f "brave.*$profile_name" > /dev/null; then
        print_warning "Force closing Brave for profile '$profile_name'"
        pkill -9 -f "brave.*$profile_name" || true
    fi
}

# Function to set Qwant as default search engine for existing profile
set_qwant_default() {
    local profile_name="$1"
    local profiles_dir="$2"
    print_status "Setting Qwant as default search engine for profile '$profile_name'"
    
    # Set Qwant as default search engine in Preferences
    set_qwant_in_preferences "$profile_name" "$profiles_dir"
    
    # Launch Brave briefly to apply the changes
    brave \
        --profile-directory="$profile_name" \
        --disable-background-timer-throttling \
        --disable-backgrounding-occluded-windows \
        --disable-renderer-backgrounding &
    
    # Wait for settings to be applied
    sleep 5
    
    # Close the browser more reliably
    pkill -f "brave.*$profile_name" || true
    sleep 2
    
    # Double-check if browser is closed
    if pgrep -f "brave.*$profile_name" > /dev/null; then
        print_warning "Force closing Brave for profile '$profile_name'"
        pkill -9 -f "brave.*$profile_name" || true
    fi
}

# Function to install root CA certificate in a profile
install_root_ca() {
    local profile_name="$1"
    local profiles_dir="$2"
    
    print_status "Installing root CA certificate for profile '$profile_name'"
    
    # Create certificate directory if it doesn't exist
    local cert_dir="$profiles_dir/$profile_name/Certificates"
    mkdir -p "$cert_dir"
    
    # Copy the certificate from the system store
    local cert_file="/usr/local/share/ca-certificates/root-ca.crt"
    if [ ! -f "$cert_file" ]; then
        print_error "Root CA certificate not found at: $cert_file"
        return 1
    fi
    
    # Copy the certificate
    cp "$cert_file" "$cert_dir/root-ca.crt"
    
    # Set proper permissions
    chmod 644 "$cert_dir/root-ca.crt"
    
    print_status "Root CA certificate installed for profile '$profile_name'"
}

# Function to verify Qwant is set as default search engine
verify_qwant_default() {
    local profile_name="$1"
    local profiles_dir="$2"
    local preferences_file="$profiles_dir/$profile_name/Preferences"
    
    print_status "Verifying Qwant is set as default search engine for profile '$profile_name'"
    
    if [ ! -f "$preferences_file" ]; then
        print_error "Preferences file not found for profile '$profile_name'"
        return 1
    fi
    
    # Check if Qwant is set as default search provider
    if grep -q '"name": "Qwant"' "$preferences_file" && \
       grep -q '"search_url": "https://www.qwant.com/?q={searchTerms}&t=web"' "$preferences_file"; then
        print_success "Qwant is properly configured as default search engine for profile '$profile_name'"
        return 0
    else
        print_error "Qwant is not properly configured as default search engine for profile '$profile_name'"
        return 1
    fi
}

# Main script
print_status "Checking Brave browser installation..."
check_brave

# Find Brave profile directory
PROFILE_DIR=$(find_brave_profile_dir)
if [ $? -ne 0 ]; then
    print_error "Failed to find Brave profile directory"
    exit 1
fi

# List of required profiles
PROFILES=("Work" "Chuivert" "COL")

# Check and create each profile
for profile in "${PROFILES[@]}"; do
    if check_profile "$profile" "$PROFILE_DIR"; then
        print_status "Profile '$profile' already exists"
    else
        print_warning "Profile '$profile' not found"
        # Create profile with Qwant as default
        create_profile "$profile" "$PROFILE_DIR"
    fi
    
    # Install root CA certificate
    install_root_ca "$profile" "$PROFILE_DIR"
    
    # Verify Qwant is set as default search engine
    verify_qwant_default "$profile" "$PROFILE_DIR"
    
    echo ""  # Add blank line between profiles
done

print_status "Profile check, search engine configuration, and certificate installation completed!" 
