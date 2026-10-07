-- User configuration for Neovim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure Homebrew, standard binary, and Mason-installed tool paths are in PATH
-- so LSP/formatter executables (ruff, stylua, prettier, ...) are found
local extra_paths = {
	vim.fn.stdpath("data") .. "/mason/bin",
	"/opt/homebrew/bin",
	"/opt/homebrew/sbin",
	"/usr/local/bin",
}
for _, path in ipairs(extra_paths) do
	if vim.fn.isdirectory(path) == 1 and not vim.env.PATH:find(path, 1, true) then
		vim.env.PATH = path .. ":" .. vim.env.PATH
	end
end

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

-- Use treesitter's indentexpr where a parser provides one (falls back to autoindent)
_G.__ts_indentexpr = function()
	return require("nvim-treesitter").indentexpr()
end
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserTreesitterIndent", { clear = true }),
	pattern = "*",
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if lang and pcall(vim.treesitter.query.get, lang, "indents") then
			vim.bo[args.buf].indentexpr = "v:lua.__ts_indentexpr()"
		end
	end,
})
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
vim.opt.showmode = false -- statusline/plugins already show mode
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.wrap = false

vim.opt.winborder = "rounded" -- default border for all floating windows (hover, oil, bqf, etc.)
vim.opt.fillchars = { vert = "│", horiz = "─", verthoriz = "┼", horizup = "┴", horizdown = "┬", vertleft = "┤", vertright = "├" }
vim.opt.inccommand = "nosplit" -- live preview :s and cmdline commands
vim.opt.splitkeep = "screen" -- keep text on screen steady when splitting/closing
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.list = false -- show whitespace characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with all folds open
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldnestmax = 8 -- limit nesting depth

-- own options

-- getting rid of comments when starting new line using 'o'
local user_config_group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = user_config_group,
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove("o")
	end,
})
