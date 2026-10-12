# Native LSP Configuration (Neovim 0.11+)

This directory contains LSP server configurations using Neovim 0.11's native LSP
configuration system with `vim.lsp.config()` and `vim.lsp.enable()`.

## What Changed in Neovim 0.11

Neovim 0.11 introduced native LSP configuration APIs that eliminate the need for
`nvim-lspconfig` in many cases:

- `vim.lsp.config()` - Configure LSP servers
- `vim.lsp.enable()` - Enable and start LSP servers
- Automatic loading of configurations from `~/.config/nvim/lsp/` directory

## How It Works

1. **Configuration Files**: Each `.lua` file in this directory corresponds to an
   LSP server
2. **File Naming**: The filename must match the server name used in
   `vim.lsp.enable()`
3. **Auto-loading**: Neovim automatically loads configurations from this
   directory
4. **Global Config**: Common settings are applied via
   `vim.lsp.config("*", { ... })`

## Current LSP Servers

| File                | LSP Server           | Languages                    |
| ------------------- | -------------------- | ---------------------------- |
| `lua_ls.lua`        | Lua Language Server  | Lua                          |
| `rust_analyzer.lua` | rust-analyzer        | Rust                         |
| `bashls.lua`        | bash-language-server | Bash, Shell                  |
| `biome.lua`         | Biome                | JavaScript, TypeScript, JSON |
| `marksman.lua`      | Marksman             | Markdown                     |
| `ruff.lua`          | Ruff                 | Python (linting)             |
| `vuels.lua`         | Vue Language Server  | Vue.js                       |
| `typos_lsp.lua`     | Typos LSP            | Text/Code spell checking     |

## Configuration Structure

Each LSP configuration file should return a table with these common fields:

```lua
return {
	cmd = { "language-server-command" }, -- Command to start the server
	filetypes = { "filetype1", "filetype2" }, -- Supported file types
	root_markers = { -- Files/dirs that indicate project root
		"package.json",
		".git",
	},
	settings = { -- Server-specific settings
		-- Server configuration goes here
	},
}
```

Standalone files are supported by default. Set `workspace_required = true` only
for servers that require a project root. Omit `settings` when no server-specific
settings are needed; Neovim defaults them to an empty table.

## Adding New LSP Servers

1. Create a new `.lua` file named after the LSP server
2. Configure the server settings in the file
3. Add the server name to the `servers` table in `init.lua`
4. Add its installation command to `install.sh`; language servers are installed
   separately from Neovim startup

Example for a new server called `my_server`:

```lua
-- File: lsp/my_server.lua
return {
	cmd = { "my-server", "--stdio" },
	filetypes = { "myfiletype" },
	root_markers = { ".myconfig", ".git" },
	settings = {
		myServer = {
			enable = true,
		},
	},
}
```

Then in `init.lua`, add `"my_server"` to the servers list:

```lua
local servers = {
	"lua_ls",
	"rust_analyzer",
	-- ... other servers ...
	"my_server", -- Add here
}
```

## Benefits of Native LSP Configuration

1. **Simpler**: Less plugin dependencies
2. **Faster**: Native implementation is more performant
3. **Cleaner**: Configurations are isolated in separate files
4. **Maintainable**: Easy to modify individual server settings
5. **Future-proof**: Uses Neovim's built-in LSP system

## Keybindings

LSP keybindings are configured globally via the `LspAttach` autocommand in
`init.lua`:

- `gD` - Go to declaration
- `gd` - Go to definition  
- `gi` - Go to implementation
- `<C-k>` - Signature help
- `<space>D` - Type definition
- `<space>r` - Rename symbol
- `<space>a` - Code actions
- `gr` - Find references
- `<space>e` - Show diagnostics
- `<space>q` - Diagnostics quickfix
- `<space>f` - Format buffer

## Migration Notes

This configuration migrated from `nvim-lspconfig` to native LSP configuration.
The functionality remains the same, but the implementation is now more
streamlined and uses Neovim's built-in capabilities.

If you need to revert to `nvim-lspconfig`, you can:

1. Add `"neovim/nvim-lspconfig"` back to your plugins
2. Replace the native LSP setup with traditional `lspconfig.server.setup()`
   calls
3. Remove this `lsp/` directory
