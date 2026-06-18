-- render-markdown.nvim — renders markdown in-buffer: styled headings, concealed syntax,
-- code block backgrounds, list bullets, and checkboxes. Only active in markdown buffers.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "markdown" },
	opts = {},
}
