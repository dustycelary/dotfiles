-- [[ Editor ]]
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Insert new line below without splitting line" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- [[ Diagnostics ]]
-- Defined here (not inside lsp.lua's lazy-loaded config) so they exist
-- even before any LSP client has attached.
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

-- [[ Navigation ]]
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory with Oil" })

-- [[ Clipboard ]]
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste clipboard" })

-- [[ Windows ]]
-- <C-hjkl> movement and <S-arrow> resizing live in plugins/smart-splits.lua so
-- they cross the nvim/tmux boundary. Everything below is split *management*,
-- which has no multiplexer involvement.
--
-- Note: <leader><space> is no longer `:b#` — it's the buffer switcher (see
-- fzf-lua.lua). Plain <C-^> is still the native alternate-buffer jump.
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "Close window" })
vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Close all other windows" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize window sizes" })

-- Zoom toggle. `equalalways` re-balances on every split/close, so rather than
-- trying to save and restore exact dimensions this just re-maximizes or
-- re-equalizes; the tab-scoped flag keeps the state per layout.
vim.keymap.set("n", "<leader>wz", function()
	if vim.t.zoomed then
		vim.cmd("wincmd =")
		vim.t.zoomed = nil
	else
		vim.cmd("wincmd |")
		vim.cmd("wincmd _")
		vim.t.zoomed = true
	end
end, { desc = "Toggle zoom current window" })

-- [[ Bookmarks — global & persistent, see lua/bookmarks.lua ]]
vim.keymap.set("n", "<leader>mm", function()
	require("bookmarks").pick()
end, { desc = "Find bookmark" })
vim.keymap.set("n", "<leader>ma", function()
	require("bookmarks").add()
end, { desc = "Bookmark current file/dir" })
vim.keymap.set("n", "<leader>mc", function()
	require("bookmarks").add_cwd()
end, { desc = "Bookmark cwd" })

-- [[ Quickfix & Location List ]]
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix panel" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix panel" })
vim.keymap.set("n", "<leader>fq", function()
	require("fzf-lua").quickfix()
end, { desc = "Fuzzy search quickfix list" })

vim.keymap.set("n", "<leader>lo", "<cmd>lopen<CR>", { desc = "Open location list panel" })
vim.keymap.set("n", "<leader>lc", "<cmd>lclose<CR>", { desc = "Close location list panel" })
vim.keymap.set("n", "<leader>fl", function()
	require("fzf-lua").loclist()
end, { desc = "Fuzzy search location list" })

-- Close quickfix/loclist window with 'q' when focused inside it
local qf_augroup = vim.api.nvim_create_augroup("QuickfixKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = qf_augroup,
	pattern = "qf",
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close quickfix" })
	end,
})

-- [[ Terminal ]]
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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
