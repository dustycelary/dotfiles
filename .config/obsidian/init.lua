-- Vim Motions (Obsidian) config: copy to <vault>/init.lua.
-- Built in already, so not remapped here: which-key, <leader>f… pickers,
-- <leader>h…/<leader>1-9 harpoon, flash on s, oil, jumplist, surround.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- ...unless the pattern has a capital

local map = vim.keymap.set
local function ob(id)
	return ":obcommand " .. id .. "<CR>"
end

-- [[ Windows ]]
map("n", "<leader>wv", ":vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>ws", ":split<CR>", { desc = "Split horizontal" })
map("n", "<leader>wq", ob("workspace:close"), { desc = "Close window" })
map("n", "<leader>wo", ob("workspace:close-others"), { desc = "Close all other windows" })
map("n", "<C-h>", ob("editor:focus-left"), { desc = "Focus split left" })
map("n", "<C-j>", ob("editor:focus-bottom"), { desc = "Focus split down" })
map("n", "<C-k>", ob("editor:focus-top"), { desc = "Focus split up" })
map("n", "<C-l>", ob("editor:focus-right"), { desc = "Focus split right" })

-- [[ Buffers → tabs ]]
map("n", "<S-l>", ob("workspace:next-tab"), { desc = "Next buffer" })
map("n", "<S-h>", ob("workspace:previous-tab"), { desc = "Previous buffer" })
map("n", "<leader>bp", ob("workspace:toggle-pin"), { desc = "Toggle pin" })
map("n", "<leader><space>", ":Picker buffers<CR>", { desc = "Switch buffer" })

-- [[ Links (LSP-ish) ]]
map("n", "gd", ob("editor:follow-link"), { desc = "Follow link" })
map("n", "gD", ob("editor:open-link-in-new-split"), { desc = "Follow link in split" })
map("n", "go", ":Picker outline<CR>", { desc = "Document symbols" })
map("n", "<leader>cn", ob("workspace:edit-file-title"), { desc = "Rename note" })

-- [[ Bookmarks ]]
map("n", "<leader>ma", ob("bookmarks:bookmark-current-view"), { desc = "Bookmark note" })
map("n", "<leader>mm", ob("bookmarks:open"), { desc = "Find bookmark" })

-- [[ Toggles ]]
map("n", "<leader>um", ob("editor:toggle-source"), { desc = "Toggle render markdown" })
