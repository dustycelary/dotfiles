return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		-- 1. Unify actions in one table so we don't repeat ourselves
		local common_actions = {
			["default"] = fzf.actions.file_edit,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
			["ctrl-q"] = fzf.actions.file_sel_to_qf,
			["ctrl-l"] = fzf.actions.file_sel_to_ll,

			-- Note: Fixed alt-h to match your prompt's comment (was alt-u in your code)
			["alt-i"] = fzf.actions.toggle_ignore,
			["alt-u"] = fzf.actions.toggle_hidden,
		}

		fzf.setup({
			-- 2. Global settings for hidden and ignored files
			defaults = {
				hidden = false, -- Hide dotfiles by default; alt-u toggles them
				no_ignore = true, -- Include files ignored by .gitignore
				formatter = "path.filename_first",
			},
			lsp = {
				formatter = "path.filename_first",
			},
			actions = {
				-- Apply the exact same keymaps to files, grep, and LSP pickers
				files = common_actions,
				grep = common_actions,
				lsp = common_actions,
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
		{ "<leader>fs", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Fzf Workspace Symbols" },
		{ "<leader>fd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Fzf Workspace Diagnostics" },
		{ "<leader>fD", "<cmd>FzfLua diagnostics_document<cr>", desc = "Fzf Document Diagnostics" },
		{ "go", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document Symbols" },
		{ "<leader>f:", "<cmd>FzfLua commands<cr>", desc = "Fzf Commands" },
	},
}
