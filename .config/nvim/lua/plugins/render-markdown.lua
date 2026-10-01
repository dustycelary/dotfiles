-- render-markdown.nvim — in-buffer markdown rendering: styled headings,
-- concealed syntax markers, code block backgrounds, list bullets, checkboxes.
-- Only loads for markdown buffers. Toggle with <leader>um.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle render markdown" },
	},
}
