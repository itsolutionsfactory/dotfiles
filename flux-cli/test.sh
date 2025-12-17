#!/bin/bash

# Exit on error
set -e

# Script directory and module info
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_NAME="flux"

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

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Testing: $test_name"
    
    if eval "$test_command"; then
        print_success "PASSED: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "FAILED: $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Main test suite
main() {
    print_header "Running Flux CLI Tests"
    
    # Test 1: Check if flux is installed
    run_test "Flux CLI is installed" "command -v flux &> /dev/null"
    
    # Test 2: Check flux version
    run_test "Flux version command works" "flux version --client &> /dev/null"
    
    # Test 3: Check flux help
    run_test "Flux help command works" "flux --help &> /dev/null"
    
    # Test 4: Check flux check (pre-flight checks)
    print_status "Testing: Flux check command (may fail if no cluster is configured)"
    if flux check &> /dev/null; then
        print_success "PASSED: Flux check command (cluster configured)"
        ((TESTS_PASSED++))
    else
        print_warning "WARNING: Flux check failed (expected if no cluster is configured)"
        print_status "This is normal if you don't have a Kubernetes cluster configured"
    fi
    
    # Test 5: Verify flux binary location
    run_test "Flux is in PATH" "[ -x \$(which flux) ]"
    
    # Test 6: Check ZSH completion (if Oh My ZSH is installed)
    if [ -d "$HOME/.oh-my-zsh" ]; then
        local completion_file="$HOME/.oh-my-zsh/custom/completions/_flux"
        run_test "Flux ZSH completion is installed" "[ -f \"$completion_file\" ]"
    else
        print_status "Skipping ZSH completion test (Oh My ZSH not detected)"
    fi
    
    # Test 7: Display flux version info
    print_header "Flux Version Information"
    flux version --client
    
    # Test 8: List available flux commands
    print_header "Available Flux Commands"
    flux --help | grep -A 100 "Available Commands:" | head -20
    
    # Summary
    print_header "Test Summary"
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${BASE}"
    echo -e "${RED}Tests Failed: $TESTS_FAILED${BASE}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_success "All tests passed!"
        exit 0
    else
        print_error "Some tests failed!"
        exit 1
    fi
}

# Run tests
main "$@"
