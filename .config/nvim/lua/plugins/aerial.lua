-- aerial.nvim — VSCode-style outline sidebar (functions, classes, markdown
-- headings). Treesitter first so it works without an LSP attached.
-- <leader>ua toggles the sidebar; inside it <CR> jumps, o/za fold, q closes.
return {
	"stevearc/aerial.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
	opts = {
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = {
			default_direction = "prefer_right",
			min_width = 28,
			max_width = { 40, 0.25 },
		},
		-- Follow the cursor in the source buffer and highlight its symbol.
		highlight_on_hover = true,
		autojump = false,
		show_guides = true,
		filter_kind = false, -- show every symbol kind, not just functions/classes
	},
	keys = {
		{ "<leader>ua", "<cmd>AerialToggle!<cr>", desc = "Outline (sidebar)" },
		{ "<leader>O", "<cmd>AerialNavToggle<cr>", desc = "Outline (floating nav)" },
	},
}
