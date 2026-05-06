#!/bin/bash

# Exit on error
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

BASE="\033[0m"
RED="\033[38;2;243;139;168m"
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
BLUE="\033[38;2;137;180;250m"
MAUVE="\033[38;2;203;166;247m"

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

test_file_exists() {
    local file="$1"

    if [ -f "$file" ]; then
        print_success "File exists: $file"
    else
        print_error "Missing file: $file"
        return 1
    fi
}

test_bash_syntax() {
    local file="$1"
    print_status "Checking bash syntax: $file"
    bash -n "$file"
    print_success "Bash syntax is valid: $file"
}

test_module_layout() {
    local module="$1"
    local module_dir="$SCRIPT_DIR/$module"

    test_file_exists "$module_dir/install.sh"

    case "$module" in
        zsh|nvm)
            test_file_exists "$module_dir/.stow-local-ignore"
            ;;
        *)
            if [ -d "$module_dir/.config" ]; then
                print_success "$module has a .config layout"
            else
                print_warning "$module does not use .config directly"
            fi
            ;;
    esac
}

stow_for_test() {
    local test_home="$1"
    local module="$2"
    local target="$3"
    local package="${4:-.}"

    print_status "Stowing $module into test home"
    (
        cd "$SCRIPT_DIR/$module"
        stow -t "$target" "$package"
    )
}

run_portable_module_test() {
    local test_home="$1"
    local module="$2"

    print_status "Running portable module test: $module"
    (
        export HOME="$test_home"
        export DOTFILES_TEST_MODE=1
        cd "$SCRIPT_DIR/$module"
        bash ./test.sh
    )
}

print_header "Testing MacOS dotfiles support"

test_file_exists "$SCRIPT_DIR/install.sh"
test_file_exists "$SCRIPT_DIR/install_macos.sh"
test_file_exists "$SCRIPT_DIR/install_ubuntu.sh"
test_file_exists "$BREWFILE"

test_bash_syntax "$SCRIPT_DIR/install.sh"
test_bash_syntax "$SCRIPT_DIR/install_macos.sh"
test_bash_syntax "$SCRIPT_DIR/install_ubuntu.sh"

for module in zsh hyfetch vim kitty kubectl github-cli gitlab-cli nvm; do
    test_module_layout "$module"
    test_bash_syntax "$SCRIPT_DIR/$module/install.sh"
done

if command_exists ruby; then
    print_status "Checking Brewfile Ruby syntax..."
    ruby -c "$BREWFILE" >/dev/null
    print_success "Brewfile syntax is valid"
else
    print_warning "Ruby is not available; skipping Brewfile syntax check"
fi

if [ "$(uname -s)" = "Darwin" ] && command_exists brew; then
    print_status "Checking Homebrew bundle state..."
    if brew bundle check --file="$BREWFILE"; then
        print_success "Homebrew bundle is already satisfied"
    else
        print_warning "Homebrew bundle is valid but not fully installed yet"
        print_warning "Run './install.sh --all' on MacOS to install missing packages"
    fi
else
    print_warning "Not running on MacOS with Homebrew; skipping brew bundle check"
fi

print_header "Running portable module tests"
TEST_HOME="$(mktemp -d)"
mkdir -p "$TEST_HOME/.config"

stow_for_test "$TEST_HOME" zsh "$TEST_HOME"
stow_for_test "$TEST_HOME" nvm "$TEST_HOME"
stow_for_test "$TEST_HOME" hyfetch "$TEST_HOME/.config" ".config"
stow_for_test "$TEST_HOME" vim "$TEST_HOME/.config" ".config"
stow_for_test "$TEST_HOME" kitty "$TEST_HOME/.config" ".config"
stow_for_test "$TEST_HOME" kubectl "$TEST_HOME/.config" ".config"
stow_for_test "$TEST_HOME" kubectl "$TEST_HOME"
stow_for_test "$TEST_HOME" github-cli "$TEST_HOME/.config" ".config"
stow_for_test "$TEST_HOME" gitlab-cli "$TEST_HOME/.config" ".config"

for module in zsh nvm hyfetch vim kitty kubectl github-cli gitlab-cli; do
    run_portable_module_test "$TEST_HOME" "$module"
done

print_success "MacOS validation completed"
