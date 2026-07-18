-- conform.nvim — format on save.
-- Formatters: ruff (py), stylua (lua), clang-format (c/json), prettier (yaml),
--             djlint (htmldjango), markdownlint (md), jq -c (jsonl).
-- Non-obvious: jsonl uses a custom jq formatter that compacts each line.
-- <leader>cf to format manually. Timeout 2s before giving up.
return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				htmldjango = { "djlint" },
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
				json = { "clang-format" },
				c = { "clang-format" },
				lua = { "stylua" },
				jsonl = { "jq_jsonl" },
				markdown = { "markdownlint" },
				yaml = { "prettier" },
			},
			formatters = {
				jq_jsonl = {
					command = "jq",
					args = { "-c", "." }, -- compact output (one object per line)
					stdin = true,
				},
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		})

		vim.keymap.set("n", "<leader>cf", function()
			require("conform").format({ async = true })
		end, { desc = "Format file" })
	end,
}
