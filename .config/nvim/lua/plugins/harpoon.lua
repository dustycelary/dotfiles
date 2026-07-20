-- harpoon2 — quick-access bookmarks for up to 4 files per project.
-- <leader>ha adds current file; <leader>hh opens the menu.
-- <leader>1-4 jump directly to slots. <leader>hn/<leader>hp cycle through the list.
-- Custom command runner additions:
-- <leader>hc toggles command menu; <leader>hC prompts for a command to append.
-- <leader>x1 to <leader>x4 executes the terminal commands in slots 1 to 4.
-- List is saved on toggle (save_on_toggle = true) so no explicit save needed.
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		local function run_in_tmux(command)
			local current_pane = vim.env.TMUX_PANE
			if not current_pane or current_pane == "" then
				return false
			end

			local panes_str = vim.fn.system("tmux list-panes -F '#{pane_id}'")
			local panes = {}
			for pane in string.gmatch(panes_str, "[^\r\n]+") do
				table.insert(panes, pane)
			end

			local target_pane = nil
			if #panes == 1 then
				-- Only Neovim pane exists. Split vertically at 30% height, keeping focus on Neovim
				local new_pane = vim.fn.system("tmux split-window -v -p 30 -d -P -F '#{pane_id}'")
				target_pane = string.gsub(new_pane, "%s+$", "")
			else
				-- Target the other pane (or first non-Neovim pane)
				for _, p in ipairs(panes) do
					if p ~= current_pane then
						target_pane = p
						break
					end
				end
			end

			if target_pane and target_pane ~= "" then
				-- Cancel any active process/command in the target pane, then execute the new one
				vim.fn.system("tmux send-keys -t " .. target_pane .. " C-c")
				vim.fn.system("tmux send-keys -t " .. target_pane .. " " .. vim.fn.shellescape(command) .. " C-m")
				return true
			end
			return false
		end

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
				key = function()
					return vim.fs.root(0, ".git") or vim.loop.cwd()
				end,
			},
			cmd = {
				create_list_item = function(config, name)
					if type(name) == "table" and name.value then
						return name
					end
					return {
						value = name,
					}
				end,
				select = function(list_item, list, option)
					local command = list_item.value

					-- Try running in Tmux pane first
					if run_in_tmux(command) then
						return
					end

					-- Fallback to Neovim terminal split
					local term_buf = nil
					-- Find if a harpoon-term buffer already exists
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.bo[buf].buftype == "terminal" and vim.fn.bufname(buf):find("harpoon-term") then
							term_buf = buf
							break
						end
					end

					local win
					if term_buf and vim.fn.bufexists(term_buf) == 1 then
						local win_found = false
						for _, w in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_get_buf(w) == term_buf then
								win = w
								win_found = true
								break
							end
						end
						if not win_found then
							vim.cmd("botright split")
							win = vim.api.nvim_get_current_win()
							vim.api.nvim_win_set_buf(win, term_buf)
						end
					else
						vim.cmd("botright split | term")
						win = vim.api.nvim_get_current_win()
						term_buf = vim.api.nvim_win_get_buf(win)
						vim.api.nvim_buf_set_name(term_buf, "harpoon-term")
					end

					-- Send command to terminal
					local chan = vim.bo[term_buf].channel
					if chan and chan > 0 then
						vim.api.nvim_chan_send(chan, command .. "\n")
					end

					vim.api.nvim_set_current_win(win)
					vim.cmd("startinsert")
				end,
			},
		})
	end,
	keys = {
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
			desc = "Harpoon menu",
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
			desc = "Harpoon next",
		},
		{
			"<leader>hp",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Harpoon prev",
		},
		{
			"<leader>hc",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list("cmd"))
			end,
			desc = "Harpoon command menu",
		},
		{
			"<leader>hC",
			function()
				vim.ui.input({ prompt = "Add terminal command: " }, function(input)
					if input and input ~= "" then
						require("harpoon"):list("cmd"):add(input)
						vim.notify("Added command: " .. input, vim.log.levels.INFO, { title = "Harpoon" })
					end
				end)
			end,
			desc = "Harpoon add command",
		},
		{
			"<leader>x1",
			function()
				require("harpoon"):list("cmd"):select(1)
			end,
			desc = "Harpoon run command 1",
		},
		{
			"<leader>x2",
			function()
				require("harpoon"):list("cmd"):select(2)
			end,
			desc = "Harpoon run command 2",
		},
		{
			"<leader>x3",
			function()
				require("harpoon"):list("cmd"):select(3)
			end,
			desc = "Harpoon run command 3",
		},
		{
			"<leader>x4",
			function()
				require("harpoon"):list("cmd"):select(4)
			end,
			desc = "Harpoon run command 4",
		},
	},
}
