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
			format_on_save = function(bufnr)
				-- Disable format-on-save with global or buffer-local flags
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
		})

		vim.keymap.set("n", "<leader>cf", function()
			require("conform").format({ async = true })
		end, { desc = "Format file" })

		-- Keymap: Toggle format-on-save for the active buffer
		vim.keymap.set("n", "<leader>ut", function()
			vim.b.disable_autoformat = not vim.b.disable_autoformat
			local status = vim.b.disable_autoformat and "Disabled" or "Enabled"
			vim.notify(status .. " format-on-save for active buffer", vim.log.levels.INFO, { title = "Conform" })
		end, { desc = "Toggle format-on-save (buffer)" })

		-- User commands to disable / enable / toggle format-on-save
		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.g.disable_autoformat = true
				vim.notify("Disabled format-on-save globally", vim.log.levels.INFO, { title = "Conform" })
			else
				vim.b.disable_autoformat = true
				vim.notify("Disabled format-on-save for active buffer", vim.log.levels.INFO, { title = "Conform" })
			end
		end, { desc = "Disable format-on-save (add ! for global)", bang = true })

		vim.api.nvim_create_user_command("FormatEnable", function(args)
			if args.bang then
				vim.g.disable_autoformat = false
				vim.notify("Enabled format-on-save globally", vim.log.levels.INFO, { title = "Conform" })
			else
				vim.b.disable_autoformat = false
				vim.notify("Enabled format-on-save for active buffer", vim.log.levels.INFO, { title = "Conform" })
			end
		end, { desc = "Enable format-on-save (add ! for global)", bang = true })

		vim.api.nvim_create_user_command("FormatToggle", function(args)
			if args.bang then
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				local status = vim.g.disable_autoformat and "Disabled" or "Enabled"
				vim.notify(status .. " format-on-save globally", vim.log.levels.INFO, { title = "Conform" })
			else
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				local status = vim.b.disable_autoformat and "Disabled" or "Enabled"
				vim.notify(status .. " format-on-save for active buffer", vim.log.levels.INFO, { title = "Conform" })
			end
		end, { desc = "Toggle format-on-save (add ! for global)", bang = true })
	end,
}
