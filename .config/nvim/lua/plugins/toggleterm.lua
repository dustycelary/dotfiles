-- toggleterm.nvim — dynamic floating, horizontal, and vertical terminals in Neovim.

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,
		open_mapping = [[<c-\>]],
		hide_numbers = true,
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		persist_mode = true,
		direction = "float",
		close_on_exit = true,
		clear_env = false,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
			winblend = 0,
			title_pos = "center",
		},
	},
	keys = {
		{ "<c-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal", mode = { "n", "t" } },
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Float)", mode = { "n" } },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Floating Terminal", mode = { "n" } },
		{
			"<leader>th",
			"<cmd>ToggleTerm direction=horizontal<cr>",
			desc = "Toggle Horizontal Terminal",
			mode = { "n" },
		},
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle Vertical Terminal", mode = { "n" } },
	},
}
