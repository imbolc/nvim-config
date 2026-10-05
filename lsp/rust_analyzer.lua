local function on_attach(client, bufnr)
	-- Without this rust-analyzer rewrites Treesitter queries from ./after/queries/rust/injections.scm
	client.server_capabilities.semanticTokensProvider = nil
end

return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = {
		"Cargo.toml",
		"rust-project.json",
		".git",
	},
	on_attach = on_attach,
	flags = {
		debounce_text_changes = 150,
	},
	settings = {
		["rust-analyzer"] = {
			-- Prevent completions from inserting call parentheses so selecting a function name keeps it as-is.
			completion = {
				addCallParenthesis = false,
				addCallArgumentSnippets = false,
			},
			cargo = {
				-- It would enable "ci" feature
				-- allFeatures = true,
			},
			rustfmt = {
				-- Use rustfmt directly for Rust 2024 formatting in LSP requests.
				overrideCommand = { "rustfmt", "--edition", "2024", "--emit", "stdout" },
			},
		},
	},
}
