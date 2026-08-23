-- Harpoon 2 — fast file & command bookmarks & navigation.
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		settings = {
			save_on_toggle = true,
			sync_on_ui_close = true,
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
		-- File Bookmarks
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

		-- Command Bookmarks
		{
			"<leader>hc",
			function()
				vim.ui.input({ prompt = "Add Harpoon Command: " }, function(input)
					if input and input ~= "" then
						require("harpoon"):list("cmd"):add({ value = input })
					end
				end)
			end,
			desc = "Harpoon add command",
		},
		{
			"<leader>hm",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list("cmd"))
			end,
			desc = "Harpoon command quick menu",
		},
		{
			"<leader>h1",
			function()
				require("harpoon"):list("cmd"):select(1)
			end,
			desc = "Harpoon run command 1",
		},
		{
			"<leader>h2",
			function()
				require("harpoon"):list("cmd"):select(2)
			end,
			desc = "Harpoon run command 2",
		},
		{
			"<leader>h3",
			function()
				require("harpoon"):list("cmd"):select(3)
			end,
			desc = "Harpoon run command 3",
		},
		{
			"<leader>h4",
			function()
				require("harpoon"):list("cmd"):select(4)
			end,
			desc = "Harpoon run command 4",
		},
	},
}
