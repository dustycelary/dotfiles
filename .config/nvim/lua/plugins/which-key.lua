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
			height = { max = math.huge },
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
	},
}
