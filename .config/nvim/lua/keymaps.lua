-- [[ Editor ]]
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Insert line below without splitting" })

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

-- [[ Clipboard ]]
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste clipboard" })

-- [[ Windows ]]
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

-- [[ Buffers ]]
-- bufferline.nvim is disabled on Pi (see its spec), so take over its keys
-- with the built-in :bnext/:bprev — same muscle memory, zero plugin cost.
if require("is_pi").is_pi then
	vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
	vim.keymap.set("n", "<S-h>", "<cmd>bprev<CR>", { desc = "Previous buffer" })
end

-- Bookmarks (<leader>m...) are registered by lua/bookmarks.lua's own setup(),
-- next to the functions they call.

-- [[ Quickfix & Location List ]]
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix panel" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix panel" })
vim.keymap.set("n", "<leader>fq", function()
	require("fzf-lua").quickfix()
end, { desc = "Search quickfix list" })

vim.keymap.set("n", "<leader>lo", "<cmd>lopen<CR>", { desc = "Open location list panel" })
vim.keymap.set("n", "<leader>lc", "<cmd>lclose<CR>", { desc = "Close location list panel" })
vim.keymap.set("n", "<leader>fl", function()
	require("fzf-lua").loclist()
end, { desc = "Search location list" })

-- Close quickfix/loclist window with 'q' when focused inside it
local qf_augroup = vim.api.nvim_create_augroup("QuickfixKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = qf_augroup,
	pattern = "qf",
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close quickfix panel" })
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
