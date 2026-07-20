-- render-markdown.nvim — renders markdown in-buffer: styled headings, concealed syntax,
-- code block backgrounds, list bullets, and checkboxes. Only active in markdown buffers.
-- <leader>um toggles render-markdown on/off.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "markdown" },
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Render Markdown" },
	},
	opts = {
		html = {
			comment = {
				conceal = false,
			},
		},
	},
}
