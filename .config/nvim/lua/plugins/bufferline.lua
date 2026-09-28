-- bufferline.nvim — top buffer tab bar with S-l / S-h navigation
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	-- Tabline re-renders on every buffer/diagnostic event; Pi uses the
	-- built-in tabline instead (see take-over keymaps below reusing Tab keys).
	enabled = not require("is_pi").is_pi,
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
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin" },
		{ "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick and close" },
	},
}
