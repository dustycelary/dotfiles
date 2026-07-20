-- User configuration for Neovim
-- TODO: fix keymap grouping so that they all make sense, such as LSP and code actions
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable built-in netrw so oil.nvim handles directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Global filetype overrides
vim.filetype.add({
	pattern = {
		[".*%.env.*"] = "sh",
	},
	extension = {
		conf = "sh",
	},
})

-- Display options
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative numbers
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.signcolumn = "yes" -- Always show sign column (for gitsigns etc)
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.autoindent = true -- Keep identation from previous line
vim.opt.smarttab = true
-- vim.opt.smartindent = true
vim.opt.expandtab = true -- Convert tabs to spaces by default

vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true
-- vim.opt.clipboard = "unnamedplus" -- Use system clipboard by default

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.equalalways = true -- always equalize window sizes when splitting/closing
vim.opt.eadirection = "both" -- equalize both width and height

vim.opt.swapfile = false -- Disable swapfiles (undofile is enabled)

-- Automatically append \v when starting a search
vim.keymap.set("n", "/", "/\\v", { desc = "Search with Very Magic" })
vim.keymap.set("n", "?", "?\\v", { desc = "Search backward with Very Magic" })

-- Automatically append \v when starting a substitute command without delaying `:` commands
vim.keymap.set("c", "/", function()
	if vim.fn.getcmdtype() == ":" then
		local cmd = vim.fn.getcmdline()
		local base_pattern = "^[%%'%<%>%d%,%.%$%-%+%;]*"
		if
			cmd:match(base_pattern .. "s$")
			or cmd:match(base_pattern .. "sub$")
			or cmd:match(base_pattern .. "substitute$")
		then
			return "/\\v"
		end
	end
	return "/"
end, { expr = true, desc = "Substitute with Very Magic" })

-- Disable auto-comment continuation when pressing 'o' or 'O'
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "o" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
	local osc52 = require("vim.ui.clipboard.osc52")
	local function no_clipboard_paste()
		return {}, "v"
	end

	local function both_registers(value)
		return { ["+"] = value, ["*"] = value }
	end

	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = both_registers(no_clipboard_paste),
		cache_enabled = 0,
	}
end

vim.opt.showcmd = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 1000
vim.opt.wrap = false

-- Folding
vim.opt.foldmethod = "manual"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with all folds open
vim.opt.foldlevelstart = 99 -- files open with all folds open
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
-- vim.opt.foldnestmax = 4 -- limit nesting depth

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- Diagnostics
vim.diagnostic.config({ virtual_text = false, virtual_lines = false })
-- Load custom keymaps
require("keymaps")
