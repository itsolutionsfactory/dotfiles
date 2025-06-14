#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

set -e


print_status "Testing all configurations..."
for dir in */; do
    if [ -d "$dir" ] && [ "$dir" != ".cursor/" ] && [ -f "${dir}install.sh" ]; then
        print_status "Testing ${dir%/} configuration..."
        cd "$dir"
        ./test.sh
        cd ..
    fi
done

print_status "All tests completed successfully!" 