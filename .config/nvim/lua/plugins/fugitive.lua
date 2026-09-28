-- vim-fugitive — Git porcelain as Neovim buffers: interactive status
-- (stage/unstage with normal motions), diffsplit, blame, log — all editable
-- and navigable like any buffer, no external terminal UI needed.
return {
	"tpope/vim-fugitive",
	keys = {
		{ "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
		{ "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff (split)" },
		{ "<leader>gl", "<cmd>Git log<cr>", desc = "Git log" },
		{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame (interactive)" },
		{ "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
		{ "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
		{ "<leader>gP", "<cmd>Git pull<cr>", desc = "Git pull" },
	},
}
