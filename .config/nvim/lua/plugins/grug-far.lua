-- grug-far.nvim — project-wide search & replace in a buffer (ripgrep-backed).
-- Fill in Search / Replace / Files filter, results update live; <localleader>r
-- applies the replacement to every match. g? inside shows all its keys.
-- <leader>rr opens it prefilled with the word under the cursor (or the visual
-- selection); <leader>rf limits it to the current file.
return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {},
	keys = {
		{
			"<leader>rr",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Replace in project",
		},
		{
			"<leader>rr",
			function()
				require("grug-far").with_visual_selection()
			end,
			mode = "x",
			desc = "Replace selection in project",
		},
		{
			"<leader>rf",
			function()
				require("grug-far").open({
					prefills = { search = vim.fn.expand("<cword>"), paths = vim.fn.expand("%") },
				})
			end,
			desc = "Replace in current file",
		},
	},
}
