-- oil.nvim — file explorer that allows editing the filesystem like a normal Vim buffer.

-- Jump straight to one fixed directory, wherever you are. `:edit` is enough
-- because oil is default_file_explorer with netrw disabled.
local function open_dir(path)
	return function()
		local dir = vim.fn.expand(path)
		if vim.fn.isdirectory(dir) == 0 then
			vim.notify("No such directory: " .. path, vim.log.levels.WARN)
			return
		end
		vim.cmd.edit(vim.fn.fnameescape(dir))
	end
end

-- The trash oil writes to with delete_to_trash. macOS has one system-wide
-- trash, so the path in the URL is ignored there and you always get all of
-- ~/.Trash; the freedesktop (Pi) implementation is per-directory, so passing
-- $HOME gets everything trashed from under the home directory.
local function open_trash()
	vim.cmd.edit("oil-trash://" .. vim.fn.expand("~"))
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
			min_update_interval = 50,
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
			["~"] = { "actions.cd", opts = { scope = "tab" }, desc = "Change tab directory here (:tcd)" },
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
			-- oil's own actions.yank_entry writes to vim.v.register, i.e. the
			-- unnamed register unless you type "+gy. Yank straight to the
			-- system clipboard instead (matching gY below), while still
			-- honouring an explicit register prefix like "ay.
			["gy"] = {
				desc = "Yank entry path to clipboard",
				callback = function()
					local oil = require("oil")
					local entry = oil.get_cursor_entry()
					local dir = oil.get_current_dir()
					if not (entry and dir) then
						return
					end
					local path = dir .. entry.name .. (entry.type == "directory" and "/" or "")
					local register = vim.v.register == '"' and "+" or vim.v.register
					vim.fn.setreg(register, path)
					vim.notify("Yanked " .. path)
				end,
			},
			["gY"] = {
				desc = "Yank current directory path",
				callback = function()
					local dir = require("oil").get_current_dir()
					if dir then
						vim.fn.setreg("+", dir)
						vim.notify("Yanked directory: " .. dir)
					end
				end,
			},
		},
	},
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/snacks.nvim" },
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory in Oil" },
		-- Two directories that are never "under the current project" but are
		-- always worth one key: where downloads land, and where deletes go.
		-- (g\ still toggles the trash for whatever directory you're browsing.)
		{ "<leader>dw", open_dir("~/Downloads"), desc = "Downloads" },
		{ "<leader>dt", open_trash, desc = "Trash" },
	},
	config = function(_, opts)
		require("oil").setup(opts)

		-- Tell attached LSP clients about renames/moves done inside Oil (editing
		-- a filename and :w) so they can update imports/requires. A single save
		-- can batch multiple move actions, so walk all of them, not just the first.
		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(event)
				for _, action in ipairs(event.data.actions) do
					if action.type == "move" then
						Snacks.rename.on_rename_file(action.src_url, action.dest_url)
					end
				end
			end,
		})

		-- `-` is declared in `keys` above, which is also what lazy-loads oil; a
		-- second vim.keymap.set here would only overwrite it with a different
		-- description, so which-key would show one thing and lazy another.

		-- Expand %% to the current directory on the command line
		vim.keymap.set("c", "%%", function()
			if vim.bo.filetype == "oil" then
				return require("oil").get_current_dir()
			else
				return vim.fn.expand("%:p:h") .. "/"
			end
		end, { expr = true, desc = "Expand to current directory path" })
	end,
}
