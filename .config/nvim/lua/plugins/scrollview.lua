-- nvim-scrollview — scrollbar on the right edge of windows.
-- Semi-transparent (winblend 50). Hides automatically when it would overlap text.
-- Shown only on the current window to save performance. No diagnostic/sign overlays configured.
return {
	"dstein64/nvim-scrollview",
	opts = {
		excluded_filetypes = {},
		current_only = true,
		base = "right",
		column = 1,
		hide_on_text_intersect = true,
		winblend = 50,
		winblend_gui = 50,
		signs_on_startup = {},
		diagnostics_severities = {},
	},
}
