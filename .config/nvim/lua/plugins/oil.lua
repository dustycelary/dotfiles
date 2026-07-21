-- oil.nvim — file explorer that allows editing the filesystem like a normal Vim buffer.
return {
	"stevearc/oil.nvim",
	lazy = false,
	opts = {
		default_file_explorer = true,
		delete_to_trash = true, -- Trash mode enabled by default
		skip_confirm_for_simple_edits = true,
		constrain_cursor = "editable", -- Keeps cursor on filename column
		experimental_watch_for_changes = true, -- Auto-refresh when files change on disk
		columns = {
			"icon",
			-- "permissions",
			-- "size",
			-- "mtime",
		},
		win_options = {
			wrap = false,
			signcolumn = "no",
			cursorcolumn = false,
			foldcolumn = "0",
			spell = false,
			list = false,
			conceallevel = 3,
			concealcursor = "nvic",
		},
		view_options = {
			show_hidden = true,
			is_hidden_file = function(name, bufnr)
				return vim.startswith(name, ".") and name ~= ".."
			end,
			is_always_leave_ignored = false,
		},
		preview = {
			max_width = 0.9,
			min_width = { 40, 0.4 },
			width = nil,
			max_height = 0.9,
			min_height = { 10, 0.1 },
			height = nil,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
		},
		progress = {
			max_width = 0.9,
			min_width = { 40, 0.4 },
			width = nil,
			max_height = { 10, 0.9 },
			min_height = { 5, 0.1 },
			height = nil,
			border = "rounded",
			min_update_interval = 50,
		},
		keymaps_help = {
			border = "rounded",
		},
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-s>"] = "actions.select_split",
			["<C-v>"] = "actions.select_vsplit",
			-- ["<C-h>"] = "actions.select_split",
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
			["<C-h>"] = false,
			["<C-l>"] = false,
			["<C-c>"] = "actions.close",
			["<C-r>"] = "actions.refresh",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
		},
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory in Oil" },
	},
}
