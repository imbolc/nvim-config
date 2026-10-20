-- Install dependencies: ./install.sh
require("vim._core.ui2").enable()

vim.g.mapleader = " "

vim.opt.mouse = ""

vim.opt.autowrite = true -- automatically :write before running a commands
vim.opt.spell = true
vim.opt.spelllang = "en,ru"

-- Backup
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "no" -- do dot display sign column to have more horizontal space

-- Folding
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false -- Don't fold everything on open
vim.opt.foldlevel = 99 -- Start with all folds open

vim.api.nvim_command("autocmd ColorScheme * highlight VertSplit guibg=bg guifg=white")

-- Wrapping
vim.opt.wrap = false -- disable soft wrapping at the edge of the screen
vim.opt.linebreak = true -- do not wrap in the middle of a word when soft wrapping is enabled
vim.opt.breakindent = true -- preserve indentation of softly wrapped lines
-- move through softly wrapped lines more naturally
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Search / substitute
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split" -- preview substitutions
vim.opt.gdefault = true

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Decrease update time
vim.opt.updatetime = 100

-- Don't lose selection when shifting blocks
vim.keymap.set("x", "<", "<gv", { silent = true })
vim.keymap.set("x", ">", ">gv", { silent = true })

-- Ignore Ctrl+Space and its Ctrl+@ encoding so accidental presses do not repeat text or leave Insert mode.
vim.keymap.set("i", "<C-Space>", "<Nop>", { silent = true })
vim.keymap.set("i", "<C-@>", "<Nop>", { silent = true })

-- Let native autocomplete open completion menus while typing so this config does not need a custom TextChangedI trigger.
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
vim.opt.autocomplete = true

-- Feed filesystem paths into native autocomplete because built-in file completion only runs after <C-x><C-f>.
function FilePathComplete(findstart, base)
	if findstart == 1 then
		-- Start completion only inside slash/tilde path tokens so normal dot completion stays with LSP.
		local line = vim.fn.getline(".")
		local col = vim.fn.col(".") - 1
		local before_cursor = line:sub(1, col)
		local start = before_cursor:find("[^%s\"'`()%[%]{}<>]*[/~][^%s\"'`()%[%]{}<>]*$")
		return start and start - 1 or -3
	end

	-- Split the typed path so suggestions scan one directory and replace the whole path token.
	local dir_prefix, file_prefix = base:match("^(.*[/\\])([^/\\]*)$")
	if not dir_prefix then
		dir_prefix = "~/"
		file_prefix = ""
	end

	-- Expand the typed directory prefix for scanning while keeping the inserted completion text as typed.
	local scan_dir = vim.fn.expand(dir_prefix)
	local ok, iterator = pcall(vim.fs.dir, scan_dir)
	if not ok then
		return { words = {}, refresh = "always" }
	end

	-- Return matching directory entries as completion items and mark them so Tab can navigate path popups.
	local matches = {}
	for name, type in iterator do
		if vim.startswith(name, file_prefix) then
			local is_dir = type == "directory"
			local suffix = is_dir and "/" or ""
			table.insert(matches, {
				word = dir_prefix .. name .. suffix,
				abbr = name .. suffix,
				kind = is_dir and "d" or "f",
				menu = "[path]",
				user_data = "filepath",
			})
		end
	end

	-- Sort directories first so path traversal stays predictable in the completion menu.
	table.sort(matches, function(a, b)
		if a.kind ~= b.kind then
			return a.kind == "d"
		end
		return a.word < b.word
	end)

	return { words = matches, refresh = "always" }
end

-- Neovim deduplicates completion sources, so re-sourcing keeps a single path source.
vim.opt.complete:append("Fv:lua.FilePathComplete")

-- Enable built-in LSP completion on attach so native completion and manual omni-complete can use server results.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
			})
		end
	end,
})

-- Keep context-sensitive Tab completion; expression mappings expand the returned keycodes.
vim.keymap.set("i", "<Tab>", function()
	local completion = vim.fn.complete_info({ "mode", "pum_visible", "items" })
	local col = vim.fn.col(".") - 1
	local line = vim.fn.getline(".")
	local before_cursor = line:sub(1, col)

	-- Detect path-source popups so Tab navigates them instead of restarting file completion.
	local has_path_items = false
	for _, item in ipairs(completion.items or {}) do
		if item.user_data == "filepath" then
			has_path_items = true
			break
		end
	end

	-- Prefer file completion for path-like tokens and select its first item so global `noselect` does not hide Tab's result.
	local is_path_context = before_cursor:match("%S*[/.~]%S*$") ~= nil
	if is_path_context and completion.mode ~= "files" and not has_path_items then
		local close_popup = completion.pum_visible == 1 and "<C-e>" or ""
		return close_popup .. "<C-x><C-f><C-n>"
	end

	if completion.pum_visible == 1 then
		return "<C-n>"
	end
	if col == 0 or line:sub(col, col):match("%s") then
		return "<Tab>"
	else
		return "<C-x><C-o>"
	end
end, { expr = true, silent = true })
vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, silent = true })

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", { silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", { silent = true })

-- disable ex mode
vim.keymap.set("n", "Q", "<nop>", { silent = true })
vim.keymap.set("n", "q:", "<nop>", { silent = true })

-- Switching between tabs by <tab> / <shift-tab>
vim.keymap.set("n", "<tab>", "gt", { silent = true })
vim.keymap.set("n", "<s-tab>", "gT", { silent = true })

-- Copy selection to the system clipboard
vim.keymap.set({ "v" }, "<leader>y", '"+y', { silent = true })

-- Copy the current buffer's full path into the primary selection (*) register
vim.keymap.set("n", "<leader>yf", function()
	-- Skip unnamed buffers so we don't yank empty paths.
	local path = vim.fn.expand("%:.")
	if path == "" then
		return
	end
	vim.fn.setreg("+", path)
	vim.notify(string.format("Copied: %s", path))
end, { silent = true })

-- Configure a notes-only keymap that copies a GitHub link for the current note.
local NOTES_ROOT = vim.fn.expand("~/proj/notes")
-- Use an autocmd to attach the mapping only for buffers inside the notes folder.
local notes_link_augroup = vim.api.nvim_create_augroup("notes-link", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = notes_link_augroup,
	callback = function()
		-- Avoid redefining the mapping when the same buffer is revisited.
		if vim.b.notes_link_mapped then
			return
		end
		-- Only set the mapping when the current buffer is within the notes root.
		local path = vim.fn.expand("%:p")
		if path == "" then
			return
		end
		if path ~= NOTES_ROOT and not vim.startswith(path, NOTES_ROOT .. "/") then
			return
		end

		-- Mark the buffer so we only set the mapping once per notes buffer.
		vim.b.notes_link_mapped = true

		vim.keymap.set("n", "<leader>yl", function()
			-- Build and copy the notes URL relative to the notes root.
			local note_path = vim.fn.expand("%:p")
			if note_path == "" then
				return
			end
			local rel_path = note_path:sub(#NOTES_ROOT + 2)
			local url = string.format("https://github.com/imbolc/notes/tree/main/%s", rel_path)
			vim.fn.setreg("+", url)
			vim.notify(string.format("Copied: %s", url))
		end, { silent = true, buffer = 0, desc = "Copy Notes Link" })
	end,
})

-- Show status line only if there are at least two windows
vim.opt.laststatus = 1

-- Hide command line until typing a command or recording a script
vim.opt.cmdheight = 0
vim.cmd("autocmd RecordingEnter * set cmdheight=1")
vim.cmd("autocmd RecordingLeave * set cmdheight=0")

-- Use Neovim's xclip provider for clipboard and primary-selection registers.
vim.g.clipboard = "xclip"

-- Templates
local templates_augroup = vim.api.nvim_create_augroup("templates", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
	group = templates_augroup,
	pattern = "*.sh",
	desc = "Load skeleton for shell scripts",
	command = "0r ~/.config/nvim/templates/skeleton.sh",
})

--------------------------------
-- File type related settings --
--------------------------------
-- Treat `.env.local` files as shell scripts so they get sh highlighting/completion in this setup.
vim.filetype.add({
	filename = {
		[".env.local"] = "sh",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.bo.commentstring = "-- %s"
		-- Use <leader>x for run commands to keep <leader>r for LSP rename.
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<leader>x",
			':silent w | !db="sandbox_$$" && createdb "$db" && psql -v ON_ERROR_STOP=1 -d "$db" -f %:S; rc=$?; dropdb --force "$db"; exit "$rc"<CR>',
			{ noremap = true, silent = true }
		)
	end,
})
vim.cmd([[au FileType lua map <buffer> <leader>x :w\| :source  %<cr>]])
vim.cmd([[au FileType rust map <buffer> <leader>x :w\|! DATABASE_URL=postgres:/// rust-script %<cr>]])
vim.cmd([[au FileType sh map <buffer> <leader>x :w\|!sh %<cr>]])
vim.cmd([[au FileType python map <buffer> <leader>x :w\|!python3 %<cr>]])
vim.cmd([[au FileType html map <buffer> <leader>x :w\|!open %<cr>]])
vim.cmd([[au FileType javascript map <buffer> <leader>x :w\|!node %<cr>]])
vim.cmd([[
    " au FileType markdown setlocal wrap
    au FileType markdown setlocal spell
    au FileType markdown setlocal conceallevel=0
    au FileType markdown map <buffer> <leader>x :w\|!comrak --unsafe -e table -e footnotes % > /tmp/vim.md.html && xdg-open /tmp/vim.md.html<cr>
]])
vim.cmd([[
    au FileType yaml setlocal wrap
    au FileType yaml setlocal spell
]])
vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Force commentstring to include spaces",
	callback = function(event)
		local cs = vim.bo[event.buf].commentstring
		vim.bo[event.buf].commentstring = cs:gsub("(%S)%%s", "%1 %%s"):gsub("%%s(%S)", "%%s %1")
	end,
})

--- Opens the centralized project TODO, or searches local TODO/README files outside ~/proj projects.
---
--- @param in_split boolean  If true, open file in a vsplit; otherwise, open in current window.
--- @param or_readme boolean  If true, also consider README.md outside ~/proj projects.
--- @param show_errors boolean  If true, notify user if no file is found outside ~/proj projects.
function OpenTodo(in_split, or_readme, show_errors)
	-- Share one todo path across a project's subfolders, opening a new buffer when the file is missing.
	local projects_dir = vim.fn.expand("~/proj/")
	local project = vim.fn.getcwd():match("^" .. vim.pesc(projects_dir) .. "([^/]+)")
	if project then
		-- Keep clone instructions visible and copyable in a read-only scratch buffer until the directory exists.
		if vim.fn.isdirectory(projects_dir .. "todo") == 0 then
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
				"# Error: todo folder is missing",
				"",
				"`~/proj/todo` folder is missing. Clone it with:",
				"",
				"```sh",
				"git clone git@github.com:imbolc/todo.git ~/proj/todo",
				"```",
			})
			vim.bo[bufnr].bufhidden = "wipe"
			vim.bo[bufnr].readonly = true
			vim.bo[bufnr].modifiable = false
			if in_split then
				vim.cmd.vsplit()
			end
			vim.api.nvim_win_set_buf(0, bufnr)
			-- Apply Markdown window settings to the displayed instructions.
			vim.bo[bufnr].filetype = "markdown"
			return
		end
		local filename = projects_dir .. "todo/" .. project .. ".md"
		vim.cmd((in_split and "vsplit" or "edit") .. " " .. vim.fn.fnameescape(filename))
		-- Seed missing todo files with a heading while preserving edits in an unsaved buffer.
		if vim.fn.getftype(filename) == "" and not vim.bo.modified then
			vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. project .. " todo" })
		end
		return
	end

	local possible_files = {
		".todo",
		".todo.txt",
		".todo.md",
		"todo.txt",
		"todo.md",
		"TODO.txt",
		"TODO.md",
		"var/todo.txt",
		"var/todo.md",
	}
	if or_readme then
		table.insert(possible_files, "README.md")
	end

	for _, filename in ipairs(possible_files) do
		-- vim.print(filename)
		if vim.fn.filereadable(filename) == 1 then
			vim.cmd((in_split and "vsplit" or "edit") .. " " .. filename)
			return
		end
	end

	if show_errors then
		vim.notify("No TODO file found\n", vim.log.levels.ERROR)
	end
end

vim.keymap.set("n", "<leader>t", "<cmd>lua OpenTodo(true, false, true)<cr>", { silent = true })
vim.keymap.set("n", "<leader>T", "<cmd>vs ~/Documents/todo.md<cr>", { silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.defer_fn(function()
				OpenTodo(false, true, false)
			end, 0)
		end
	end,
})

-------------
-- Plugins --
-------------
local plugins = {
	{ src = "https://github.com/dhruvasagar/vim-table-mode" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/junegunn/vim-slash" }, -- Automatically remove search selection.
	{ src = "https://github.com/mechatroner/rainbow_csv" },
	{ src = "https://github.com/nativerv/cyrillic.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/saecki/crates.nvim" },
	{ src = "https://github.com/sainnhe/everforest" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
}

-- Respect --noplugin by skipping package installation, loading, and plugin-specific setup when plugin loading is disabled.
local plugin_loading_enabled = vim.o.loadplugins

-- Keep event-loaded packages out of the eager vim.pack loader so their startup cost stays deferred.
local deferred_plugins = {
	["crates.nvim"] = true,
	["cyrillic.nvim"] = true,
}

if plugin_loading_enabled then
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			-- Keep installed parsers compatible when nvim-treesitter is installed or updated.
			local name, kind = ev.data.spec.name, ev.data.kind
			if name ~= "nvim-treesitter" or (kind ~= "install" and kind ~= "update") then
				return
			end

			vim.schedule(function()
				if pcall(vim.cmd, "packadd nvim-treesitter") then
					pcall(vim.cmd, "TSUpdate")
				end
			end)
		end,
	})

	-- Install missing plugins without a prompt and load eager plugins for the setup below.
	vim.pack.add(plugins, {
		confirm = false,
		load = function(plugin)
			-- Let explicit autocmds below load deferred packages only when their old Lazy events would have run.
			if deferred_plugins[plugin.spec.name] then
				return
			end

			-- Load every other native package immediately so explicit setup calls below can require plugin modules.
			vim.cmd.packadd(plugin.spec.name)
		end,
	})

	-- Load the configured colorscheme after vim.pack makes the theme package available.
	vim.cmd([[colorscheme everforest]])

	-- Load and watch the persisted theme after colorscheme packages are available.
	local theme_file = vim.fn.expand("~/.config/nvim/theme.lua")
	if vim.fn.filereadable(theme_file) == 0 then
		-- Create the file before watching it so changes also work on a fresh installation.
		vim.fn.writefile({}, theme_file, "a")
	end
	local function load_theme()
		-- Report invalid theme edits without breaking startup or later reloads.
		local ok, err_msg = pcall(dofile, theme_file)
		if not ok then
			vim.notify("Error loading theme file: " .. err_msg, vim.log.levels.ERROR)
		end
	end
	local theme_watcher = assert(vim.uv.new_fs_event())
	local ok, err = theme_watcher:start(
		theme_file,
		{},
		vim.schedule_wrap(function(watch_err, _, events)
			if watch_err then
				vim.notify("Error watching theme file: " .. watch_err, vim.log.levels.ERROR)
				theme_watcher:stop()
			elseif events.change then
				load_theme()
			end
		end)
	)
	if not ok then
		vim.notify("Error watching theme file: " .. err, vim.log.levels.ERROR)
	end
	vim.api.nvim_create_autocmd("VimLeavePre", {
		once = true,
		callback = function()
			-- Closing the watcher releases its handle and stops notifications on exit.
			theme_watcher:close()
		end,
	})
	load_theme()

	-- Configure table-mode's Markdown-compatible corner character before the plugin creates tables.
	vim.g.table_mode_corner = "|"

	-- Configure crates.nvim only on the first Cargo.toml read.
	vim.api.nvim_create_autocmd("BufRead", {
		pattern = "Cargo.toml",
		once = true,
		callback = function()
			-- Load and configure crates.nvim when a Cargo manifest opens, preserving the previous Lazy BufRead event.
			vim.cmd.packadd("crates.nvim")
			require("crates").setup()
		end,
	})

	-- Configure Oil as the directory editor and expose the existing project drawer keymap.
	require("oil").setup({
		view_options = {
			show_hidden = true,
		},
	})
	vim.keymap.set("n", "<leader>d", ":Oil --preview<cr>", { silent = true })

	-- Configure Conform as the external formatter orchestrator for project filetypes.
	require("conform").setup({
		formatters_by_ft = {
			css = { "biome" },
			html = { "global_prettier" },
			javascript = { "biome", "biome-organize-imports" },
			json = { "biome" },
			jsonc = { "biome" },
			json5 = { "global_prettier" },
			lua = { "stylua" },
			-- Format Markdown with rumdl and keep Conform responsible for fenced code.
			markdown = function(bufnr)
				-- Skip injected formatting when markdown contains rust,ignore fenced blocks so Conform does not modify or drop ignored Rust examples.
				for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
					if line:match("^```%s*rust%s*,%s*ignore[%w_,%-]*%s*$") then
						return { "rumdl" }
					end
				end
				-- Format fenced code before prose reflow changes its line positions.
				return { "injected", "rumdl" }
			end,
			python = { "ruff_format", "ruff_organize_imports" },
			-- rust `injected` breaks Maud templates.
			-- rust = { "rustfmt_nightly", "injected" },
			-- Format Rust normally before formatting Topcoat macros in opted-in projects.
			rust = { "rustfmt_nightly", "topcoat" },
			sh = { "shfmt" },
			-- sql = { "sleek" },
			toml = { "taplo" },
			vue = { "global_prettier" },
			yaml = { "global_prettier" },
		},
		formatters = {
			global_prettier = {
				command = "/usr/bin/nodejs",
				args = { "/usr/local/bin/prettier", "--stdin-filepath", "$FILENAME" },
				stdin = true,
			},
			taplo = {
				-- Mirror the buffer's effective indent settings so TOML format-on-save keeps following Neovim's .editorconfig values.
				args = function(_, ctx)
					-- Fall back to tabstop when shiftwidth is zero so Taplo still receives a concrete indentation width.
					local indent_width = ctx.shiftwidth > 0 and ctx.shiftwidth or vim.bo[ctx.buf].tabstop
					-- Build Taplo's indent string from the current buffer options so tabs and spaces both stay in sync with .editorconfig.
					local indent_string = vim.bo[ctx.buf].expandtab and string.rep(" ", indent_width) or "\t"
					return {
						"format",
						"--stdin-filepath",
						ctx.filename,
						"--option",
						"indent_string=" .. indent_string,
						"-",
					}
				end,
				stdin = true,
			},
			rustfmt_nightly = {
				-- Use nightly rustfmt directly for normal Rust formatting in buffers and Markdown code fences.
				command = "rustup",
				args = { "run", "nightly", "rustfmt", "--emit", "stdout" },
				stdin = true,
			},
			topcoat = {
				-- Format macro bodies only in projects with a Topcoat.toml marker, after rustfmt has formatted the Rust code.
				command = "topcoat",
				args = { "fmt", "--stdin" },
				stdin = true,
				cwd = require("conform.util").root_file({ "Topcoat.toml" }),
				require_cwd = true,
			},
			rumdl = {
				-- Emit only formatted Markdown; Conform already passes the buffer filename for config discovery.
				append_args = { "--silent" },
			},
			-- sleek = {
			-- 	command = "sleek",
			-- 	stdin = true,
			-- },
		},
		format_on_save = {
			-- Allow time for Markdown and injected code formatters to finish before saving.
			timeout_ms = 3000,
			lsp_fallback = true,
		},
	})

	-- Reuse formatters_by_ft for injected code while ignoring snippet formatting errors.
	require("conform").formatters.injected = {
		options = {
			ignore_errors = true,
		},
	}

	local treesitter = require("nvim-treesitter")

	-- Install parsers into Neovim's site directory so parser binaries are runtime data instead of files inside the plugin checkout.
	treesitter.setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	-- Share the supported filetypes so parser installation and highlighting stay in sync.
	local treesitter_filetypes = {
		"css",
		"html",
		"javascript",
		"json",
		"json5",
		"jsonc",
		"lua",
		"markdown",
		"python",
		"query",
		"rust",
		"scss",
		"sh",
		"sql",
		"svelte",
		"toml",
		"typescript",
		"vue",
		"yaml",
	}

	-- Resolve aliases such as sh to bash and jsonc to json before installing parsers and their dependencies.
	treesitter.install(vim.tbl_map(vim.treesitter.language.get_lang, treesitter_filetypes))

	-- Enable native Nvim Tree-sitter highlighting for filetypes whose parsers are managed by nvim-treesitter or bundled with Nvim.
	vim.api.nvim_create_autocmd("FileType", {
		pattern = treesitter_filetypes,
		callback = function()
			-- Keep files usable while missing parsers install asynchronously.
			if not pcall(vim.treesitter.start) then
				return
			end

			-- Preserve the previous Tree-sitter indentation behavior using the new nvim-treesitter indentation entry point.
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})

	local fzf_lua = require("fzf-lua")
	local actions = require("fzf-lua.actions")

	-- Configure fzf-lua to keep skim-backed file and grep pickers with tab-opening file actions.
	fzf_lua.setup({
		fzf_bin = "sk", -- use skim instead of fzf
		actions = {
			files = {
				true, -- inherit default bindings
				["enter"] = actions.file_tabedit, -- open in a tab on Enter
			},
		},
		defaults = {
			file_icons = false,
		},
		files = {
			-- Let skim match pasted paths reliably while preferring exact filenames over longer prefix matches.
			fzf_opts = { ["--split-match"] = "/", ["--algo"] = "skim_v2", ["--tiebreak"] = "score,length,begin,end" },
		},
	})

	-- Map the main file finder to fzf-lua's files picker.
	vim.keymap.set("n", "<leader>f", function()
		fzf_lua.files()
	end, { silent = true, desc = "Find Files" })

	-- Map the notes finder to fzf-lua with the notes directory as its working tree.
	vim.keymap.set("n", "<leader>n", function()
		fzf_lua.files({ cwd = NOTES_ROOT })
	end, { silent = true, desc = "Find Notes" })

	-- Map live grep to fzf-lua's project text search picker.
	vim.keymap.set("n", "<leader>g", function()
		fzf_lua.live_grep()
	end, { silent = true, desc = "Live Grep" })

	-- Keep Fidget as the notification and LSP progress UI because native progress is not visible with this minimal statusline setup.
	require("fidget").setup()

	-- Defer Cyrillic keyboard helpers until after startup so the vim.pack migration keeps Lazy's VeryLazy timing.
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			-- Load Cyrillic keyboard helpers after startup to preserve Lazy's deferred VeryLazy timing.
			vim.cmd.packadd("cyrillic.nvim")
			require("cyrillic").setup({
				no_cyrillic_abbrev = false, -- default
			})
		end,
	})
end

-- Native LSP configuration uses ~/.config/nvim/lsp/*.lua files and does not require a plugin wrapper.
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = true,
})

-- Attach buffer-local LSP mappings whenever a native LSP client starts for a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local function map(mode, lhs, rhs)
			-- Apply a consistent buffer-local LSP mapping shape for every attached server.
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true })
		end

		-- LSP keybindings.
		map("n", "gD", vim.lsp.buf.declaration)
		map("n", "gd", vim.lsp.buf.definition)
		map("n", "gi", vim.lsp.buf.implementation)
		map("n", "<C-k>", vim.lsp.buf.signature_help)
		map("n", "<leader>D", vim.lsp.buf.type_definition)
		map("n", "<leader>r", vim.lsp.buf.rename)
		map("n", "<leader>a", vim.lsp.buf.code_action)
		map("n", "gr", vim.lsp.buf.references)
		map("n", "<leader>e", vim.diagnostic.open_float)
		map("n", "<leader>q", vim.diagnostic.setloclist)
		-- Use the format-on-save chain for manual formatting, with LSP fallback for other filetypes.
		map("n", "<leader>lf", function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end)
	end,
})

-- Enable LSP servers using native configuration files from the lsp/ directory.
local servers = {
	"bashls",
	"biome",
	"denols",
	"lua_ls",
	"marksman",
	"ruff",
	"rust_analyzer",
	"typos_lsp",
	"vuels",
	-- "harper_ls",
}

vim.lsp.enable(servers)
