-- aerial.nvim — code outline sidebar for symbols, functions, and classes.
return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>ua", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial code outline sidebar" },
	},
	opts = {
		layout = {
			default_direction = "left",
			placement = "edge",
		},
		attach_mode = "global",
		backends = { "treesitter", "lsp", "markdown", "man" },
		show_guides = true,
		keymaps = {
			["<C-k>"] = false,
		},
	},
}
