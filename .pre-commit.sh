#!/usr/bin/env sh

set -eu

# Let Git locate shared worktree hooks and honor core.hooksPath.
hook_path=$(git rev-parse --git-path hooks/pre-commit)

# Installation is optional: skip noninteractive prompts and treat EOF as "no".
if [ -t 0 ] && ! [ "$hook_path" -ef "$0" ]; then
    printf "Link this script as the git pre-commit hook to avoid further manual running? (y/N): "
    read -r link_hook || link_hook=n
    case "$link_hook" in
    [Yy])
        mkdir -p "$(dirname "$hook_path")"
        ln -sf "$(realpath "$0")" "$hook_path"
        ;;
    esac
fi

set -x

# Install tools
rumdl --version >/dev/null 2>&1 || cargo install --locked rumdl
typos --version >/dev/null 2>&1 || cargo install --locked typos-cli

# Lints
typos .
rumdl check . || { set +x && printf "Run:\nrumdl fmt .\n" && exit 1; }

# Tests
vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/open_todo.lua
# Check native LSP defaults and both SQL injection string forms.
vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/lsp_defaults.lua
vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/sql_injections.lua
# Check first-run theme watching and recovery from invalid theme edits.
vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/theme.lua

# Health
vim --appimage-extract-and-run --headless -c checkhealth -c quit
