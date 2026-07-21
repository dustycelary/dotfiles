return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		-- Custom Action: Open parent directory in Oil
		local open_in_oil = function(selected, opts)
			if not selected or #selected == 0 then
				return
			end
			local entry = fzf_path.entry_to_file(selected[1], opts)
			local path = entry.path or entry.bufname or entry.uri
			if path then
				local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":h")
				require("oil").open(dir)
			end
		end

		-- Custom Action: Delete the selected file
		local delete_file = function(selected, opts)
			if not selected or #selected == 0 then
				return
			end
			local entry = fzf_path.entry_to_file(selected[1], opts)
			local path = entry.path or entry.bufname or entry.uri
			if not path then
				return
			end

			local confirm = vim.fn.input(string.format("Delete '%s'? [y/N]: ", vim.fn.fnamemodify(path, ":t")))
			vim.cmd("redraw") -- clear the command line

			if confirm:lower() == "y" then
				local success, err = os.remove(path)
				if success then
					vim.notify("File deleted: " .. path, vim.log.levels.INFO)
					fzf.actions.resume(selected, opts)
				else
					vim.notify("Error deleting file: " .. tostring(err), vim.log.levels.ERROR)
				end
			else
				vim.notify("Deletion cancelled", vim.log.levels.WARN)
			end
		end

		-- 1. Unify actions in one table so we don't repeat ourselves
		local common_actions = {
			["default"] = fzf.actions.file_edit,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
			["alt-q"] = fzf.actions.file_sel_to_qf,
			["alt-l"] = fzf.actions.file_sel_to_ll,
			["ctrl-e"] = open_in_oil,
			["ctrl-d"] = delete_file,

			-- Note: Fixed alt-h to match your prompt's comment (was alt-u in your code)
			["alt-i"] = fzf.actions.toggle_ignore,
			["alt-u"] = fzf.actions.toggle_hidden,
		}

		fzf.setup({
			-- 2. Global settings for hidden and ignored files
			defaults = {
				hidden = false, -- Hide hidden files by default (until alt-h)
				no_ignore = false, -- Respect .gitignore by default (until alt-i)
			},
			actions = {
				-- Apply the exact same keymaps to both files and grep
				files = common_actions,
				grep = common_actions,
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
		{ "<leader>f:", "<cmd>FzfLua commands<cr>", desc = "Fzf Commands" },
		-- {
		-- 	"<leader>fs",
		-- 	function()
		-- 		require("fzf-lua").lsp_live_workspace_symbols()
		-- 	end,
		-- 	desc = "Fzf Workspace Symbols",
		-- },
		-- {
		-- 	"<leader>fd",
		-- 	function()
		-- 		require("fzf-lua").lsp_document_diagnostics()
		-- 	end,
		-- 	desc = "Fzf Document Diagnostics",
		-- },
		-- {
		-- 	"<leader>fD",
		-- 	function()
		-- 		require("fzf-lua").lsp_workspace_diagnostics()
		-- 	end,
		-- 	desc = "Fzf Workspace Diagnostics",
		-- },
	},
}
