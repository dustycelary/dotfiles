-- User configuration for Neovim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable built-in netrw so oil.nvim handles directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldnestmax = 4 -- limit nesting depth
