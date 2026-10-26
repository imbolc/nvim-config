return {
	cmd = { "harper-ls", "--stdio" },
	-- Harper cannot parse CSS, YAML, JSON, or Vimscript, so keep it detached from those buffers.
	filetypes = {
		"markdown",
		"text",
		"gitcommit",
		"html",
		"javascript",
		"typescript",
		"lua",
		"python",
		"rust",
		"go",
		"java",
		"c",
		"cpp",
		"toml",
		"sh",
		"bash",
	},
	-- Translate Neovim's shell filetypes so Harper can parse and check their comments.
	get_language_id = function(_, filetype)
		return (filetype == "sh" or filetype == "bash") and "shellscript" or filetype
	end,
	root_markers = {
		".harper.toml",
		".harper.json",
		"harper.toml",
		"harper.json",
		".git",
		"package.json",
		"Cargo.toml",
		"pyproject.toml",
	},
	settings = {
		["harper-ls"] = {
			userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
			linters = {
				SentenceCapitalization = false,
				-- Allow sentence case in headings without Harper suggesting title case.
				UseTitleCase = false,
			},
			codeActions = {
				ForceStable = true,
			},
		},
	},
}
