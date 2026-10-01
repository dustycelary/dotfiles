-- fzf-lua — fuzzy finder. <leader>f finds inside the current scope (cwd,
-- buffer's dir, buffers, grep, LSP, diagnostics, help); <leader>d searches
-- outside it (~, OneDrive, iCloud, Trash). Each fixed root has files
-- (lowercase) + directories (uppercase), except ~/dh/dd and cwd/ff/f- and
-- buffer-dir/f./f>. In every picker alt-f/alt-s/alt-c act on the entry's
-- directory (files / grep / cd via tab-local :tcd + oil). alt-* so fzf's
-- ctrl-* line editing keeps working.

-- <leader>d* roots can't use the global hidden/no_ignore defaults (at $HOME
-- they'd walk ~/Library, node_modules, .git/objects); alt-g/alt-b toggle them.
local fd_excludes = " --exclude Library --exclude .git --exclude node_modules"
	.. " --exclude .venv --exclude venv --exclude .cache --exclude .Trash"

-- Prompt shows the root since results are stripped of it.
local function prompt_for(dir)
	return vim.fn.fnamemodify(dir, ":~") .. "/ > "
end

-- alt-c: tab-local :tcd + open in oil (notify since cwd change is invisible).
local function cd(dir)
	vim.cmd.tcd(vim.fn.fnameescape(dir))
	vim.cmd.edit(vim.fn.fnameescape(dir))
	vim.notify("cwd → " .. vim.fn.fnamemodify(dir, ":~"))
end

-- Shared "next picker" jumps used by dir pickers and file-picker actions.
local function goto_files(dir)
	require("fzf-lua").files({ cwd = dir, prompt = prompt_for(dir) })
end

local function goto_grep(dir)
	require("fzf-lua").live_grep({ cwd = dir, prompt = prompt_for(dir) })
end

-- Trash root matching oil's delete_to_trash (mac ~/.Trash, freedesktop
-- $XDG_DATA_HOME/Trash/files). Function so per-machine XDG is read on press.
local function trash_dir()
	if vim.fn.has("mac") == 1 then
		return "~/.Trash"
	end
	local xdg = vim.env.XDG_DATA_HOME
	if not xdg or xdg == "" then
		xdg = vim.fs.joinpath(assert(vim.uv.os_homedir()), ".local", "share")
	end
	return vim.fs.joinpath(xdg, "Trash", "files")
end

-- Root can be a path or thunk (buffer dir, trash). nil + warning = bail.
local function resolve_root(dir)
	local base = type(dir) == "function" and dir() or dir
	if not base or base == "" then
		vim.notify("This buffer has no directory on disk", vim.log.levels.WARN)
		return nil
	end
	base = vim.fn.expand(base)
	if vim.fn.isdirectory(base) == 0 then
		vim.notify("No such directory: " .. vim.fn.fnamemodify(base, ":~"), vim.log.levels.WARN)
		return nil
	end
	return base
end

-- `types` = fd --type filter; `overrides` for roots needing other filtering.
local function rooted_picker(dir, types, overrides)
	return function()
		local base = resolve_root(dir)
		if not base then
			return
		end
		require("fzf-lua").files(vim.tbl_extend("force", {
			cwd = base,
			no_ignore = false,
			hidden = false,
			fd_opts = "--color=never " .. types .. fd_excludes,
		}, overrides or {}))
	end
end

local function files_in(dir, overrides)
	return rooted_picker(dir, "--type f --type l", overrides)
end

-- Dir-picker actions. `resolve` maps one selection to an abs path (fd paths
-- are cwd-relative).
local function dir_actions(resolve)
	return {
		["default"] = function(selected)
			vim.cmd.edit(vim.fn.fnameescape(resolve(selected)))
		end,
		["alt-f"] = function(selected)
			goto_files(resolve(selected))
		end,
		["alt-s"] = function(selected)
			goto_grep(resolve(selected))
		end,
		["alt-c"] = function(selected)
			cd(resolve(selected))
		end,
	}
end

-- fzf-lua has no directory picker; fd --type d supplies candidates.
-- `dir` can be a thunk for roots known only at press time (cwd, buffer dir).
local function dirs_in(dir)
	return function()
		local fzf = require("fzf-lua")
		local base = resolve_root(dir)
		if not base then
			return
		end

		-- Hidden dirs stay in (~/.config is a likely target); dirs-only
		-- keeps the set small enough to stay instant.
		local cmd = "fd --color=never --type d --hidden"
			.. fd_excludes
			-- Toolchain caches: ~12k noise entries under $HOME.
			.. " --exclude .npm --exclude .pyenv --exclude .nvm"
			.. " --exclude .cargo --exclude .rustup --exclude .codex"

		-- fd trailing slash would break joinpath onto base.
		local function resolve(selected)
			return vim.fs.joinpath(base, (selected[1]:gsub("/$", "")))
		end

		fzf.fzf_exec(cmd, {
			cwd = base,
			prompt = prompt_for(base),
			-- Builtin previewer expects files; use native ls/eza for dirs.
			preview = "eza --tree --level=1 --color=always {} 2>/dev/null || ls -1 {}",
			fzf_opts = { ["--no-multi"] = true },
			actions = dir_actions(resolve),
		})
	end
end

-- Sibling search: ff walks cwd, this uses the current file's dir (oil-aware).
local function current_file_dir()
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			local dir = oil.get_current_dir() -- nil on remote adapters
			return dir and (dir:gsub("(.)/$", "%1"))
		end
	end
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" or name:match("^%a[%w+.-]*://") then
		return nil
	end
	return vim.fs.dirname(name)
end

-- Fixed roots outside the current project. Lowercase = files, uppercase =
-- directories, except ~ (dh/dd history).
local root_pairs = {
	{ fkey = "h", dkey = "dd", dir = "~", flabel = "~", dlabel = "~" },
	{ fkey = "o", dkey = "O", dir = "~/Library/CloudStorage/OneDrive-Personal", flabel = "OneDrive", dlabel = "OneDrive" },
	{
		fkey = "i",
		dkey = "I",
		dir = "~/Library/Mobile Documents/com~apple~CloudDocs",
		flabel = "iCloud Drive",
		dlabel = "iCloud Drive",
	},
	{ fkey = "b", dkey = "B", dir = trash_dir, flabel = "Trash", dlabel = "Trash", files_overrides = { hidden = true } },
}

local keys = {
	-- [[ <leader>f — find inside the current scope ]]
	{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files (cwd)" },
	{ "<leader>f-", dirs_in(vim.uv.cwd), desc = "Directories (cwd)" },
	-- Mnemonic: "." is this directory, the same as in the shell.
	{
		"<leader>f.",
		function()
			local dir = current_file_dir()
			if not dir then
				vim.notify("This buffer has no directory on disk", vim.log.levels.WARN)
				return
			end
			require("fzf-lua").files({ cwd = dir, prompt = prompt_for(dir) })
		end,
		desc = "Files in current file's directory",
	},
	{ "<leader>f>", dirs_in(current_file_dir), desc = "Directories in current file's directory" },
	{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
	{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
	{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
	{ "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
	{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
	{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
	{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
	{ '<leader>f"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
	{ "<leader>f:", "<cmd>FzfLua commands<cr>", desc = "Commands" },
	{ "<leader>fc", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
	{ "<leader>fs", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
	{ "<leader>fd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
	{ "<leader>fD", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
	{ "go", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },

	-- <CR> on switcher = :b# toggle.
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
}

-- Expand fixed roots: files on lowercase, dirs on uppercase.
for _, root in ipairs(root_pairs) do
	local d_lhs = root.dkey == "dd" and "<leader>dd" or "<leader>d" .. root.dkey
	local f_lhs = "<leader>d" .. root.fkey
	keys[#keys + 1] = { f_lhs, files_in(root.dir, root.files_overrides), desc = "Files in " .. root.flabel }
	keys[#keys + 1] = { d_lhs, dirs_in(root.dir), desc = "Directories in " .. root.dlabel }
end

return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		-- File entries contribute their parent dir; dir entries act as-is.
		local function entry_dir(selected, opts)
			local entry = fzf_path.entry_to_file(selected[1], opts)
			local file = entry.path
			if not file or file == "" then
				return nil
			end
			if not fzf_path.is_absolute(file) then
				file = fzf_path.join({ opts.cwd or vim.uv.cwd(), file })
			end
			-- Dir itself is the target, else its parent.
			if vim.fn.isdirectory(file) == 1 then
				return file
			end
			local dir = vim.fs.dirname(file)
			return vim.fn.isdirectory(dir) == 1 and dir or nil
		end

		local function with_dir(fn)
			return function(selected, opts)
				local dir = entry_dir(selected, opts)
				if not dir then
					vim.notify("This entry has no directory on disk", vim.log.levels.WARN)
					return
				end
				fn(dir)
			end
		end

		-- Single `files` table covers grep/lsp/oldfiles/quickfix/buffers too.
		local common_actions = {
			["default"] = fzf.actions.file_edit,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
			["ctrl-q"] = fzf.actions.file_sel_to_qf,
			["ctrl-l"] = fzf.actions.file_sel_to_ll,

			["alt-g"] = fzf.actions.toggle_ignore,
			["alt-b"] = fzf.actions.toggle_hidden,

			-- Same trio as dir pickers, scoped to the entry's directory.
			["alt-f"] = with_dir(goto_files),
			["alt-s"] = with_dir(goto_grep),
			["alt-c"] = with_dir(cd),
		}

		fzf.setup({
			keymap = {
				builtin = {
					-- Preview starts hidden in narrow panes; tmux swallows
					-- F2/F3/F4, so toggle needs a reachable key. Terminals
					-- send <C-/> as <C-_>; bind both.
					["<C-/>"] = "toggle-preview",
					["<C-_>"] = "toggle-preview",
				},
			},
			-- Sized vs whole editor; flex flips vertical in narrow panes.
			-- Function so tmux zoom takes effect without restart.
			winopts = function()
				return {
					height = 0.90,
					width = 0.92,
					preview = {
						hidden = vim.o.columns < 100, -- no room for list+preview
						layout = "flex",
						flip_columns = 110,
						horizontal = "right:50%",
						vertical = "down:45%",
						scrollbar = "float",
					},
				}
			end,
			defaults = {
				hidden = true,
				no_ignore = true,
				formatter = "path.filename_first",
			},
			grep = {
				rg_glob = true,
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git/ --glob !.venv/ --glob !venv/ --max-columns=4000 -e",
			},
			actions = {
				files = common_actions,
			},
		})

		fzf.register_ui_select()
	end,
	keys = keys,
}
