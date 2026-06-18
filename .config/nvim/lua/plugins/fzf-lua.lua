-- fzf-lua — fuzzy finder for files, grep, buffers, LSP, and more.
-- Files use fd (respects .gitignore, hidden files included, common dirs excluded).
-- Grep uses ripgrep with hidden files. <leader>sF / <leader>sG include ignored files.
-- Non-obvious: <leader>cR does project-wide rename via grep → quickfix → cfdo.
-- LSP keymaps (grd, grr, gri, go, <leader>ss) open results in fzf instead of quickfix.
return {
	"ibhagwan/fzf-lua",
	-- optional for icons
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
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

		require("fzf-lua").setup({
			files = {
				cmd = "fd --type f --hidden " .. fd_excludes .. " 2>/dev/null",
				fzf_opts = { ["--scheme"] = "path" },
			},
			grep = {
				-- respects .gitignore; .git is always skipped by rg
				rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096",
				fzf_opts = { ["--scheme"] = "path" },
			},
		})
	end,
	keys = {
		{ "<leader>sf", "<cmd>FzfLua files<cr>", desc = "Fzf Files" },
		{
			"<leader>sF",
			function()
				require("fzf-lua").files({
					cmd = "fd --type f --hidden --no-ignore --exclude .git 2>/dev/null",
				})
			end,
			desc = "Fzf Files (all, inc. ignored)",
		},
		{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Fzf Grep" },
		{
			"<leader>sG",
			function()
				require("fzf-lua").live_grep({
					rg_opts = "--no-ignore --hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096",
				})
			end,
			desc = "Fzf Grep (all, inc. ignored)",
		},
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
									vim.cmd("tcd " .. vim.fn.fnameescape(selected[1]))
									vim.notify("cwd: " .. selected[1], vim.log.levels.INFO)
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
