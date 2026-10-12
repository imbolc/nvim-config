-- Run from the repository root: vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/theme.lua
-- Exercise the real file watcher without loading plugins or changing the user's theme.
local source = table.concat(vim.fn.readfile("init.lua"), "\n")
local setup = assert(source:match("(\tlocal theme_file = .-)\n\t%-%- Configure table%-mode"))
local theme_file = vim.fn.tempname() .. ".lua"
local messages = {}
vim.fn.expand = function(path)
	assert(path == "~/.config/nvim/theme.lua")
	return theme_file
end
vim.notify = function(message, level)
	table.insert(messages, { message, level })
end

-- A first-run file must exist before the watcher starts, without producing an error.
assert(loadstring(setup))()
assert(vim.fn.filereadable(theme_file) == 1 and #messages == 0)
vim.fn.writefile({ "vim.g.theme_test_value = 'first'" }, theme_file)
assert(
	vim.wait(2000, function()
		return vim.g.theme_test_value == "first"
	end),
	"The watcher did not load the first theme edit"
)

-- Invalid edits must report an error and leave the watcher able to load the next valid edit.
vim.fn.writefile({ "this is not valid Lua" }, theme_file)
assert(
	vim.wait(2000, function()
		return #messages > 0
	end),
	"An invalid theme edit was not reported"
)
assert(messages[1][1]:find("Error loading theme file:", 1, true))
assert(messages[1][2] == vim.log.levels.ERROR)
assert(vim.g.theme_test_value == "first")
vim.fn.writefile({ "vim.g.theme_test_value = 'second'" }, theme_file)
assert(
	vim.wait(2000, function()
		return vim.g.theme_test_value == "second"
	end),
	"The watcher did not recover after an invalid edit"
)

-- A new session applies the persisted theme immediately and closes its watcher on exit.
vim.api.nvim_exec_autocmds("VimLeavePre", {})
vim.g.theme_test_value = nil
assert(loadstring(setup))()
assert(vim.g.theme_test_value == "second")
vim.api.nvim_exec_autocmds("VimLeavePre", {})
assert(vim.uv.fs_unlink(theme_file))

print("Theme reload regression check passed")
