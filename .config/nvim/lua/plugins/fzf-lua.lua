return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		-- 1. Unify actions in one table so we don't repeat ourselves
		local trouble_fzf = require("trouble.sources.fzf")
		local common_actions = {
			["default"] = fzf.actions.file_edit,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = trouble_fzf.actions.open,
			["alt-t"] = fzf.actions.file_tabedit,
			["alt-q"] = fzf.actions.file_sel_to_qf,
			["alt-l"] = fzf.actions.file_sel_to_ll,

			["alt-i"] = fzf.actions.toggle_ignore,
			["alt-u"] = fzf.actions.toggle_hidden,
		}

		fzf.setup({
			-- 2. Global settings for hidden and ignored files
			defaults = {
				hidden = true, -- Hide hidden files by default
				no_ignore = true, -- Do not hide ignored files (.gitignore) by default
				formatter = "path.filename_first",
			},
			lsp = {
				async_or_path = true,
				formatter = "path.filename_first",
			},
			actions = {
				-- Apply the exact same keymaps to both files and grep
				files = common_actions,
				grep = common_actions,
			},
			registers = {
				multiline = false,
				winopts = {
					preview = {
						layout = "horizontal",
						horizontal = "right:65%",
					},
				},
			},
			-- 3. We completely removed the hardcoded 'cmd' overrides and 'fd_excludes'.
			-- fzf-lua's defaults are already perfectly tuned for fd and ripgrep.
			-- By not hardcoding exclusions, your alt-i/alt-h toggles will now work correctly!
		})

		fzf.register_ui_select()
	end,
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Fzf Files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Fzf Grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Fzf Buffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Fzf Help" },
		{ "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Fzf Resume" },
		{ "<leader>fc", "<cmd>FzfLua command_history<cr>", desc = "Fzf Command History" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Fzf Keymaps" },
		{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Fzf Old Files" },
		{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Fzf Marks" },
		{ '<leader>f"', "<cmd>FzfLua registers<cr>", desc = "Fzf Registers" },
		{ "<leader>f:", "<cmd>FzfLua commands<cr>", desc = "Fzf Commands" },
		{
			"<leader>fs",
			function()
				require("fzf-lua").lsp_live_workspace_symbols()
			end,
			desc = "Fzf Workspace Symbols",
		},
		{
			"<leader>fd",
			function()
				require("fzf-lua").lsp_document_diagnostics()
			end,
			desc = "Fzf Document Diagnostics",
		},
		{
			"go",
			function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				local has_symbol_provider = false
				for _, client in ipairs(clients) do
					if client.supports_method("textDocument/documentSymbol") then
						has_symbol_provider = true
						break
					end
				end
				if has_symbol_provider then
					require("fzf-lua").lsp_document_symbols()
				else
					require("fzf-lua").treesitter()
				end
			end,
			desc = "Document symbols (LSP / Treesitter)",
		},
	},
}
