-- User configuration for Neovim
-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Display options
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative numbers
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.signcolumn = "yes" -- Always show sign column (for gitsigns etc)
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.autoindent = true -- Keep identation from previous line
vim.opt.smarttab = true
vim.opt.smartindent = true

vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.equalalways = true -- always equalize window sizes when splitting/closing
vim.opt.eadirection = "both" -- equalize both width and height

-- netrw
-- -- Use 'time' to sort by last modification date
vim.g.netrw_sort_by = "time"

-- Change the list style to 1 (Long listing format) to show dates, times, and file sizes
vim.g.netrw_liststyle = 1

-- Optional: Set the sort direction to 'reverse' so the newest files appear at the top
vim.g.netrw_sort_direction = "reverse"

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

if vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil then
	local function osc52_paste_fresh()
		if vim.fn.executable("python3") ~= 1 then
			return {}, "v"
		end

		local script = [[
import base64
import os
import re
import select
import sys
import termios
import time
import tty

tmux_mode = os.environ.get("TMUX") is not None
query = b"\x1bPtmux;\x1b\x1b]52;c;?\x07\x1b\\" if tmux_mode else b"\x1b]52;c;?\x07"

with open("/dev/tty", "r+b", buffering=0) as t:
    fd = t.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        os.write(fd, query)

        buf = bytearray()
        deadline = time.monotonic() + 1.5
        while time.monotonic() < deadline:
            timeout = max(0.0, deadline - time.monotonic())
            ready, _, _ = select.select([fd], [], [], timeout)
            if not ready:
                break
            chunk = os.read(fd, 4096)
            if not chunk:
                break
            buf.extend(chunk)
            if b"\x07" in buf or b"\x1b\\" in buf:
                break

        match = re.search(rb"\]52;[^;]*;([A-Za-z0-9+/=]+)", bytes(buf))
        if not match:
            raise SystemExit(1)

        sys.stdout.buffer.write(base64.b64decode(match.group(1), validate=False))
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
]]

		local output = vim.fn.systemlist({ "python3", "-c", script })
		if vim.v.shell_error ~= 0 then
			return {}, "v"
		end
		return output, "v"
	end

	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = osc52_paste_fresh,
			["*"] = osc52_paste_fresh,
		},
		cache_enabled = 0,
	}
end

vim.opt.showcmd = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 1000
vim.opt.wrap = false

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with all folds open
vim.opt.foldlevelstart = 99 -- files open with all folds open
vim.opt.foldnestmax = 4 -- limit nesting depth

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
