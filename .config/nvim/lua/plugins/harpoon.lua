-- Global Harpoon file bookmarks and command shortcuts.
-- Commands beginning with ":" run in Neovim; all others run in tmux/a terminal split.

local function harpoon()
	return require("harpoon")
end

local function list(name)
	return harpoon():list(name)
end

local function select(name, index)
	return function()
		list(name):select(index)
	end
end

local function run_in_tmux(command)
	local current = vim.env.TMUX_PANE
	if not current or current == "" then
		return false
	end

	local panes = vim.fn.systemlist("tmux list-panes -F '#{pane_id}'")
	local target = vim.iter(panes):find(function(pane)
		return pane ~= current
	end)

	if not target then
		target = vim.trim(vim.fn.system("tmux split-window -v -p 30 -d -P -F '#{pane_id}'"))
	end
	if target == "" then
		return false
	end

	vim.fn.system({ "tmux", "send-keys", "-t", target, "C-c" })
	vim.fn.system({ "tmux", "send-keys", "-t", target, command, "C-m" })
	return true
end

local function run_in_terminal(command)
	local buffer = vim.fn.bufnr("^harpoon-term$")
	local window = buffer ~= -1 and vim.fn.bufwinid(buffer) or -1

	if buffer == -1 then
		vim.cmd("botright split | terminal")
		buffer = vim.api.nvim_get_current_buf()
		window = vim.api.nvim_get_current_win()
		vim.api.nvim_buf_set_name(buffer, "harpoon-term")
	elseif window == -1 then
		vim.cmd("botright split")
		window = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(window, buffer)
	end

	vim.api.nvim_chan_send(vim.bo[buffer].channel, command .. "\n")
	vim.api.nvim_set_current_win(window)
	vim.cmd.startinsert()
end

local function run_ex(command)
	command = command:sub(2)
	local view = vim.fn.winsaveview()
	vim.fn.histadd("cmd", command)
	local ok, err = pcall(vim.cmd, command)
	vim.fn.winrestview(view)
	if not ok then
		error(err)
	end
end

local keys = {
	{
		"<leader>ha",
		function()
			list():add()
		end,
		desc = "Harpoon add file",
	},
	{
		"<leader>hh",
		function()
			harpoon().ui:toggle_quick_menu(list())
		end,
		desc = "Harpoon file menu",
	},
	{
		"<leader>hn",
		function()
			list():next()
		end,
		desc = "Harpoon next file",
	},
	{
		"<leader>hp",
		function()
			list():prev()
		end,
		desc = "Harpoon previous file",
	},
	{
		"<leader>hc",
		function()
			harpoon().ui:toggle_quick_menu(list("cmd"))
		end,
		desc = "Harpoon command menu",
	},
	{
		"<leader>hC",
		function()
			vim.ui.input({ prompt = "Add command: " }, function(command)
				if command and command ~= "" then
					list("cmd"):add(command)
					vim.notify("Added command: " .. command, vim.log.levels.INFO, { title = "Harpoon" })
				end
			end)
		end,
		desc = "Harpoon add command",
	},
}

for index = 1, 4 do
	table.insert(keys, {
		"<leader>" .. index,
		select(nil, index),
		desc = "Harpoon file " .. index,
	})
	table.insert(keys, {
		"<leader>x" .. index,
		select("cmd", index),
		desc = "Harpoon run command " .. index,
	})
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = keys,
	config = function()
		harpoon():setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
				key = function()
					return "__global_harpoon__"
				end,
			},
			default = {
				create_list_item = function(_, name)
					local path = name
					if not path or path == "" then
						path = vim.api.nvim_buf_get_name(0)
					end
					if path == "" then
						return nil
					end
					path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))

					local bufnr = vim.fn.bufnr(path, false)
					local pos = { 1, 0 }
					if bufnr ~= -1 and bufnr == vim.api.nvim_get_current_buf() then
						pos = vim.api.nvim_win_get_cursor(0)
					end

					return {
						value = path,
						context = {
							row = pos[1],
							col = pos[2],
						},
					}
				end,
				BufLeave = function(arg, list)
					local bufnr = arg.buf
					local bufname = vim.fs.normalize(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p"))
					local item = list:get_by_value(bufname)
					if item then
						local pos = vim.api.nvim_win_get_cursor(0)
						item.context.row = pos[1]
						item.context.col = pos[2]
					end
				end,
				display = function(item)
					return vim.fn.fnamemodify(item.value, ":~:.")
				end,
			},
			cmd = {
				create_list_item = function(_, item)
					return type(item) == "table" and item or { value = item }
				end,
				display = function(item)
					return type(item) == "table" and item.value or tostring(item)
				end,
				select = function(item)
					local command = type(item) == "table" and item.value or item
					if vim.startswith(command, ":") then
						run_ex(command)
					elseif not run_in_tmux(command) then
						run_in_terminal(command)
					end
				end,
			},
		})
	end,
}
