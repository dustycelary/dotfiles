-- supermaven-nvim — Ultra-fast AI code completion plugin.
-- Usage commands inside Neovim:
--   :SupermavenUseFree  — Activate free tier
--   :SupermavenUsePro   — Activate pro tier / sign in
--   :SupermavenStatus   — Check connection status
return {
	"supermaven-inc/supermaven-nvim",
	event = "VeryLazy",
	cmd = {
		"SupermavenUseFree",
		"SupermavenUsePro",
		"SupermavenStatus",
		"SupermavenToggle",
		"SupermavenLogout",
		"SupermavenShowLog",
	},
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-a>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
			ignore_filetypes = {},
			color = {
				suggestion_color = "#888888",
				cterm = 244,
			},
			disable_inline_completion = false,
			disable_keymaps = false,
		})
	end,
}
