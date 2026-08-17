vim.keymap.set("t", "<C-]>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

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

-- [[ Windows ]]
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<S-Right>", "2<C-w><", { desc = "Decrease window width" })
vim.keymap.set("n", "<S-Left>", "2<C-w>>", { desc = "Increase window width" })
vim.keymap.set("n", "<S-Up>", "2<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<S-Down>", "2<C-w>-", { desc = "Decrease window height" })
vim.keymap.set("n", "<leader><space>", "<cmd>b#<cr>", { desc = "Toggle last active buffer" })

vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", { desc = "Close window" })

-- [[ Tab Pages ]]
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab page" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab page" })

-- Equalize windows while preserving the aerial sidebar width

-- [[ Terminal ]]
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ UI toggles ]]
vim.keymap.set("n", "<leader>ua", "<cmd>AerialToggle!<CR>", { desc = "Toggle symbol sidebar (aerial)" })

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
