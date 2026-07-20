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
	-- config = function(_, opts)
	-- 	local wk = require("which-key")
	-- 	wk.setup(opts)
	--
	-- 	-- Enhanced Gruvbox color scheme highlights for WhichKey
	-- 	local hl = vim.api.nvim_set_hl
	-- 	hl(0, "WhichKey", { fg = "#fabd2f", bold = true }) -- Key labels (Yellow)
	-- 	hl(0, "WhichKeyGroup", { fg = "#d3869b", bold = true }) -- Group names (Purple)
	-- 	hl(0, "WhichKeySeparator", { fg = "#fe8019" }) -- Separator arrow (Orange)
	-- 	hl(0, "WhichKeyDesc", { fg = "#ebdbb2" }) -- Key descriptions (Light Fg)
	-- 	hl(0, "WhichKeyBorder", { fg = "#fe8019", bg = "#1d2021" }) -- Orange rounded border
	-- 	hl(0, "WhichKeyNormal", { bg = "#1d2021" }) -- Deep background (Gruvbox Dark Hard)
	-- 	hl(0, "WhichKeyTitle", { fg = "#fe8019", bold = true }) -- Title text (Orange)
	-- 	hl(0, "WhichKeyIcon", { fg = "#8ec07c" }) -- Icons (Aqua)
	-- end,
}
