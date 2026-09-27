-- Harpoon 2 — fast file & command bookmarks & navigation.
-- Files are scoped to the current directory (harpoon's normal per-project
-- behavior). Commands are shared globally across every project instead: the
-- "cmd" list's storage key is forced to a constant whenever it's the list
-- being touched, either directly (add/select, flagged via using_global_key)
-- or through the quick-menu UI (detected via ui.active_list.name == "cmd").
local GLOBAL_CMD_KEY = "__global_commands__"
local using_global_key = false

local function cmd_list()
	using_global_key = true
	local ok, list = pcall(function()
		return require("harpoon"):list("cmd")
	end)
	using_global_key = false
	if not ok then
		error(list)
	end
	return list
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
	},
	config = function(_, opts)
		local harpoon = require("harpoon")
		harpoon:setup(opts)

		-- Execute Harpoon commands when selected from the "cmd" list
		harpoon:extend({
			SELECT = function(cx)
				if cx.list and cx.list.name == "cmd" and cx.item and cx.item.value then
					local cmd = cx.item.value
					if cmd:sub(1, 1) == ":" then
						vim.cmd(cmd:sub(2))
					else
						vim.cmd("split | terminal " .. cmd)
					end
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
				vim.ui.input({ prompt = "Add Harpoon Command: " }, function(input)
					if input and input ~= "" then
						cmd_list():add({ value = input })
					end
				end)
			end,
			desc = "Harpoon add command",
		},
		{
			"<leader>hm",
			function()
				require("harpoon").ui:toggle_quick_menu(cmd_list())
			end,
			desc = "Harpoon command quick menu",
		},
		{
			"<leader>h1",
			function()
				cmd_list():select(1)
			end,
			desc = "Harpoon run command 1",
		},
		{
			"<leader>h2",
			function()
				cmd_list():select(2)
			end,
			desc = "Harpoon run command 2",
		},
		{
			"<leader>h3",
			function()
				cmd_list():select(3)
			end,
			desc = "Harpoon run command 3",
		},
		{
			"<leader>h4",
			function()
				cmd_list():select(4)
			end,
			desc = "Harpoon run command 4",
		},
	},
}
