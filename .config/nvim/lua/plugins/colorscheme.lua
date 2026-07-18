-- gruvbox.nvim — colorscheme, using the Gruvbox Dark Hard variant.
-- Styles: italic comments/strings, bold keywords/functions.
return {
	"ellisonleao/gruvbox.nvim",
	lazy = false, -- load during startup, it's the main UI theme
	priority = 1000, -- load before all other plugins so highlights are correct
	config = function()
		require("gruvbox").setup({
			terminal_colors = true, -- add neovim terminal colors
			undercurl = true,
			underline = true,
			bold = true,
			italic = {
				strings = true,
				emphasis = true,
				comments = true,
				operators = false,
				folds = true,
			},
			strikethrough = true,
			invert_selection = false,
			invert_signs = false,
			invert_tabline = false,
			invert_intend_guides = false,
			inverse = true, -- invert background for search, diffs, etc.
			contrast = "hard", -- can be "hard", "soft" or empty string
			palette_overrides = {},
			overrides = {},
			dim_inactive = false,
			transparent_mode = false,
		})

		vim.cmd.colorscheme("gruvbox")
	end,
}
