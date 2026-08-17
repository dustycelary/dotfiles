-- trouble.nvim — pretty diagnostics, references, telescope/fzf results, quickfix, and location lists.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics (Trouble)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
		{ "<leader>xe", function() vim.diagnostic.open_float() end, desc = "Show Diagnostic Popup" },
		{ "<leader>xd", function() require("fzf-lua").lsp_document_diagnostics() end, desc = "Document Diagnostics (Fzf)" },
		{ "<leader>xD", function() require("fzf-lua").lsp_workspace_diagnostics() end, desc = "Workspace Diagnostics (Fzf)" },
		{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Outline)" },
		{
			"<leader>xl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions/References",
		},
		{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
	},
}
