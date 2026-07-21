-- oil.nvim — file explorer that allows editing the filesystem like a normal Vim buffer.

local function toggle_oil_sidebar()
	local current_win = vim.api.nvim_get_current_win()
	local current_tab = vim.api.nvim_get_current_tabpage()

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "oil" then
			if win == current_win then
				vim.api.nvim_win_close(win, true)
			else
				vim.api.nvim_set_current_win(win)
			end
			return
		end
	end

	vim.cmd("topleft 30vsplit")
	require("oil").open()
	vim.wo.winfixwidth = true
end

local function open_entry_to_side(keep_open)
	local oil = require("oil")
	local util = require("oil.util")
	local entry = oil.get_cursor_entry()
	if not entry then
		return
	end

	if util.is_directory(entry) then
		oil.select()
		return
	end

	local oil_win = vim.api.nvim_get_current_win()
	local oil_buf = vim.api.nvim_get_current_buf()
	local current_tab = vim.api.nvim_get_current_tabpage()

	local target_win = nil
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
		if win ~= oil_win and vim.api.nvim_win_get_config(win).relative == "" then
			local buf = vim.api.nvim_win_get_buf(win)
			local ft = vim.bo[buf].filetype
			if ft ~= "oil" and ft ~= "aerial" then
				target_win = win
				break
			end
		end
	end

	if not target_win or not vim.api.nvim_win_is_valid(target_win) then
		vim.cmd("rightbelow vsplit")
		target_win = vim.api.nvim_get_current_win()
	end

	util.get_edit_path(oil_buf, entry, function(normalized_url)
		vim.api.nvim_set_current_win(target_win)
		vim.cmd.edit({ args = { util.escape_filename(normalized_url) } })

		if not keep_open and vim.api.nvim_win_is_valid(oil_win) then
			vim.api.nvim_win_close(oil_win, true)
		end
	end)
end

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
			["q"] = "<cmd>quit<CR>",
			["<S-CR>"] = {
				callback = function()
					open_entry_to_side(true)
				end,
				desc = "Open file in side window and keep Oil open",
			},
			["<CR>"] = {
				callback = function()
					open_entry_to_side(false)
				end,
				desc = "Open file in side window and close Oil",
			},
			["l"] = {
				callback = function()
					open_entry_to_side(false)
				end,
				desc = "Open file and close Oil (or enter directory)",
			},
			["<C-s>"] = "actions.select_vsplit",
			["<C-v>"] = "actions.select_vsplit",
			["<C-h>"] = false,
			["<C-l>"] = false,
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
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
		{
			"<leader>e",
			function()
				toggle_oil_sidebar()
			end,
			desc = "Toggle Oil file explorer sidebar",
		},
	},
}
