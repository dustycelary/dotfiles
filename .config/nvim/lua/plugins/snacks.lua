-- snacks.nvim — notifier replaces raw vim.notify (which can't render
-- multi-line messages like the LSP client list). input replaces vim.ui.input
-- with a float at the cursor, which is what makes the native LSP rename
-- prompt (<leader>cn, lsp.lua) usable. rename gives LSP-aware file renaming;
-- the Oil hookup lives in oil.lua's OilActionsPost autocmd.
-- quickfile renders the initial buffer before other plugins load, which
-- only works if snacks itself loads eagerly — hence lazy = false, per
-- upstream's own recommended config for bigfile/quickfile/dashboard users.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		notifier = { enabled = true },
		input = { enabled = true },
		quickfile = { enabled = true },
	},
	keys = {
		{
			"<leader>cr",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename file",
		},
		{
			"<leader>un",
			function()
				local lines = { "# Notifications" }
				for _, n in ipairs(Snacks.notifier.history or {}) do
					lines[#lines + 1] = ("[%s] %s"):format((n.level or "info"):upper(), n.msg or "")
				end
				vim.cmd("new")
				vim.bo.bufhidden = "wipe"
				vim.bo.swapfile = false
				vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
				vim.bo.modifiable = false
				vim.bo.filetype = "text"
			end,
			desc = "Notification history",
		},
	},
}
