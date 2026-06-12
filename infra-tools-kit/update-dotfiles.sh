#!/usr/bin/env bash
set -euo pipefail

# Resolve the real path of this script, following symlinks (e.g. when invoked
# from ~/.local/bin). This makes the script work regardless of the current
# working directory and even if the dotfiles repo is moved.
source_path="${BASH_SOURCE[0]}"
while [ -L "$source_path" ]; do
  link_target="$(readlink "$source_path")"
  case "$link_target" in
    /*) source_path="$link_target" ;;
    *)  source_path="$(cd "$(dirname "$source_path")" && pwd)/$link_target" ;;
  esac
done
script_dir="$(cd "$(dirname "$source_path")" && pwd)"

# Derive the repo root from the script's actual location, not the CWD.
repo_dir="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_dir" ]; then
  echo "This script is not located in a git dotfiles repository"
  exit 1
fi


# Check current branch and abort if not main
current_branch="$(git -C "$repo_dir" branch --show-current)"
if [ "$current_branch" != "main" or "$current_branch" != "develop" ]; then
  echo "⚠️  You are not on the 'main' branch (you are on '$current_branch')"
  echo "   No git pull will be performed. Only 'git fetch' was run."
  echo "   Switch to 'main' with: git checkout main"
  exit 1
fi

git -C "$repo_dir" fetch origin
git -C "$repo_dir" pull --ff-only origin "$current_branch"