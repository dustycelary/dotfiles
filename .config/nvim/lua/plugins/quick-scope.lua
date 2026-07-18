-- quick-scope — highlights the best f/F/t/T jump targets on each line.
-- Underlines the first unique character per word when you press f/F/t/T.
return {
	"unblevable/quick-scope",
	event = "VeryLazy",
	init = function()
		vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
	end,
}
