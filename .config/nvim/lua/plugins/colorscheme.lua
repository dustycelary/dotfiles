return {
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = false,
		priority = 1000,
		config = function()
			require("github-theme").setup({
				options = {
					transparent = false,
					terminal_colors = true,
					darken = {
						floats = true,
						sidebars = { enable = true },
					},
				},
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("github_dark_default")
		end,
	},
}
