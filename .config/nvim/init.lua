-- Cache compiled Lua bytecode so startup doesn't re-parse every plugin's
-- source from disk each launch — biggest win on slow storage (e.g. Pi SD card).
vim.loader.enable()

require("config")
require("keymaps")
require("bookmarks").setup()

local is_pi = require("is_pi").is_pi

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

require("lazy").setup("plugins", {
	-- On Pi the background update checker + change-detection git polling
	-- thrash the SD card; check manually with :Lazy on the Pi.
	checker = { enabled = not is_pi, notify = false },
	change_detection = { enabled = not is_pi, notify = false },
	performance = {
		rtp = {
			-- skip sourcing built-in runtime plugins we don't use, to shave a
			-- few ms off startup (matchit/matchparen kept: real editing features)
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"zipPlugin",
				"tohtml",
				"tutor",
				"netrwPlugin", -- oil.nvim replaces netrw anyway
			},
		},
	},
})

-- Diagnostics
vim.diagnostic.config({ virtual_text = false, virtual_lines = false })

