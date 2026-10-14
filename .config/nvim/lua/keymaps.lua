-- [[ Editor ]]
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Insert line below without splitting" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- [[ Spelling ]]
-- Markdown turns spell on by itself (config.lua); this flips it anywhere.
vim.keymap.set("n", "<leader>us", function()
	vim.opt_local.spell = not vim.wo.spell
	vim.notify(
		"Spell check: " .. (vim.wo.spell and "ON" or "OFF") .. " (this buffer)",
		vim.log.levels.INFO,
		{ title = "Spell" }
	)
end, { desc = "Toggle spell check (buffer)" })

-- Suggestions in a fuzzy picker; a count (1z=) still takes that suggestion
-- straight away, like the built-in.
vim.keymap.set("n", "z=", function()
	if vim.v.count > 0 then
		vim.cmd("normal! " .. vim.v.count .. "z=")
	else
		require("fzf-lua").spell_suggest()
	end
end, { desc = "Spelling suggestions" })

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
