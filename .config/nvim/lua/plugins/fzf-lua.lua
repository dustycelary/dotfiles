-- fzf-lua — fuzzy finder for files, grep, buffers, LSP, and more.
-- Files use fd (excludes common dirs).
-- Grep uses ripgrep.
-- Non-obvious: <leader>cR does project-wide rename via grep → quickfix → cfdo.
-- <C-e> opens the parent directory of the selected file in netrw.
-- <C-d> prompts to delete the selected file.
-- <M-i> (alt-i) toggles ignored files (.gitignore).
-- <M-h> (alt-h) toggles hidden files.
-- LSP keymaps (grd, grr, gri, go, <leader>ss) open results in fzf instead of quickfix.
return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		local fd_excludes = table.concat({
			"--exclude .git",
			"--exclude .venv",
			"--exclude node_modules",
			"--exclude __pycache__",
			"--exclude .mypy_cache",
			"--exclude .pytest_cache",
			"--exclude dist",
			"--exclude build",
		}, " ")

		-- Custom Action: Open parent directory in Netrw
		local open_in_netrw = function(selected, opts)
			if not selected or #selected == 0 then
				return
			end
			local entry = fzf_path.entry_to_file(selected[1], opts)
			local path = entry.path or entry.bufname or entry.uri
			if path then
				local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":h")
				vim.cmd("edit " .. vim.fn.fnameescape(dir))
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
					-- Reopen the fzf window (resume) to refresh the file list
					fzf.actions.resume(selected, opts)
				else
					vim.notify("Error deleting file: " .. tostring(err), vim.log.levels.ERROR)
				end
			else
				vim.notify("Deletion cancelled", vim.log.levels.WARN)
			end
		end

		require("fzf-lua").setup({
			defaults = {
				no_ignore = true,
				hidden = true,
			},
			actions = {
				files = {
					-- Explicit standard actions
					["default"] = fzf.actions.file_edit,
					["ctrl-s"] = fzf.actions.file_split,
					["ctrl-v"] = fzf.actions.file_vsplit,
					["ctrl-t"] = fzf.actions.file_tabedit,
					["alt-q"] = fzf.actions.file_sel_to_qf,
					["alt-l"] = fzf.actions.file_sel_to_ll,

					-- Custom integrations
					["ctrl-e"] = open_in_netrw,
					["ctrl-d"] = delete_file,

					-- Toggles
					["alt-i"] = { fzf.actions.toggle_ignore },
					["alt-h"] = { fzf.actions.toggle_hidden },
				},
				grep = {
					-- Grep needs its own explicit mapping to use the toggles
					["default"] = fzf.actions.file_edit,
					["ctrl-s"] = fzf.actions.file_split,
					["ctrl-v"] = fzf.actions.file_vsplit,
					["ctrl-t"] = fzf.actions.file_tabedit,
					["alt-q"] = fzf.actions.file_sel_to_qf,
					["alt-l"] = fzf.actions.file_sel_to_ll,

					-- Toggles
					["alt-i"] = { fzf.actions.toggle_ignore },
					["alt-h"] = { fzf.actions.toggle_hidden },
				},
			},
			files = {
				-- Kept clean so the toggles work bidirectionally
				cmd = "fd --type f " .. fd_excludes .. " 2>/dev/null",
				fzf_opts = { ["--scheme"] = "path" },
				no_ignore = true,
				hidden = true,
			},
			grep = {
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096",
				fzf_opts = { ["--scheme"] = "path" },
				no_ignore = true,
				hidden = true,
			},
		})

		fzf.register_ui_select()
	end,
	keys = {
		{ "<leader>sf", "<cmd>FzfLua files<cr>", desc = "Fzf Files" },
		{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Fzf Grep" },
		{ "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "Fzf Buffers" },
		{ "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Fzf Help" },
		{ "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "Fzf Resume" },
		{ "<leader>s:", "<cmd>FzfLua command_history<cr>", desc = "Fzf Command History" },
		{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Fzf Keymaps" },
		{ "<leader>so", "<cmd>FzfLua oldfiles<cr>", desc = "Fzf Old Files" },
		{ "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Fzf Marks" },
		{
			"<leader>sw",
			function()
				require("fzf-lua").grep_cword()
			end,
			desc = "Fzf Search Word Under Cursor",
		},
		{
			"<leader>ss",
			function()
				require("fzf-lua").lsp_live_workspace_symbols()
			end,
			desc = "Fzf Workspace Symbols",
		},
		{
			"<leader>sd",
			function()
				require("fzf-lua").lsp_document_diagnostics()
			end,
			desc = "Fzf Document Diagnostics",
		},
		{
			"<leader>sD",
			function()
				require("fzf-lua").lsp_workspace_diagnostics()
			end,
			desc = "Fzf Workspace Diagnostics",
		},
		{ "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "Fzf Commands" },
		{
			"<leader>si",
			function()
				require("fzf-lua").fzf_exec(
					"fd --type d --hidden --exclude .git --exclude .venv --exclude node_modules --exclude __pycache__ 2>/dev/null",
					{
						prompt = "Dirs> ",
						actions = {
							["default"] = function(selected)
								if selected and selected[1] then
									vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
								end
							end,
						},
					}
				)
			end,
			desc = "Fzf Directories",
		},
	},
}
