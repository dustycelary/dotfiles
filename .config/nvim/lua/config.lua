-- User configuration for Neovim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local is_pi = require("is_pi").is_pi

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
-- relativenumber + cursorline force a full-window redraw on every move;
-- fine on Mac, visibly laggy on Pi over SSH / software rendering.
vim.opt.relativenumber = not is_pi -- Show relative numbers
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true
vim.opt.signcolumn = "yes" -- Always show sign column (for gitsigns etc)
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.autoindent = true -- Keep indentation from previous line
vim.opt.smarttab = true
-- vim.opt.smartindent = true
vim.opt.expandtab = true -- Convert tabs to spaces by default

-- Use treesitter's indentexpr where a parser provides one (falls back to autoindent).
-- Skipped entirely on Pi: the per-FileType query lookup + indentexpr
-- evaluation costs more than it saves on weak ARM cores.
if not is_pi then
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
end
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while performing editing operations

vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.cursorline = not is_pi
-- vim.opt.clipboard = "unnamedplus" -- Use system clipboard by default

-- Over SSH there's no pbcopy/xclip to talk to, so route the "+ register
-- through OSC 52 instead: it rides the terminal escape sequence back up
-- through tmux/ssh to Ghostty, which writes it to the real macOS clipboard.
if vim.env.SSH_TTY then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}
end

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
vim.opt.inccommand = "nosplit" -- live preview :s and cmdline commands
vim.opt.splitkeep = "screen" -- keep text on screen steady when splitting/closing
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.list = false -- show whitespace characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

-- Folding
-- Treesitter foldexpr re-parses on every fold operation; on Pi fall back to
-- cheap manual folds (still open by default).
if is_pi then
	vim.opt.foldmethod = "manual"
else
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
end
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
