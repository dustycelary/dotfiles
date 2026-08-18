return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function(_, opts)
			require("catppuccin").setup(opts)
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
		config = function()
			require("nightfox").setup({
				options = {
					transparent = true,
				},
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("carbonfox")
		end,
	},
}
