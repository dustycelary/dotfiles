-- LSP setup — mason + mason-lspconfig + nvim-lspconfig.
-- On Pi (see lua/is_pi.lua): only lua_ls + bashls auto-install. The Node/Python
-- servers (basedpyright, yamlls, jsonls, html, dockerls, marksman, taplo,
-- phpactor) each cost a persistent process + RAM; install them manually with
-- :MasonInstall if you need one, preferably from apt (clangd especially —
-- Mason's binary is x86_64-only).
local is_pi = require("is_pi").is_pi
local pi_servers = { "lua_ls", "bashls" }
local full_servers = {
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
}
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
			ensure_installed = is_pi and pi_servers or full_servers,
			-- Don't auto-enable every Mason-installed server on Pi: only the
			-- ones in ensure_installed above. Manual :MasonInstall stays opt-in.
			automatic_enable = is_pi and pi_servers or true,
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
								-- Pi: no type-checking, no indexing — completions +
								-- diagnostics only. Desktop keeps basic + indexing.
								typeCheckingMode = is_pi and "off" or "basic",
								autoImportCompletions = true,
								diagnosticMode = "openFilesOnly",
								autoSearchPaths = true,
								useLibraryCodeForTypes = not is_pi,
								indexing = not is_pi,
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
					-- <leader>cn (rename symbol) belongs to inc-rename.nvim. It has to
					-- stay out of here: a buffer-local map would shadow the global one
					-- and we'd be back to the preview-less prompt.
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
			local is_pi = require("is_pi").is_pi
			require("conform").setup({
				formatters_by_ft = {
					htmldjango = { "djlint" },
					-- One ruff call on Pi (3x spawn on save is noticeable);
					-- full fix+format+organize chain on desktop.
					python = is_pi and { "ruff_format" } or { "ruff_fix", "ruff_format", "ruff_organize_imports" },
					json = { "clang-format" },
					c = { "clang-format" },
					lua = { "stylua" },
					jsonl = { "jq_jsonl" },
					-- Node-based formatters (prettier, markdownlint) each spawn
					-- node (~300-500ms on Pi); skip them there, keep manual
					-- <leader>cf which still tries LSP fallback off.
					markdown = is_pi and {} or { "markdownlint" },
					yaml = is_pi and {} or { "prettier" },
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
					-- No LSP fallback on Pi: with most servers disabled it would
					-- just add a blocking timeout to every save.
					return { timeout_ms = is_pi and 2000 or 500, lsp_fallback = not is_pi }
				end,
			})
			vim.keymap.set("n", "<leader>cf", function()
				require("conform").format({ async = true })
			end, { desc = "Format buffer" })
		end,
	},
}
