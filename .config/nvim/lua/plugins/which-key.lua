-- which-key.nvim — vertical floating popup for keymaps.
-- Helix preset presents keymaps in a sleek vertical side panel with Gruvbox styling.

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix", -- Vertical side layout
		delay = 300, -- Delay in ms before showing popup
		keys = {
			scroll_down = "<c-d>",
			scroll_up = "<c-u>",
		},
		win = {
			border = "rounded", -- Complete rounded floating card border
			padding = { 1, 2 }, -- Balanced inner padding
			title = true,
			title_pos = "center",
			wo = {
				winblend = 0,
			},
			height = { max = 25 },
		},
		layout = {
			align = "left",
		},
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
			colors = true,
			mappings = true,
		},
		spec = {
			{ "<leader>b", group = "Buffers" },
			{ "<leader>c", group = "Code & LSP" },
			{ "<leader>f", group = "Fzf Search & Find" },
			{ "<leader>h", group = "Harpoon Bookmarks" },
			{ "<leader>m", group = "Marks & Quickfix" },
			{ "<leader>t", group = "Terminal & Tabs" },
			{ "<leader>u", group = "UI Toggles" },
			{ "<leader>w", group = "Windows & Splits" },
			{ "<leader>x", group = "Diagnostics" },
			{ "gr", group = "LSP Definitions / References" },
			{ "]", group = "Next Motion" },
			{ "[", group = "Previous Motion" },
		},
	},
}
