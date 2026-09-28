-- Harpoon 2 — fast file & command bookmarks & navigation.
-- Files are scoped to the current directory (harpoon's normal per-project
-- behavior). Commands are shared globally across every project instead: the
-- "cmd" list's storage key is forced to a constant for the *entire* duration
-- of any operation that touches that list (add/select/quick-menu), via
-- with_cmd_list() below. Anything narrower breaks persistence: Harpoon:sync()
-- re-derives the key independently when the ADD/REMOVE events fire, so if the
-- flag were reset before that happened, saves would silently land under the
-- current project's key instead of the global one.
local GLOBAL_CMD_KEY = "__global_commands__"
local using_global_key = false

local function with_cmd_list(fn)
	using_global_key = true
	local ok, result = pcall(function()
		return fn(require("harpoon"):list("cmd"))
	end)
	using_global_key = false
	if not ok then
		error(result)
	end
	return result
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
			key = function()
				if using_global_key then
					return GLOBAL_CMD_KEY
				end
				local ui = require("harpoon").ui
				if ui.active_list and ui.active_list.name == "cmd" then
					return GLOBAL_CMD_KEY
				end
				return vim.loop.cwd()
			end,
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
		},
	},
	config = function(_, opts)
		require("harpoon"):setup(opts)
	end,
	keys = {
		-- File Bookmarks (per directory)
		{
			"<leader>ha",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Harpoon add file",
		},
		{
			"<leader>hh",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Harpoon file quick menu",
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
			desc = "Harpoon next file",
		},
		{
			"<leader>hp",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Harpoon previous file",
		},

		-- Command Bookmarks (global, shared across every project)
		{
			"<leader>hc",
			function()
				vim.ui.input({ prompt = "Add Harpoon Command (prefix with ':' to run as Vim command, else runs in a terminal): " }, function(input)
					if input and input ~= "" then
						with_cmd_list(function(list)
							list:add({ value = input })
						end)
					end
				end)
			end,
			desc = "Harpoon add command",
		},
		{
			"<leader>hm",
			function()
				with_cmd_list(function(list)
					require("harpoon").ui:toggle_quick_menu(list)
				end)
			end,
			desc = "Harpoon command quick menu",
		},
		{
			"<leader>h1",
			function()
				with_cmd_list(function(list)
					list:select(1)
				end)
			end,
			desc = "Harpoon run command 1",
		},
		{
			"<leader>h2",
			function()
				with_cmd_list(function(list)
					list:select(2)
				end)
			end,
			desc = "Harpoon run command 2",
		},
		{
			"<leader>h3",
			function()
				with_cmd_list(function(list)
					list:select(3)
				end)
			end,
			desc = "Harpoon run command 3",
		},
		{
			"<leader>h4",
			function()
				with_cmd_list(function(list)
					list:select(4)
				end)
			end,
			desc = "Harpoon run command 4",
		},
	},
}
