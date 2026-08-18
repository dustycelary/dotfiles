-- LSP setup — mason + mason-lspconfig + nvim-lspconfig.
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
				"yamlls",
				"jsonls",
				"phpactor",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = { "b0o/schemastore.nvim" },
		config = function()
			-- Border UI & CursorHold hover diagnostics
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
			vim.diagnostic.config({ float = { border = "rounded" } })

			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
				end,
			})

			-- LspInfo command
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

			-- Dynamic Python Virtualenv Path helper
			local function get_python_path(start_path)
				local match = vim.fs.find(".venv", {
					path = start_path or vim.fn.getcwd(),
					upward = true,
					type = "directory",
				})[1]
				if match and vim.fn.executable(match .. "/bin/python") == 1 then
					return match .. "/bin/python"
				end
				local python3 = vim.fn.exepath("python3")
				if python3 ~= "" then
					return python3
				end
				local python = vim.fn.exepath("python")
				return python ~= "" and python or "python3"
			end

			-- Custom server overrides
			local custom_servers = {
				basedpyright = {
					root_markers = {
						"pyrightconfig.json",
						"pyproject.toml",
						"setup.py",
						"setup.cfg",
						".git",
						"requirements.txt",
					},
					before_init = function(_, config)
						local root = config.root_dir or vim.fn.getcwd()
						config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
							python = { pythonPath = get_python_path(root) },
						})
					end,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								autoImportCompletions = false,
								diagnosticMode = "openFilesOnly",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								indexing = false,
								ignore = {
									"**/.venv",
									"**/venv",
									"**/node_modules",
									"**/__pycache__",
									"**/build",
									"**/dist",
								},
							},
						},
						python = {},
					},
				},
				lua_ls = {
					settings = { Lua = { telemetry = { enable = false } } },
				},
				jsonls = {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
				yamlls = {
					settings = {
						yaml = {
							schemaStore = { enable = false, url = "" },
							schemas = require("schemastore").yaml.schemas(),
							validate = true,
						},
					},
				},
			}

			-- Setup and enable all Mason-installed servers
			local mason_lspconfig = require("mason-lspconfig")
			for _, name in ipairs(mason_lspconfig.get_installed_servers()) do
				local config = vim.tbl_deep_extend("force", { workspace_required = false }, custom_servers[name] or {})
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			-- LSP buffer keymaps & autocmds
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "yamlls" then
						client.server_capabilities.documentFormattingProvider = false
					end

					local b = args.buf

					vim.keymap.set("n", "grd", function()
						require("fzf-lua").lsp_definitions({ jump1 = true })
					end, { buffer = b, desc = "Go to definition" })
					vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = b, desc = "Go to declaration" })
					vim.keymap.set("n", "grr", vim.lsp.buf.references, { buffer = b, desc = "LSP references → Quickfix" })
					vim.keymap.set("n", "gri", function()
						require("fzf-lua").lsp_implementations({ jump1 = true })
					end, { buffer = b, desc = "LSP implementations" })
					vim.keymap.set("n", "go", function()
						local clients = vim.lsp.get_clients({ bufnr = 0 })
						for _, c in ipairs(clients) do
							if c.supports_method("textDocument/documentSymbol") then
								require("fzf-lua").lsp_document_symbols()
								return
							end
						end
						require("fzf-lua").treesitter()
					end, { buffer = b, desc = "Document symbols" })

					vim.keymap.set(
						"n",
						"<leader>cs",
						function()
							require("lsp_signature").toggle_float_win()
						end,
						{ buffer = b, desc = "Toggle signature help" }
					)
					vim.keymap.set("n", "<leader>cn", vim.lsp.buf.rename, { buffer = b, desc = "Rename symbol" })
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = b, desc = "Code actions" })
					vim.keymap.set(
						"v",
						"<leader>ca",
						vim.lsp.buf.code_action,
						{ buffer = b, desc = "Code actions (range)" }
					)
				end,
			})

			-- Diagnostic jump mappings
			local function jump_diag(count, severity)
				if vim.diagnostic.jump then
					vim.diagnostic.jump({ count = count, severity = severity })
				else
					vim.diagnostic[count > 0 and "goto_next" or "goto_prev"](
						severity and { severity = severity } or nil
					)
				end
			end

			vim.keymap.set("n", "[d", function()
				jump_diag(-1)
			end, { desc = "Previous diagnostic" })
			vim.keymap.set("n", "]d", function()
				jump_diag(1)
			end, { desc = "Next diagnostic" })
			vim.keymap.set("n", "[e", function()
				jump_diag(-1, vim.diagnostic.severity.ERROR)
			end, { desc = "Previous error" })
			vim.keymap.set("n", "]e", function()
				jump_diag(1, vim.diagnostic.severity.ERROR)
			end, { desc = "Next error" })
			vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
			vim.keymap.set("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "Diagnostics → quickfix" })
			vim.keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Diagnostics → loclist" })
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {
			bind = true,
			handler_opts = { border = "rounded" },
			hint_enable = false,
			floating_window = true,
			toggle_key = "<C-k>",
			toggle_key_flip_floatwin_setting = true,
		},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},
	{
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
						args = { "-c", "." },
						stdin = true,
					},
				},
				format_on_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_fallback = true }
				end,
			})
			vim.keymap.set("n", "<leader>cf", function()
				require("conform").format({ async = true })
			end, { desc = "Format file" })
		end,
	},
}
