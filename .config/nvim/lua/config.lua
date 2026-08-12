-- User configuration for Neovim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Default .sh files to bash syntax/filetype
vim.g.is_bash = 1

-- Disable built-in netrw so oil.nvim handles directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Display options
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative numbers
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true
vim.opt.signcolumn = "yes" -- Always show sign column (for gitsigns etc)
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.autoindent = true -- Keep indentation from previous line
vim.opt.smarttab = true
-- vim.opt.smartindent = true
vim.opt.expandtab = true -- Convert tabs to spaces by default
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while performing editing operations

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

vim.opt.showcmd = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 1000
vim.opt.wrap = false

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with all folds open
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldnestmax = 4 -- limit nesting depth

-- own options

-- getting rid of comments when starting new line using 'o'
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove("o")
	end,
})
