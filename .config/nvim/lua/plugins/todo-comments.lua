-- todo-comments.nvim — highlight TODO/FIXME/HACK/NOTE/etc. in comments.
-- ]t / [t jump between them; <leader>ft lists them via fzf-lua (rg-backed),
-- <leader>fT narrows to TODO/FIX/FIXME. <leader>qt dumps them into quickfix.
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TodoQuickFix", "TodoLocList", "TodoFzfLua" },
	opts = {
		signs = false, -- keep the sign column for gitsigns/diagnostics
	},
	keys = {
		{ "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
		{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
		{ "<leader>ft", function() require("todo-comments.fzf").todo() end, desc = "Todo comments" },
		{
			"<leader>fT",
			function() require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end,
			desc = "Todo/Fix/Fixme",
		},
		{ "<leader>qt", "<cmd>TodoQuickFix<cr>", desc = "Todo comments → quickfix" },
	},
}
