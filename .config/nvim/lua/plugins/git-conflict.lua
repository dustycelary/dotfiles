-- git-conflict.nvim — visualize and resolve git merge conflicts inline.
-- Auto-detects conflict markers (<<<<<<<, =======, >>>>>>>) in buffers.

return {
	"akinsho/git-conflict.nvim",
	version = "*",
	event = "VeryLazy",
	opts = {
		default_mappings = {
			ours = "co",
			theirs = "ct",
			none = "cn",
			both = "cb",
			next = "]x",
			prev = "[x",
		},
		default_commands = true,
		disable_diagnostics = false,
		list_opener = "copen",
	},
	keys = {
		{ "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", desc = "Git Conflict: Choose Ours" },
		{ "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Git Conflict: Choose Theirs" },
		{ "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", desc = "Git Conflict: Choose Both" },
		{ "<leader>gcn", "<cmd>GitConflictChooseNone<cr>", desc = "Git Conflict: Choose None" },
		{ "<leader>gcq", "<cmd>GitConflictListQf<cr>", desc = "Git Conflict: Quickfix List" },
		{ "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next Git Conflict" },
		{ "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev Git Conflict" },
	},
}
