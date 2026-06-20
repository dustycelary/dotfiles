-- LSP setup — mason + mason-lspconfig + nvim-lspconfig.
-- Servers: basedpyright, lua_ls, clangd, html (+ htmldjango), bashls, marksman, dockerls, yamlls.
-- Non-obvious: yamlls uses schemastore for JSON schema validation; its formatter is disabled
--   (conform handles formatting). html registers for htmldjango filetype too.
-- basedpyright runs with typeCheckingMode=off and openFilesOnly to avoid noise.
-- Diagnostics virtual text/lines are OFF globally (init.lua) — tiny-inline-diagnostic handles display.
-- :LspInfo shows attached clients for the current buffer.
return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
		lazy = false,
		opts = {
			ensure_installed = {
				"html",
				"dockerls",
				"lua_ls",
				"marksman",
				"bashls",
				"basedpyright",
				-- "clangd",
				"yamlls",
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = { "b0o/schemastore.nvim" },
		config = function()
			local function lsp_info()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					vim.notify("No LSP clients attached", vim.log.levels.WARN, { title = "LSP" })
					return
				end
				local lines = {}
				for _, client in ipairs(clients) do
					table.insert(lines, client.name .. " (id=" .. client.id .. ")")
				end
				vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP clients" })
			end
			vim.api.nvim_create_user_command("LspInfo", lsp_info, { desc = "Show attached LSP clients" })
			vim.keymap.set("n", "<leader>ci", lsp_info, { desc = "LSP info" })

			-- lua_ls: lazydev.nvim handles neovim API type stubs automatically
			local servers = {
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "off",
								autoImportCompletions = true,
								diagnosticMode = "openFilesOnly",
							},
						},
						python = {
							pythonPath = vim.fn.exepath("python3"),
						},
					},
				},
				dockerls = { single_file_support = true },
				marksman = { single_file_support = true },
				lua_ls = {
					single_file_support = true,
					settings = { Lua = { telemetry = { enable = false } } },
				},
				html = {
					filetypes = { "html", "htmldjango" },
					root_markers = { "package.json", ".git" },
					single_file_support = true,
					init_options = { provideFormatter = false }, -- don't mangle Django template tags
				},
				bashls = {
					filetypes = { "sh", "bash", "zsh" },
					root_markers = { "package.json", ".git" },
					single_file_support = true,
				},
				clangd = {},
				yamlls = {
					single_file_support = true,
					settings = {
						yaml = {
							schemaStore = { enable = false, url = "" },
							schemas = require("schemastore").yaml.schemas(),
							validate = true,
						},
					},
				},
			}

			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "yamlls" then
						client.server_capabilities.documentFormattingProvider = false
					end

					vim.keymap.set("n", "grd", function()
						require("fzf-lua").lsp_definitions({ jump1 = true })
					end, { buffer = args.buf, desc = "Go to definition" })
					vim.keymap.set(
						"n",
						"grD",
						vim.lsp.buf.declaration,
						{ buffer = args.buf, desc = "Go to declaration" }
					)
					vim.keymap.set("n", "grr", function()
						require("fzf-lua").lsp_references()
					end, { buffer = args.buf, desc = "LSP references" })
					vim.keymap.set("n", "gri", function()
						require("fzf-lua").lsp_implementations({ jump1 = true })
					end, { buffer = args.buf, desc = "LSP implementations" })
					vim.keymap.set("n", "go", function()
						require("fzf-lua").lsp_document_symbols()
					end, { buffer = args.buf, desc = "Document symbols" })

					vim.keymap.set(
						"n",
						"<leader>cs",
						vim.lsp.buf.signature_help,
						{ buffer = args.buf, desc = "Signature help" }
					)

					vim.keymap.set("n", "<leader>cn", vim.lsp.buf.rename, { buffer = args.buf, desc = "Rename symbol" })
					vim.keymap.set(
						"n",
						"<leader>ca",
						vim.lsp.buf.code_action,
						{ buffer = args.buf, desc = "Code actions" }
					)
					vim.keymap.set(
						"v",
						"<leader>ca",
						vim.lsp.buf.code_action,
						{ buffer = args.buf, desc = "Code actions (range)" }
					)

					local rep = require("nvim-treesitter-textobjects.repeatable_move")
					local diag_move = rep.make_repeatable_move(function(opts)
						if opts.forward then
							vim.diagnostic.goto_next()
						else
							vim.diagnostic.goto_prev()
						end
					end)
					local err_move = rep.make_repeatable_move(function(opts)
						local diag_opts = { severity = vim.diagnostic.severity.ERROR }
						if opts.forward then
							vim.diagnostic.goto_next(diag_opts)
						else
							vim.diagnostic.goto_prev(diag_opts)
						end
					end)
					vim.keymap.set("n", "[d", function()
						diag_move({ forward = false })
					end, { buffer = args.buf, desc = "Previous diagnostic" })
					vim.keymap.set("n", "]d", function()
						diag_move({ forward = true })
					end, { buffer = args.buf, desc = "Next diagnostic" })
					vim.keymap.set("n", "[e", function()
						err_move({ forward = false })
					end, { buffer = args.buf, desc = "Previous error" })
					vim.keymap.set("n", "]e", function()
						err_move({ forward = true })
					end, { buffer = args.buf, desc = "Next error" })
					vim.keymap.set(
						"n",
						"<leader>ce",
						vim.diagnostic.open_float,
						{ buffer = args.buf, desc = "Show diagnostic float" }
					)
					vim.keymap.set(
						"n",
						"<leader>cl",
						vim.diagnostic.setloclist,
						{ buffer = args.buf, desc = "Diagnostics → loclist" }
					)
				end,
			})
		end,
	},
}
