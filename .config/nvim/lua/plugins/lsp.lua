-- LSP setup — mason + mason-lspconfig + nvim-lspconfig.
-- Servers: basedpyright, lua_ls, clangd, html, bashls, marksman, dockerls, yamlls, jsonls, phpactor.
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
			-- Add borders to LSP floating windows
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
			vim.diagnostic.config({ float = { border = "rounded" } })

			-- Command for checking attached clients
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

			local function get_python_path(start_path)
				local match = vim.fs.find(".venv", {
					path = start_path or vim.fn.getcwd(),
					upward = true,
					type = "directory",
				})[1]
				if match and vim.fn.executable(match .. "/bin/python") == 1 then
					return match .. "/bin/python"
				end
				return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3"
			end

			local custom_servers = {
				basedpyright = {
					root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", ".git", "requirements.txt" },
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
								ignore = { "**/.venv", "**/venv", "**/node_modules", "**/__pycache__", "**/build", "**/dist" },
							},
						},
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

			-- Setup installed Mason servers automatically
			local mason_lspconfig = require("mason-lspconfig")
			for _, name in ipairs(mason_lspconfig.get_installed_servers()) do
				local config = vim.tbl_deep_extend("force", { workspace_required = false }, custom_servers[name] or {})
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			-- Keymaps on LSP attach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local buf = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "yamlls" then
						client.server_capabilities.documentFormattingProvider = false
					end

					local fzf = require("fzf-lua")
					vim.keymap.set("n", "grd", function() fzf.lsp_definitions({ jump1 = true }) end, { buffer = buf, desc = "Go to definition" })
					vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to declaration" })
					vim.keymap.set("n", "grr", fzf.lsp_references, { buffer = buf, desc = "LSP references" })
					vim.keymap.set("n", "gri", function() fzf.lsp_implementations({ jump1 = true }) end, { buffer = buf, desc = "LSP implementations" })

					vim.keymap.set("n", "<leader>cs", vim.lsp.buf.signature_help, { buffer = buf, desc = "Signature help" })
					vim.keymap.set("n", "<leader>cn", vim.lsp.buf.rename, { buffer = buf, desc = "Rename symbol" })
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code actions" })

					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = buf, desc = "Previous diagnostic" })
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = buf, desc = "Next diagnostic" })

					local err_opts = { severity = vim.diagnostic.severity.ERROR }
					vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev(err_opts) end, { buffer = buf, desc = "Previous error" })
					vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next(err_opts) end, { buffer = buf, desc = "Next error" })

					vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { buffer = buf, desc = "Show diagnostic float" })
					vim.keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, { buffer = buf, desc = "Diagnostics → loclist" })
				end,
			})
		end,
	},
}
