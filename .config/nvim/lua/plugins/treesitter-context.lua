-- nvim-treesitter-context — sticky function/class context headers at top of window.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	main = "treesitter-context",
	opts = {
		enable = true,
		max_lines = 4,
		min_window_height = 0,
		line_numbers = true,
		multiline_threshold = 20,
		trim_scope = "outer",
		mode = "cursor",
		separator = nil,
		zindex = 20,
	},
	config = function(_, opts)
		require("treesitter-context").setup(opts)
	end,
	keys = {
		{
			"[c",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to parent context",
		},
		{ "<leader>ut", "<cmd>TSContextToggle<cr>", desc = "Toggle Treesitter Context" },
	},
}
