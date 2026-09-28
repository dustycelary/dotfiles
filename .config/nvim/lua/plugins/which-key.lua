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
			-- border comes from the global vim.opt.winborder default
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
			{ "<leader>b", group = "Buffers", icon = "" },
			{ "<leader>c", group = "Code & LSP", icon = "" },
			{ "<leader>d", group = "Directories", icon = "" },
			{ "<leader>f", group = "Fzf Search & Find", icon = "" },
			{ "<leader>g", group = "Git", icon = "" },
			{ "<leader>h", group = "Harpoon (project files)", icon = "" },
			{ "<leader>l", group = "Location List", icon = "" },
			{ "<leader>m", group = "Bookmarks (global)", icon = "" },
			{ "<leader>n", group = "Swap Next (Treesitter)", icon = "" },
			{ "<leader>N", group = "Swap Previous (Treesitter)", icon = "" },
			{ "<leader>q", group = "Quickfix", icon = "" },
			{ "<leader>S", group = "Sessions", icon = "" },
			{ "<leader>s", group = "Surround", icon = "" },
			{ "<leader>u", group = "UI Toggles", icon = "" },
			{ "<leader>w", group = "Windows & Splits", icon = "" },
			{ "<leader>?", "<cmd>FzfLua keymaps<cr>", desc = "Search all keymaps", icon = "" },
			{ "gr", group = "LSP Definitions / References" },
			{ "]", group = "Next Motion", icon = "" },
			{ "[", group = "Previous Motion", icon = "" },
		},
	},
}
