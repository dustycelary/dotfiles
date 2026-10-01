-- LSP setup — mason + mason-lspconfig + nvim-lspconfig.
return {
	{
		"williamboman/mason.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
		event = { "BufReadPre", "BufNewFile" },
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
				"taplo",
				"phpactor",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "b0o/schemastore.nvim" },
		config = function()
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
			vim.keymap.set("n", "<leader>ci", lsp_info, { desc = "LSP client info" })

			-- Resolve the interpreter + version for the closest .venv (falls back to python3 on PATH)
			local function resolve_python(root)
				local venv_dir = vim.fs.find(".venv", {
					path = root or vim.fn.getcwd(),
					upward = true,
					type = "directory",
				})[1]

				local venv_path, venv_name
				local python
				if venv_dir and vim.fn.executable(venv_dir .. "/bin/python") == 1 then
					venv_path = vim.fs.dirname(venv_dir)
					venv_name = ".venv"
					python = venv_dir .. "/bin/python"
				else
					python = vim.fn.exepath("python3")
					if python == "" then
						python = vim.fn.exepath("python")
					end
					if python == "" then
						python = "python3"
					end
				end

				local version
				local ok, output =
					pcall(vim.fn.system, { python, "-c", "import sys; print('%d.%d' % sys.version_info[:2])" })
				if ok and vim.v.shell_error == 0 then
					version = vim.trim(output)
				end

				return venv_path, venv_name, version
			end

			-- Custom server overrides (merged over the "*" defaults set below)
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
						local bufname = vim.api.nvim_buf_get_name(0)
						local start_path = config.root_dir
							or (bufname ~= "" and vim.fs.dirname(bufname))
							or vim.fn.getcwd()
						local venv_path, venv_name, python_version = resolve_python(start_path)
						config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
							python = { venvPath = venv_path, venv = venv_name },
							basedpyright = { analysis = { pythonVersion = python_version } },
						})
					end,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								autoImportCompletions = true,
								diagnosticMode = "openFilesOnly",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								indexing = true,
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
					-- yaml-language-server always advertises formatting; disable it up front
					-- (via on_init, before the client ever attaches) since prettier/conform owns
					-- yaml formatting instead.
					on_init = function(client)
						client.server_capabilities.documentFormattingProvider = false
					end,
				},
			}

			-- Base config applied to every server: capabilities + relaxed workspace requirement.
			-- mason-lspconfig's automatic_enable (default: on) calls vim.lsp.enable() for every
			-- Mason-installed server, so we only need to declare configs here, not loop & enable.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end

			vim.lsp.config("*", {
				capabilities = capabilities,
				workspace_required = false,
			})

			for name, config in pairs(custom_servers) do
				vim.lsp.config(name, config)
			end

			-- LSP buffer keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local b = args.buf

					vim.keymap.set("n", "grd", function()
						require("fzf-lua").lsp_definitions({ jump1 = true })
					end, { buffer = b, desc = "Go to definition" })
					vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = b, desc = "Go to declaration" })
					vim.keymap.set("n", "grr", vim.lsp.buf.references, { buffer = b, desc = "References → quickfix" })
					vim.keymap.set("n", "gri", function()
						require("fzf-lua").lsp_implementations({ jump1 = true })
					end, { buffer = b, desc = "Implementations" })
					vim.keymap.set("n", "<leader>cs", function()
						local blink = require("blink.cmp")
						if blink.is_signature_visible() then
							blink.hide_signature()
						else
							blink.show_signature()
						end
					end, { buffer = b, desc = "Toggle signature help" })
					-- Native rename: the server's own prepareRename decides what text
					-- the prompt starts with, so it is the real symbol range rather
					-- than whatever <cword> happens to grab. Snacks' input module
					-- (snacks.lua) renders the prompt as a float at the cursor.
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

			local virtual_text_enabled = false
			vim.keymap.set("n", "<leader>uV", function()
				virtual_text_enabled = not virtual_text_enabled
				vim.diagnostic.config({ virtual_text = virtual_text_enabled })
				vim.notify(
					"Native virtual text: " .. (virtual_text_enabled and "ON" or "OFF"),
					vim.log.levels.INFO,
					{ title = "Diagnostics" }
				)
			end, { desc = "Toggle LSP virtual text" })

			vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
			vim.keymap.set("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "Diagnostics → quickfix" })
			vim.keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Diagnostics → location list" })
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
					-- ruff_fix is `ruff check --fix`, which by default deletes unused
					-- imports (F401) on every save — including the import you just
					-- typed and were about to use two lines down. The inline config
					-- *extends* whatever the project's own unfixable list is (the
					-- --unfixable flag would replace it), so F401 is still reported
					-- as a diagnostic, it just never gets auto-fixed.
					ruff_fix = {
						prepend_args = { "--config", 'lint.extend-unfixable=["F401"]' },
					},
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
			end, { desc = "Format buffer" })
		end,
	},
}
