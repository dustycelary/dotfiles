-- nvim-bqf — Better Quickfix window with floating code preview and syntax highlighting
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	opts = {
		auto_enable = true,
		preview = {
			win_height = 12,
			win_vheight = 12,
			delay_syntax = 80,
			border = "rounded",
			show_title = true,
		},
	},
}
