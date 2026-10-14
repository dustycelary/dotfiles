-- render-markdown.nvim — in-buffer markdown rendering: styled headings,
-- concealed syntax markers, code block backgrounds, list bullets, checkboxes.
-- HTML comments stay visible (todo notes). Only loads for markdown buffers.
-- Toggle for the current buffer with <leader>um.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	opts = {
		-- Keep <!-- TODO: … --> visible so todo-comments can highlight them.
		html = { comment = { conceal = false } },
		-- A bare "- [ ]" with no text yet parses as a bullet + empty link, not a
		-- task, so its brackets get concealed. Render it as a checkbox anyway.
		checkbox = {
			custom = {
				empty = { raw = "[ ]", rendered = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
			},
		},
	},
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", desc = "Toggle render markdown (buffer)" },
	},
}
