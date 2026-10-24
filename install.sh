#!/usr/bin/env sh
set -eux

# CSS, JS
sudo npm install -g prettier@latest       # formatter
sudo npm install -g @biomejs/biome@latest # formatter, LSP

# Deno
sudo apt install cmake libclang-dev
cargo install deno --locked

# Vue
sudo npm install -g vls@latest # LSP

# Sh
sudo apt install -y shellcheck                  # linter
sudo apt install -y shfmt                       # formatter
sudo npm install -g bash-language-server@latest # LSP, uses shellcheck

# Spelling / Grammar
cargo install --locked --quiet typos-lsp # spell checker LSP
cargo install --locked --quiet harper-ls # grammar LSP

# Markdown
cargo install --locked --quiet comrak # renderer
cargo install --locked --quiet rumdl  # formatter, linter

# Lua
cargo install --locked --quiet stylua # formatter

# Treesitter
sudo apt install -y libclang-dev               # build dependency for tree-sitter-cli
cargo install --locked --quiet tree-sitter-cli # parser compiler used by nvim-treesitter

# Toml
cargo install --locked --quiet taplo-cli # formatter

# `fzf-lua`
cargo install --locked --quiet bat fd-find ripgrep skim

# Sql
cargo install --locked sqruff # formatter

# Rust
rustup component add rust-analyzer
rustup component add rustfmt --toolchain nightly
cargo install --locked topcoat-cli

# Python
uv tool install ruff@latest # linter, formatter and LSP

# Check Homebrew only after the other dependencies have been installed.
if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Error: brew is required to install lua-language-server and marksman and must be on PATH.' >&2
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
brew install lua-language-server marksman
