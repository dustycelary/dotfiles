-- todo-comments.nvim — highlights TODO/FIXME/HACK/NOTE/etc comments with colored icons.
-- ]t / [t jump between todos (repeatable via treesitter-textobjects).
-- <leader>st opens a fzf picker of all todos in the project.
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter-textobjects" },
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
	config = function(_, opts)
		require("todo-comments").setup(opts)
		local rep = require("nvim-treesitter-textobjects.repeatable_move")
		local todo_move = rep.make_repeatable_move(function(opts)
			if opts.forward then
				require("todo-comments").jump_next()
			else
				require("todo-comments").jump_prev()
			end
		end)
		vim.keymap.set({ "n", "x", "o" }, "]t", function()
			todo_move({ forward = true })
		end, { desc = "Next TODO comment" })
		vim.keymap.set({ "n", "x", "o" }, "[t", function()
			todo_move({ forward = false })
		end, { desc = "Previous TODO comment" })
		vim.keymap.set("n", "<leader>st", "<cmd>TodoFzfLua<cr>", { desc = "Fzf TODO comments" })
	end,
}
