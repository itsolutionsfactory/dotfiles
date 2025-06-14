#!/bin/bash

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

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    local expected_exit_code=${3:-0}

    print_status "Running test: $test_name"
    if eval "$test_command" > /dev/null 2>&1; then
        if [ $? -eq $expected_exit_code ]; then
            print_status "✓ Test passed: $test_name"
            return 0
        else
            print_error "✗ Test failed: $test_name (unexpected exit code)"
            return 1
        fi
    else
        if [ $? -eq $expected_exit_code ]; then
            print_status "✓ Test passed: $test_name"
            return 0
        else
            print_error "✗ Test failed: $test_name"
            return 1
        fi
    fi
}

# Test kubectl installation
run_test "kubectl installation" "command -v kubectl" || exit 1
run_test "kubectl version" "kubectl version --client" || exit 1

# Test kubelogin installation
run_test "kubelogin installation" "command -v kubelogin" || exit 1
run_test "kubelogin version" "kubelogin version" || exit 1

# Test kubectl configuration
run_test "kubectl config file exists" "test -f ~/.kube/config" || exit 1
run_test "kubectl config is valid" "kubectl config view" || exit 1

# Test kubectl contexts
run_test "kubectl contexts" "kubectl config get-contexts" || exit 1

# Test kubectl completion
run_test "kubectl completion file exists" "test -f ~/.config/kubectl/completion.zsh" || exit 1

# Test kubectl plugins directory
run_test "kubectl plugins directory exists" "test -d ~/.kube/plugins" || exit 1

# Test OIDC configuration
run_test "OIDC configuration" "kubectl config view | grep -q 'oidc-issuer-url'" || exit 1

# Test cluster access
print_status "Testing cluster access..."
if kubectl cluster-info > /dev/null 2>&1; then
    print_status "✓ Successfully connected to cluster"
else
    print_warning "Could not connect to cluster. This might be expected if you're not currently authenticated."
fi

# Test namespace access
print_status "Testing namespace access..."
if kubectl get ns > /dev/null 2>&1; then
    print_status "✓ Successfully accessed namespaces"
else
    print_warning "Could not access namespaces. This might be expected if you're not currently authenticated."
fi

print_status "All tests completed!"
print_status "If you see any warnings about cluster access, make sure you're properly authenticated with your OIDC provider." 