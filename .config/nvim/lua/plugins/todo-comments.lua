return {
	"folke/todo-comments.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
	config = function(_, opts)
		require("todo-comments").setup(opts)
		vim.keymap.set("n", "<leader>st", "<cmd>TodoFzfLua<cr>", { desc = "Fzf TODO comments" })
	end,
}
