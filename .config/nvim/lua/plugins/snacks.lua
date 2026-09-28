-- snacks.nvim — only the notifier module is enabled here, replacing raw
-- vim.notify (which can't render multi-line messages like the LSP client list).
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		notifier = { enabled = true },
	},
}
