-- Habits plugins: helping you learn better Vim/Neovim movement patterns.
return {
	-- hardtime.nvim: Prevents bad habits like spamming hjkl
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		event = "VeryLazy",
		opts = {
			disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason", "aerial", "fzf" },
		},
		keys = {
			{ "<leader>uh", "<cmd>Hardtime toggle<cr>", desc = "Toggle Hardtime" },
		},
	},

	-- precognition.nvim: Guides you to use better Neovim motions
	{
		"tris203/precognition.nvim",
		event = "VeryLazy",
		opts = {
			startVisible = true,
			showBlankVirtLine = true,
		},
		keys = {
			{
				"<leader>up",
				function()
					require("precognition").toggle()
				end,
				desc = "Toggle Precognition",
			},
		},
	},
}
