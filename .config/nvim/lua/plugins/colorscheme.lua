-- nightfox.nvim — terafox colorscheme

-- return {
-- 	"folke/tokyonight.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		local transparent = false -- set to true if you would like to enable transparency
--
-- 		local coolnight = {
-- 			bg = "#011323",
-- 			bg_dark = "#00111E",
-- 			bg_float = "#00111E",
-- 			bg_highlight = "#012646",
-- 			bg_popup = "#00111E",
-- 			bg_search = "#3E90D7",
-- 			bg_sidebar = "#00111E",
-- 			bg_statusline = "#00111E",
-- 			bg_visual = "#064984",
-- 			fg = "#E3EEF7",
-- 			fg_dark = "#AECBE5",
-- 			fg_float = "#CBDFF0",
-- 			fg_gutter = "#2D4F6C",
-- 			fg_sidebar = "#AECBE5",
-- 			border = "#03447C",
-- 		}
--
-- 		require("tokyonight").setup({
-- 			style = "storm",
-- 			transparent = transparent,
-- 			styles = {
-- 				sidebars = transparent and "transparent" or "dark",
-- 				floats = transparent and "transparent" or "dark",
-- 			},
-- 			on_colors = function(colors)
-- 				colors.bg = coolnight.bg
-- 				colors.bg_dark = transparent and colors.none or coolnight.bg_dark
-- 				colors.bg_float = transparent and colors.none or coolnight.bg_float
-- 				colors.bg_highlight = coolnight.bg_highlight
-- 				colors.bg_popup = coolnight.bg_popup
-- 				colors.bg_search = coolnight.bg_search
-- 				colors.bg_sidebar = transparent and colors.none or coolnight.bg_sidebar
-- 				colors.bg_statusline = transparent and colors.none or coolnight.bg_statusline
-- 				colors.bg_visual = coolnight.bg_visual
-- 				colors.border = coolnight.border
-- 				colors.fg = coolnight.fg
-- 				colors.fg_dark = coolnight.fg_dark
-- 				colors.fg_float = coolnight.fg_float
-- 				colors.fg_gutter = coolnight.fg_gutter
-- 				colors.fg_sidebar = coolnight.fg_sidebar
-- 			end,
-- 			lualine_bold = true,
-- 		})
--
-- 		vim.cmd("colorscheme tokyonight")
-- 	end,
-- }

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.o.background = "light"
			vim.cmd.colorscheme("catppuccin-latte")
		end,
		opts = {
			flavour = "latte",
			term_colors = true,
			transparent_background = false,
			styles = {
				comments = { "italic" },
				conditionals = { "bold" },
				functions = { "bold" },
				keywords = { "bold" },
				types = { "bold" },
				booleans = { "bold" },
				sidebars = "normal",
				floats = "normal",
			},
			integrations = {
				aerial = true,
				cmp = true,
				gitsigns = true,
				treesitter = true,
				which_key = true,
				render_markdown = true,
				fzf = true,
				indent_blankline = { enabled = true },
			},
			color_overrides = {
				latte = {
					base = "#ffffff", -- Pure crisp white background
					mantle = "#f2f4f8",
					crust = "#e2e8f0",
					text = "#181926", -- Deep slate-black text (razor-sharp contrast)
					subtext1 = "#363a4f",
					subtext0 = "#494d64",
					overlay2 = "#5c5f77", -- Darker, highly legible comments
				},
			},
			custom_highlights = function(colors)
				return {
					Visual = { bg = "#4c4f69", fg = "#eff1f5", bold = true },
					CursorLine = { bg = "#f1f3f9" },
					LineNr = { fg = "#8c8fa1" },
					CursorLineNr = { fg = "#181926", bold = true },
					NormalSB = { bg = "#f2f4f8", fg = "#181926" },
					SignColumnSB = { bg = "#f2f4f8" },
				}
			end,
		},
	},
	{
		"EdenEast/nightfox.nvim",
		priority = 1000,
	},
}
