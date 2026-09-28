-- nvim-treesitter-context — pinned function/class header context at the top of the window
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "BufReadPost",
	opts = {
		enable = true,
		max_lines = 3,
		min_window_height = 0,
		line_numbers = true,
		multiline_threshold = 20,
		trim_scope = "outer",
		mode = "cursor",
		separator = nil,
		zindex = 20,
	},
}
