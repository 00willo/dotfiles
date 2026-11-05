#!/usr/bin/env bash
# Run: bash install.sh [--example personal-macbook|personal-fedora-workstation]
set -euo pipefail

example=""
if [[ $# -gt 0 ]]; then
    if [[ $# -ne 2 || "$1" != "--example" ]]; then
        echo "Usage: bash install.sh [--example personal-macbook|personal-fedora-workstation]" >&2
        exit 2
    fi
    case "$2" in
        personal-macbook|personal-fedora-workstation) example="$2" ;;
        *) echo "Unknown machine example: $2" >&2; exit 2 ;;
    esac
fi
repo="${DOTFILES_REPO:-https://github.com/00willo/dotfiles.git}"
export PATH="$HOME/.local/bin:$PATH"

case "$(uname -s)" in
    Darwin)
        if ! xcode-select -p >/dev/null 2>&1; then
            xcode-select --install
            echo "Finish installing Xcode Command Line Tools, then run this script again."
            exit 1
        fi
        if ! command -v brew >/dev/null 2>&1; then
            if [[ -x /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -x /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            else
                installer=$(mktemp)
                curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
                /bin/bash "$installer"
                rm -f "$installer"
                if [[ -x /opt/homebrew/bin/brew ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
        fi
        command -v chezmoi >/dev/null 2>&1 || brew install chezmoi
        ;;
    Linux)
        for prerequisite in curl git; do
            if ! command -v "$prerequisite" >/dev/null 2>&1; then
                echo "Install $prerequisite with your distribution's package manager, then rerun." >&2
                exit 1
            fi
        done
        if ! command -v chezmoi >/dev/null 2>&1; then
            installer=$(mktemp)
            curl -fsSL https://get.chezmoi.io -o "$installer"
            sh "$installer" -b "$HOME/.local/bin"
            rm -f "$installer"
        fi
        ;;
    *) echo "Supported systems: macOS and Linux." >&2; exit 1 ;;
esac

# HTTPS works without an SSH key; private mirrors can override DOTFILES_REPO.
chezmoi init "$repo"
if [[ -n "$example" ]]; then
    source_dir=$(chezmoi source-path)
    config_file=$(chezmoi execute-template '{{ .chezmoi.configFile }}')
    example_file="$source_dir/examples/machines/$example.toml"
    if [[ ! -f "$example_file" ]]; then
        echo "Example not found in the selected repository: $example_file" >&2
        exit 1
    fi
    if [[ -e "$config_file" ]]; then
        echo "Config already exists: $config_file" >&2
        echo "Review $example_file and merge selections into the existing config; then run chezmoi diff and chezmoi apply." >&2
        exit 1
    fi
    mkdir -p "$(dirname "$config_file")"
    (set -o noclobber; cat "$example_file" > "$config_file")
    echo "Created $config_file. Review and edit it, then run chezmoi diff and chezmoi apply."
    exit 0
fi
chezmoi apply
