vim.keymap.set("t", "<C-]>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

vim.keymap.set("n", "<leader>uq", function()
	local file = vim.api.nvim_buf_get_name(0)
	if file ~= "" then
		local cmd = string.format(
			'qlmanage -p %s >/dev/null 2>&1 & sleep 0.05 && osascript -e \'tell application "System Events" to set frontmost of process "qlmanage" to true\'',
			vim.fn.shellescape(file)
		)
		vim.fn.jobstart(cmd)
	end
end, { desc = "Quick Look markdown preview" })

-- [[ Editor ]]
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Insert new line below without splitting line" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- [[ Horizontal scrolling ]]
vim.keymap.set("n", "<M-.>", "5zl", { desc = "Scroll view right" })
vim.keymap.set("n", "<M-,>", "5zh", { desc = "Scroll view left" })

-- [[ Navigation ]]
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory with Oil" })

-- [[ Clipboard ]]
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste clipboard" })
vim.keymap.set("n", "<leader>Y", function()
	local path = vim.fn.expand("%:p")
	if path == "" then
		path = vim.fn.getcwd()
	end
	vim.fn.setreg("+", path)
	vim.notify(path, vim.log.levels.INFO, { title = "Copied to clipboard" })
end, { desc = "Copy file path" })

-- [[ Windows ]]
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<M-H>", "2<C-w><", { desc = "Decrease window width" })
vim.keymap.set("n", "<M-L>", "2<C-w>>", { desc = "Increase window width" })
vim.keymap.set("n", "<M-K>", "2<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<M-J>", "2<C-w>-", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "2<C-w><", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "2<C-w>>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-Up>", "2<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "2<C-w>-", { desc = "Decrease window height" })
vim.keymap.set("n", "<leader><space>", "<cmd>b#<cr>", { desc = "Toggle last active buffer" })

vim.keymap.set("n", "<leader>w-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wh", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>w|", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close split window" })
vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", { desc = "Close window" })

-- [[ Tab Pages ]]
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab page" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab page" })

-- Equalize windows while preserving the aerial sidebar width
vim.keymap.set("n", "<C-w>=", function()
	local aerial_win, aerial_width
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local cfg = vim.api.nvim_win_get_config(win)
		if cfg.relative == "" then
			local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
			if ft == "aerial" then
				aerial_win = win
				aerial_width = vim.api.nvim_win_get_width(win)
				break
			end
		end
	end
	vim.cmd("wincmd =")
	if aerial_win and aerial_width then
		vim.api.nvim_win_set_width(aerial_win, aerial_width)
	end
end, { desc = "Equalize windows" })

-- [[ Terminal ]]
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ UI toggles ]]
vim.keymap.set("n", "<leader>ua", "<cmd>AerialToggle!<CR>", { desc = "Toggle symbol sidebar (aerial)" })
vim.keymap.set("n", "<leader>uz", function()
	if vim.t.is_zoomed then
		vim.cmd("tabclose")
	else
		vim.cmd("tab split")
		vim.t.is_zoomed = true
	end
end, { desc = "Toggle window zoom (maximize split)" })

vim.keymap.set("n", "<leader>ui", function()
	local current = vim.bo.shiftwidth
	local new_size = (current == 2) and 4 or 2
	vim.bo.shiftwidth = new_size
	vim.bo.tabstop = new_size
	vim.bo.softtabstop = new_size
	vim.notify("Indent size set to " .. new_size, vim.log.levels.INFO, { title = "Indentation" })
end, { desc = "Toggle indent size (2 <-> 4)" })

-- Repeat the latest Ex (:) command, including commands run from Harpoon via vim.cmd().
vim.keymap.set("n", "<leader>.", function()
	local command = vim.fn.histget("cmd", -1)
	if command == "" then
		vim.notify("No Ex command to repeat", vim.log.levels.WARN)
		return
	end

	local view = vim.fn.winsaveview()
	local ok, err = pcall(vim.cmd, command)
	vim.fn.winrestview(view)
	if not ok then
		error(err)
	end
end, { desc = "Repeat last Ex command" })

vim.keymap.set("n", "<leader>uc", function()
	if vim.g.colors_name == "catppuccin-latte" or vim.g.colors_name == "catppuccin" then
		vim.o.background = "dark"
		vim.cmd.colorscheme("carbonfox")
		vim.api.nvim_set_hl(0, "Visual", { bg = "#4c4f69", fg = "#eff1f5", bold = true })
		vim.notify("Colorscheme: carbonfox (dark)", vim.log.levels.INFO, { title = "Colorscheme" })
	else
		vim.o.background = "light"
		vim.cmd.colorscheme("catppuccin-latte")
		vim.notify("Colorscheme: catppuccin-latte (light)", vim.log.levels.INFO, { title = "Colorscheme" })
	end
end, { desc = "Toggle colorscheme (catppuccin-latte light <-> carbonfox dark)" })

-- [[ Code / LSP ]]
-- Replace: buffer-local word under cursor
vim.keymap.set("n", "<leader>cr", function()
	local word = vim.fn.expand("<cword>")
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes(":%s/" .. word .. "/" .. word .. "/gI<Left><Left><Left>", true, false, true),
		"n",
		false
	)
end, { desc = "Replace word (buffer)" })

-- Replace: project-wide via fzf-lua grep → quickfix → cfdo
vim.keymap.set("n", "<leader>cR", function()
	local fzf = require("fzf-lua")
	vim.ui.input({ prompt = "Search: " }, function(search)
		if not search or search == "" then
			return
		end
		vim.ui.input({ prompt = "Replace with: " }, function(replacement)
			if replacement == nil then
				return
			end
			fzf.grep({
				search = search,
				actions = {
					["default"] = function(selected)
						-- Send matches to quickfix then replace across all files
						fzf.actions.file_sel_to_qf(selected)
						vim.schedule(function()
							vim.cmd(
								string.format(
									"cfdo %%s/%s/%s/gI | update",
									vim.fn.escape(search, "/"),
									vim.fn.escape(replacement, "/")
								)
							)
						end)
					end,
				},
			})
		end)
	end)
end, { desc = "Replace word (project)" })
