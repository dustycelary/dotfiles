-- Diffview — visual git diffs, side-by-side branch comparison, and merge conflict tool
return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Git Diffview" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Current File Git History" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Project Git History" },
		{ "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Close Git Diffview" },
	},
	opts = {},
}
