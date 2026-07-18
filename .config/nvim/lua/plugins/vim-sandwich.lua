-- vim-sandwich — add, delete, replace surrounding pairs (brackets, quotes, tags, etc.).
-- <leader>wa  add surrounding    e.g. <leader>wa" wraps selection in quotes
-- <leader>wd  delete surrounding
-- <leader>wD  delete surrounding (auto-detect, no prompt)
-- <leader>wr  replace surrounding
-- <leader>wR  replace surrounding (auto-detect)
-- 'i' recipe lets you type arbitrary open/close strings when adding/replacing.
return {
	"machakann/vim-sandwich",
	config = function()
		vim.keymap.set({ "n", "x" }, "<leader>wa", "<Plug>(sandwich-add)", { desc = "Add surrounding" })
		vim.keymap.set("n", "<leader>wd", "<Plug>(sandwich-delete)", { desc = "Delete surrounding" })
		vim.keymap.set("n", "<leader>wD", "<Plug>(sandwich-delete-auto)", { desc = "Delete surrounding (auto-detect)" })
		vim.keymap.set("n", "<leader>wr", "<Plug>(sandwich-replace)", { desc = "Replace surrounding" })
		vim.keymap.set(
			"n",
			"<leader>wR",
			"<Plug>(sandwich-replace-auto)",
			{ desc = "Replace surrounding (auto-detect)" }
		)

		vim.g["sandwich#recipes"] = vim.list_extend(vim.deepcopy(vim.g["sandwich#default_recipes"]), {
			-- 'i' prompts for arbitrary open/close strings
			{
				buns = { 'input("Open: ")', 'input("Close: ")' },
				expr = 1,
				input = { "i" },
				kind = { "add", "replace" },
			},
			-- HTML/Markdown comment
		})
	end,
}
