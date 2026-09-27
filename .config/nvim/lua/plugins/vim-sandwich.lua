-- vim-sandwich — add, delete, replace surrounding pairs (brackets, quotes, tags, etc.).
-- <leader>wa  add surrounding    e.g. <leader>wa" wraps selection in quotes
-- <leader>wd  delete surrounding
-- <leader>wD  delete surrounding (auto-detect, no prompt)
-- <leader>wr  replace surrounding
-- <leader>wR  replace surrounding (auto-detect)
-- 'i' recipe lets you type arbitrary open/close strings when adding/replacing.
return {
	"machakann/vim-sandwich",
	init = function()
		-- disable the plugin's default "sa"/"sd"/"sdb"/"sr"/"srb" mappings:
		-- they clash with flash.nvim's plain "s"/"S" jump keys (ambiguous
		-- prefix). We keep our own <leader>s* mappings below instead.
		vim.g.operator_sandwich_no_default_key_mappings = 1
	end,
	config = function()
		vim.keymap.set({ "n", "x" }, "<leader>sa", "<Plug>(sandwich-add)", { desc = "Add surrounding" })
		vim.keymap.set("n", "<leader>sd", "<Plug>(sandwich-delete)", { desc = "Delete surrounding" })
		vim.keymap.set("n", "<leader>sD", "<Plug>(sandwich-delete-auto)", { desc = "Delete surrounding (auto-detect)" })
		vim.keymap.set("n", "<leader>sr", "<Plug>(sandwich-replace)", { desc = "Replace surrounding" })
		vim.keymap.set(
			"n",
			"<leader>sR",
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
