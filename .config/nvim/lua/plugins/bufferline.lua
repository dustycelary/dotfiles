-- bufferline.nvim — tab bar showing open buffers with LSP diagnostic counts.
-- Navigated with <Tab>/<S-Tab> (keymaps.lua). Close icons hidden to reduce noise.
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			mode = "buffers",
			diagnostics = "nvim_lsp",
			always_show_bufferline = true,
			show_buffer_close_icons = false,
			show_close_icon = false,
		},
	},
}
