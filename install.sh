#!/usr/bin/env sh
set -eux

# CSS, JS
sudo npm install -g prettier@latest yaml-unist-parser@latest # formatter
sudo npm install -g @biomejs/biome@latest                    # formatter, LSP

sudo apt install cmake
cargo install deno --locked

# Vue
sudo npm install -g vls@latest # LSP

# Sh
sudo apt install -y shellcheck                  # linter
sudo apt install -y shfmt                       # formatter
sudo npm install -g bash-language-server@latest # LSP, uses shellcheck

# Spelling / Grammar
cargo install --locked --quiet typos-cli # LSP
cargo install --locked --quiet harper-ls # LSP

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

# Python
pipx install ruff # linter, formatter and LSP

# `fzf-lua`
cargo install --locked --quiet bat fd-find ripgrep skim

# Sql
cargo install --locked sleek # formatter

# Rust
rustup component add rust-analyzer
rustup component add rustfmt --toolchain nightly
cargo install --locked topcoat-cli
