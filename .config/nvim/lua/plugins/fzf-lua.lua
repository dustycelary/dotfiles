-- Directory pickers (<leader>d*) search outside any project, so they can't use
-- the global `hidden = true` / `no_ignore = true` defaults below — pointed at
-- $HOME those walk ~/Library, every node_modules and every .git/objects. These
-- pickers opt back into fd's normal filtering; alt-g / alt-b still toggle the
-- unfiltered behavior back on from inside the picker.
local function files_in(dir)
	return function()
		local path = vim.fn.expand(dir)
		if vim.fn.isdirectory(path) == 0 then
			vim.notify("No such directory: " .. dir, vim.log.levels.WARN)
			return
		end
		require("fzf-lua").files({
			cwd = path,
			no_ignore = false,
			hidden = false,
			fd_opts = "--color=never --type f --type l"
				.. " --exclude Library --exclude .git --exclude node_modules"
				.. " --exclude .venv --exclude venv --exclude .cache --exclude .Trash",
		})
	end
end

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

			["alt-g"] = fzf.actions.toggle_ignore,
			["alt-b"] = fzf.actions.toggle_hidden,
		}

		fzf.setup({
			-- fzf-lua sizes its float against the *whole editor*, not the current
			-- split, and its "flex" preview flips to a stacked vertical layout
			-- below `flip_columns`. In a half-width tmux pane that leaves neither
			-- the list nor the preview enough room, which is why paths were
			-- getting truncated. Evaluated per-invocation, so it reacts to the
			-- pane being zoomed (tmux F3) without a restart.
			winopts = function()
				return {
					height = 0.90,
					width = 0.92,
					preview = {
						-- Under ~100 columns there is no room for a list *and* a
						-- preview; start hidden and toggle with <C-/> when wanted.
						hidden = vim.o.columns < 100,
						layout = "flex",
						flip_columns = 110,
						horizontal = "right:50%",
						vertical = "down:45%",
						scrollbar = "float",
					},
				}
			end,
			fzf_opts = {
				["--ellipsis"] = "…",
				-- By default fzf scrolls a too-long line sideways to keep the
				-- *match* on screen. With `path.filename_first` the filename is
				-- at the start of the line, so matching a directory near the end
				-- of a long path scrolled the filename out of view entirely —
				-- every result rendered as a bare "… ~/long/path/here". Pin the
				-- line to the left instead: the filename always shows and the
				-- path is what gets cut.
				["--no-hscroll"] = true,
			},
			keymap = {
				builtin = {
					-- Since the preview now starts hidden in a narrow pane, the
					-- toggle needs to be reachable. <F4> is fzf-lua's default and
					-- still works, but it's an awkward reach and its neighbours
					-- <F2>/<F3> are swallowed by tmux (copy-mode / pane zoom).
					-- Terminals send <C-/> as <C-_>; bind both.
					["<C-/>"] = "toggle-preview",
					["<C-_>"] = "toggle-preview",
				},
			},
			-- 2. Global settings for hidden and ignored files
			defaults = {
				hidden = true, -- Hide dotfiles by default; alt-b toggles them
				no_ignore = true, -- Include files ignored by .gitignore
				formatter = "path.filename_first",
			},
			grep = {
				rg_glob = true, -- Auto-parse globs after '--' (e.g., search_term -- *.lua)
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git/ --glob !.venv/ --glob !venv/ --max-columns=4000 -e",
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
		-- Project files: resolve the git root rather than using whatever cwd
		-- happens to be, so this works the same from a nested subdirectory.
		{
			"<leader>ff",
			function()
				require("fzf-lua").files({ cwd = vim.fs.root(0, ".git") or vim.uv.cwd() })
			end,
			desc = "Files (project root)",
		},
		{ "<leader>fF", "<cmd>FzfLua files<cr>", desc = "Files (cwd)" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
		{ "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
		{ "<leader>fc", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
		{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
		{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
		{ '<leader>f"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
		{ "<leader>fs", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
		{ "<leader>fd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
		{ "<leader>fD", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
		{ "go", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
		{ "<leader>f:", "<cmd>FzfLua commands<cr>", desc = "Commands" },

		-- Quick buffer switch. `sort_lastused` puts the alternate buffer first,
		-- so <leader><space><CR> is the old `:b#` toggle, and the preview stays
		-- hidden to keep it feeling like a switcher rather than a picker.
		{
			"<leader><space>",
			function()
				require("fzf-lua").buffers({
					sort_lastused = true,
					winopts = { height = 0.40, width = 0.60, preview = { hidden = true } },
				})
			end,
			desc = "Switch buffer",
		},

		-- [[ Directories — search outside the current project ]]
		{ "<leader>dh", files_in("~"), desc = "Files in ~" },
		{ "<leader>dn", files_in("~/Documents"), desc = "Files in ~/Documents" },
		{ "<leader>dD", files_in("~/Documents/dotfiles"), desc = "Files in ~/Documents/dotfiles" },
		{ "<leader>dd", files_in("~/Downloads"), desc = "Files in ~/Downloads" },
		{ "<leader>do", files_in("~/OneDrive"), desc = "Files in ~/OneDrive" },
		{ "<leader>dc", files_in("~/Developer"), desc = "Files in ~/Developer" },
	},
}
