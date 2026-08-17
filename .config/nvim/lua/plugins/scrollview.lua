-- nvim-scrollview — scrollbar on the right edge of windows.
-- Light, high-contrast scrollbar handle for easy visibility (winblend 0).
-- Hides automatically when it would overlap text.
-- Shown only on the current window to save performance. No diagnostic/sign overlays configured.
return {
	"dstein64/nvim-scrollview",
	opts = {
		excluded_filetypes = {},
		current_only = true,
		base = "right",
		column = 1,
		hide_on_text_intersect = true,
		winblend = 0,
		winblend_gui = 0,
		signs_on_startup = {},
		diagnostics_severities = {},
	},
	config = function(_, opts)
		require("scrollview").setup(opts)

		local function set_scrollview_hl()
			if vim.o.background == "dark" then
				vim.api.nvim_set_hl(0, "ScrollView", { bg = "#a6adc8", fg = "#11111b" })
			else
				vim.api.nvim_set_hl(0, "ScrollView", { bg = "#5c5f77", fg = "#ffffff" })
			end
		end

		set_scrollview_hl()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("ScrollViewCustomHighlight", { clear = true }),
			callback = set_scrollview_hl,
		})
	end,
}
