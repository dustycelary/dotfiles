-- vim-fugitive — Git porcelain as Neovim buffers: interactive status
-- (stage/unstage with normal motions), diffsplit, blame, log — all editable
-- and navigable like any buffer, no external terminal UI needed.
return {
	"tpope/vim-fugitive",
	keys = {
		{ "<leader>gs", "<cmd>Git<cr>", desc = "Status" },
		{ "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Diff (split)" },
		{ "<leader>gl", "<cmd>Git log<cr>", desc = "Log" },
		{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Blame (full window)" },
		{ "<leader>gc", "<cmd>Git commit<cr>", desc = "Commit" },
		{ "<leader>gp", "<cmd>Git push<cr>", desc = "Push" },
		{ "<leader>gP", "<cmd>Git pull<cr>", desc = "Pull" },
	},
}
