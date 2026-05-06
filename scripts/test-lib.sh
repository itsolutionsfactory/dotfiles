#!/bin/bash

# Shared helpers for portable module tests.

resolve_path_portable() {
    local path="$1"
    local target

    if [ -L "$path" ]; then
        target="$(readlink "$path")"
        case "$target" in
            /*) path="$target" ;;
            *) path="$(dirname "$path")/$target" ;;
        esac
    fi

    (
        cd "$(dirname "$path")"
        printf "%s/%s\n" "$(pwd -P)" "$(basename "$path")"
    )
}

test_stow_link_portable() {
    local target="$1"
    local source="$2"

    print_status "Testing stow link: $target"

    if [ ! -L "$target" ]; then
        print_error "$target is not a symbolic link"
        return 1
    fi

    local abs_source
    local abs_target
    abs_source="$(resolve_path_portable "$source")"
    abs_target="$(resolve_path_portable "$target")"

    if [ "$abs_target" = "$abs_source" ]; then
        print_success "$target is properly linked by stow"
        return 0
    fi

    print_error "$target is not properly linked by stow"
    print_error "Expected: $abs_source"
    print_error "Got: $abs_target"
    return 1
}
