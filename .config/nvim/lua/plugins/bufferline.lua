-- bufferline.nvim — top buffer tab bar with S-l / S-h navigation
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			mode = "buffers",
			diagnostics = "nvim_lsp",
			separator_style = "thin",
			show_buffer_close_icons = false,
			show_close_icon = false,
		},
	},
	keys = {
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle buffer pin" },
		{ "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
	},
}
