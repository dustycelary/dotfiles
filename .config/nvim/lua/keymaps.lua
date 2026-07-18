-- [[ Terminal ]]
vim.keymap.set("t", "<C-]>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ Editor ]]
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("n", "<C-CR>", "o", { desc = "Insert line below" })
vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Insert line below" })
vim.keymap.set("i", "<S-CR>", "<C-o>$", { desc = "Move cursor to last character of line" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "S", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local prev_indent = ""
	if row > 1 then
		local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
		prev_indent = prev_line:match("^(%s*)") or ""
	end
	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { prev_indent })
	vim.api.nvim_win_set_cursor(0, { row, #prev_indent })
	vim.cmd("startinsert!")
end, { desc = "Re-indent to match line above and insert" })

vim.keymap.set("n", "zF", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local prev_row
	repeat
		prev_row = row
		vim.cmd("normal! [z")
		row = vim.api.nvim_win_get_cursor(0)[1]
	until row == prev_row
	vim.cmd("normal! zC")
end, { desc = "Close outermost enclosing fold" })

-- [[ Horizontal scrolling ]]
vim.keymap.set("n", "<M-.>", "5zl", { desc = "Scroll view right" })
vim.keymap.set("n", "<M-,>", "5zh", { desc = "Scroll view left" })

-- [[ Navigation ]]
vim.keymap.set("n", "-", function()
	vim.cmd("edit " .. vim.fn.expand("%:p:h"))
end, { desc = "Open parent directory" })

vim.keymap.set("n", "<leader>cd", function()
	local path = vim.fn.expand("%:p:h")
	vim.cmd("cd " .. path)
	vim.notify(path, vim.log.levels.INFO, { title = "Changed CWD" })
end, { desc = "cd to current file's dir" })

-- [[ Clipboard ]]
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste clipboard" })
vim.keymap.set("v", "<leader>P", '"_dP', { desc = "Replace selection with clipboard" })
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
vim.keymap.set("n", "<C-q>", "<C-w>q", { desc = "Close window" })

vim.keymap.set("n", "<M-H>", "2<C-w><", { desc = "Decrease window width" })
vim.keymap.set("n", "<M-L>", "2<C-w>>", { desc = "Increase window width" })
vim.keymap.set("n", "<M-K>", "2<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<M-J>", "2<C-w>-", { desc = "Decrease window height" })

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
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- [[ Buffers & Tabs ]]
vim.keymap.set("n", "<M-Space>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-Space>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>ba", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Close all other buffers" })

vim.keymap.set("n", "<leader>bt", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>bq", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>b]", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>b[", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>bo", "<cmd>tabonly<CR>", { desc = "Close all other tabs" })
vim.keymap.set("n", "<leader>bm", ":tabmove ", { desc = "Move tab" })

-- [[ UI toggles ]]
vim.keymap.set("n", "<leader>ui", function()
	local current = vim.bo.shiftwidth
	local new_size = (current == 2) and 4 or 2
	vim.bo.shiftwidth = new_size
	vim.bo.tabstop = new_size
	vim.bo.softtabstop = new_size
	vim.notify("Indent size set to " .. new_size, vim.log.levels.INFO, { title = "Indentation" })
end, { desc = "Toggle indent size (2 <-> 4)" })

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

vim.keymap.set("n", "<leader>cT", function()
	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	if not ok or not parser then
		vim.notify("No treesitter parser active", vim.log.levels.WARN, { title = "Treesitter" })
		return
	end
	local lines = { parser:lang() }
	for lang, _ in pairs(parser:children()) do
		table.insert(lines, "  " .. lang .. " (injected)")
	end
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Treesitter" })
end, { desc = "Treesitter info" })
