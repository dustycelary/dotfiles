-- Harpoon 2 — fast file & command bookmarks & navigation.
--
-- Files stay scoped to the current directory (harpoon's normal per-project
-- behavior). Commands are global: the same list in every directory, and it
-- survives quitting nvim.
--
-- settings.key() alone can't do that. It decides two things at once: the
-- in-memory bucket *and* the file name on disk (harpoon/data.lua hashes the
-- key to pick <stdpath-data>/harpoon/<sha256>.json), and that file is read
-- exactly once, when Harpoon:setup() constructs its Data object. So a key()
-- that returns a constant only while a command keymap is running writes the
-- commands into the global file but still *reads* the cwd file at startup:
-- the list looks saved, then comes back empty on the next launch.
--
-- So the command list gets its own Data object, permanently pinned to
-- GLOBAL_CMD_KEY, and is deliberately kept out of harpoon.lists so that
-- Harpoon:sync() — which is always cwd-keyed — can never write it to the
-- wrong file. Saving it is our job: after an add, whenever the quick menu
-- rewrites a list, and on exit.
local GLOBAL_CMD_KEY = "__global_commands__"
local CMD_LIST = "cmd"

---@type { data: table, list: table }?
local cmd_store = nil

local function get_cmd_store()
	if cmd_store then
		return cmd_store
	end

	local Data = require("harpoon.data")
	local Config = require("harpoon.config")
	local List = require("harpoon.list")

	-- A minimal config whose key() is constant — this is what pins both the
	-- data file and the bucket inside it to the global key, forever.
	local data = Data.Data:new({
		settings = {
			key = function()
				return GLOBAL_CMD_KEY
			end,
		},
	})

	local list_config = Config.get_config(require("harpoon").config, CMD_LIST)

	cmd_store = {
		data = data,
		list = List.decode(list_config, CMD_LIST, data:data(GLOBAL_CMD_KEY, CMD_LIST)),
	}

	return cmd_store
end

local function cmd_list()
	return get_cmd_store().list
end

local function save_cmds()
	local store = get_cmd_store()
	store.data:update(GLOBAL_CMD_KEY, CMD_LIST, store.list:encode())
	store.data:sync()
end

-- Runs a stored "cmd" list entry: ':'-prefixed strings run as Vim commands,
-- anything else runs in a terminal split.
local function run_cmd(value)
	if value:sub(1, 1) == ":" then
		vim.cmd(value:sub(2))
	else
		vim.cmd("split | terminal " .. value)
	end
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		settings = {
			save_on_toggle = true,
			sync_on_ui_close = true,
		},
		-- Per-list override for "cmd": replaces the default file-opening
		-- select() entirely, instead of just adding a SELECT event listener
		-- (List:select() always runs both the event AND config.select, so a
		-- listener alone can't prevent the default file-buffer behavior).
		cmd = {
			select = function(item)
				if item and item.value then
					run_cmd(item.value)
				end
			end,
			-- Commands are plain strings; skip the default's cursor-position
			-- context and its relative-path handling for a nil name.
			create_list_item = function(_, name)
				return { value = name or "" }
			end,
		},
	},
	config = function(_, opts)
		local harpoon = require("harpoon")
		harpoon:setup(opts)

		-- The quick menu rewrites a list in place from the buffer text and
		-- announces it with LIST_CHANGE, which carries no list argument — so
		-- persist the command list on any such edit. A redundant write when
		-- the file list was the one edited is harmless.
		harpoon:extend({
			LIST_CHANGE = function()
				if cmd_store then
					save_cmds()
				end
			end,
		})

		vim.api.nvim_create_autocmd("VimLeavePre", {
			group = vim.api.nvim_create_augroup("HarpoonGlobalCommands", { clear = true }),
			callback = function()
				if cmd_store then
					save_cmds()
				end
			end,
		})
	end,
	keys = {
		-- File Bookmarks (per directory)
		{
			"<leader>ha",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Add file to list",
		},
		{
			"<leader>hh",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "File quick menu",
		},
		{
			"<leader>1",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "Harpoon file 1",
		},
		{
			"<leader>2",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "Harpoon file 2",
		},
		{
			"<leader>3",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "Harpoon file 3",
		},
		{
			"<leader>4",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "Harpoon file 4",
		},
		{
			"<leader>hn",
			function()
				require("harpoon"):list():next()
			end,
			desc = "Next file in list",
		},
		{
			"<leader>hp",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Previous file in list",
		},

		-- Command Bookmarks (global, shared across every project and session)
		{
			"<leader>hc",
			function()
				vim.ui.input(
					{ prompt = "Add Harpoon Command (prefix with ':' to run as Vim command, else runs in a terminal): " },
					function(input)
						if input and input ~= "" then
							cmd_list():add({ value = input })
							save_cmds()
						end
					end
				)
			end,
			desc = "Add command to list",
		},
		{
			"<leader>hm",
			function()
				require("harpoon").ui:toggle_quick_menu(cmd_list())
			end,
			desc = "Command quick menu",
		},
		{
			"<leader>6",
			function()
				cmd_list():select(1)
			end,
			desc = "Run command 1",
		},
		{
			"<leader>7",
			function()
				cmd_list():select(2)
			end,
			desc = "Run command 2",
		},
		{
			"<leader>8",
			function()
				cmd_list():select(3)
			end,
			desc = "Run command 3",
		},
		{
			"<leader>9",
			function()
				cmd_list():select(4)
			end,
			desc = "Run command 4",
		},
	},
}
