return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = false,
				terminal_colors = true,
				dim_inactive = {
					enabled = false,
					shade = "dark",
					percentage = 0.15,
				},
				integrations = {
					cmp = true,
					gitsigns = true,
					harpoon = true,
					indent_blankline = { enabled = true },
					mason = true,
					native_lsp = { enabled = true },
					treesitter = true,
					treesitter_context = true,
					which_key = true,
					fzf = true,
					render_markdown = true,
					flash = true,
					oil = true,
				},
				custom_highlights = function(colors)
					return {
						WinSeparator = { fg = colors.overlay2, bold = true },
					}
				end,
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
