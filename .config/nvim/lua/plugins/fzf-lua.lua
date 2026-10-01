-- fzf-lua — the fuzzy finder for everything. Two keymap groups, split by
-- *scope* rather than by picker type:
--
--   <leader>f   Find something inside the current scope — files under cwd or
--               next to the current buffer, the buffer list, grep, symbols,
--               diagnostics, help.
--   <leader>d   Search somewhere that is *not* the current directory: $HOME,
--               OneDrive, iCloud Drive, the trash, anywhere zoxide remembers.
--
-- Every fixed location has a files picker and a directories picker on the same
-- letter, the shifted key being the directories one:
--
--   ~             <leader>dh / <leader>dd   (dd predates the rule; dH is unused)
--   OneDrive      <leader>do / <leader>dO
--   iCloud Drive  <leader>di / <leader>dI
--   Trash         <leader>db / <leader>dB   (b for bin — dt is the oil jump)
--   cwd           <leader>ff / <leader>f-   (- is oil's own "open a dir" key)
--   buffer's dir  <leader>f. / <leader>f>
--
-- <leader>fa and <leader>da are the two roots worth searching as one list.
--
-- Inside every picker the same three alt-keys act on the focused entry. A
-- directory entry is used as-is; a file entry contributes its parent
-- directory, so the binds mean the same thing in the file, grep, LSP, buffer
-- and directory pickers:
--
--   alt-f  find files in it
--   alt-s  live grep in it
--   alt-c  cd into it (tab-local `:tcd`) and open it in oil
--
-- alt-* rather than ctrl-*: an action bind is emitted after keymap.fzf and
-- therefore wins, so a ctrl-* here would silently cost you fzf's own line
-- editing (ctrl-e is end-of-line, ctrl-f/b are half-page scroll).

-- Directory pickers (<leader>d*) search outside any project, so they can't use
-- the global `hidden = true` / `no_ignore = true` defaults below — pointed at
-- $HOME those walk ~/Library, every node_modules and every .git/objects. These
-- pickers opt back into fd's normal filtering; alt-g / alt-b still toggle the
-- unfiltered behavior back on from inside the picker.
local fd_excludes = " --exclude Library --exclude .git --exclude node_modules"
	.. " --exclude .venv --exclude venv --exclude .cache --exclude .Trash"

-- Every alt-c does the same two things: make the directory the cwd, then land
-- in it. `:tcd` is tab-local so it doesn't disturb your other tabs, and oil is
-- the default file explorer, so `:edit` on a directory browses it. The notify
-- is there because nothing else on screen says the cwd moved.
local function cd(dir)
	vim.cmd.tcd(vim.fn.fnameescape(dir))
	vim.cmd.edit(vim.fn.fnameescape(dir))
	vim.notify("cwd → " .. vim.fn.fnamemodify(dir, ":~"))
end

-- Where the OS puts deleted files, i.e. where oil's `delete_to_trash` sends
-- them. Mirrors oil's own two implementations (adapters/trash/{mac,freedesktop})
-- so <leader>db searches exactly what `g\\` browses: one ~/.Trash on macOS, and
-- $XDG_DATA_HOME/Trash/files under the freedesktop spec. A function rather than
-- a constant because XDG_DATA_HOME is set per machine (the Pi moves it onto the
-- T7), and this way the picker reads it when pressed.
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

-- A picker root: a path string, or a function returning one for the roots that
-- aren't known until the key is pressed (the current buffer's directory, the
-- trash). nil after a warning means "nothing to search", so callers just bail.
local function resolve_root(dir)
	local base = type(dir) == "function" and dir() or dir
	if not base or base == "" then
		-- Only the current-buffer root can be nil: scratch buffers and non-file
		-- schemes (terminal://, fugitive://) have no directory on disk.
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

-- `types` is the fd --type selection, which is the only thing separating the
-- files-only pickers from the files-and-directories ones. `overrides` is for
-- the odd root that wants different filtering (see the trash below).
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

-- Files *and* directories in one list. fd emits both from one walk, and nothing
-- else has to change: fzf-lua's builtin previewer already shells out to
-- `ls -la` for a directory entry, <CR> runs `:edit` (which oil picks up for a
-- directory), and common_actions' alt-f/alt-s/alt-c treat a directory entry as
-- itself rather than as its parent. The trade-off vs. the dirs-only pickers is
-- volume — directories are outnumbered by files, so this is for "I know roughly
-- what it's called", not "there's a project somewhere under ~".
local function files_and_dirs_in(dir, overrides)
	return rooted_picker(dir, "--type f --type l --type d", overrides)
end

-- Actions shared by every picker whose entries are directories. `resolve` turns
-- one selected entry into an absolute path, which is the only part that differs
-- between them (fd emits paths relative to its cwd, zoxide emits "score<TAB>
-- path").
local function dir_actions(resolve)
	return {
		-- oil is the default file explorer, so :edit on a directory opens it as
		-- an editable buffer.
		["default"] = function(selected)
			vim.cmd.edit(vim.fn.fnameescape(resolve(selected)))
		end,
		-- Chain straight into the pickers you'd otherwise reach for next,
		-- already scoped to the directory you just picked.
		["alt-f"] = function(selected)
			local d = resolve(selected)
			require("fzf-lua").files({ cwd = d, prompt = vim.fn.fnamemodify(d, ":~") .. "/ > " })
		end,
		["alt-s"] = function(selected)
			local d = resolve(selected)
			require("fzf-lua").live_grep({ cwd = d, prompt = vim.fn.fnamemodify(d, ":~") .. "/ > " })
		end,
		-- Like <CR>, but it also moves the cwd there.
		["alt-c"] = function(selected)
			cd(resolve(selected))
		end,
	}
end

-- Directory picker. fzf-lua ships pickers for files, buffers and grep but has
-- nothing that searches for *directories*, which is the scope you want when the
-- target isn't a file you can name — "there's a project somewhere under ~, I
-- just don't remember where". fd's --type d supplies the candidates; the
-- actions decide what happens once you've found one.
--
-- `dir` is a path string, or a function returning one for pickers whose root
-- isn't known until you press the key (the cwd variant below).
local function dirs_in(dir)
	return function()
		local fzf = require("fzf-lua")
		local base = resolve_root(dir)
		if not base then
			return
		end

		-- Same reasoning as files_in: rooted at $HOME an unfiltered walk drags in
		-- ~/Library and every node_modules. Hidden directories stay *in* though —
		-- ~/.config is one of the likeliest targets, and dirs-only keeps the
		-- result set small enough that it stays instant.
		local cmd = "fd --color=never --type d --hidden"
			.. fd_excludes
			-- Toolchain caches are pure noise in a directory list and between
			-- them account for ~12k entries under $HOME. Drop one from this
			-- list if you ever do want to land inside it.
			.. " --exclude .npm --exclude .pyenv --exclude .nvm"
			.. " --exclude .cargo --exclude .rustup --exclude .codex"

		-- fd prints directories with a trailing slash; drop it so the entry joins
		-- cleanly onto `base` (which fd made the results relative to via cwd).
		local function resolve(selected)
			return vim.fs.joinpath(base, (selected[1]:gsub("/$", "")))
		end

		fzf.fzf_exec(cmd, {
			cwd = base,
			prompt = vim.fn.fnamemodify(base, ":~") .. "/ > ",
			-- Native fzf previewer rather than the builtin one, which expects
			-- file entries and would try to read a directory as text. eza is the
			-- nicer listing; ls covers boxes that don't have it.
			preview = "eza --tree --level=1 --color=always {} 2>/dev/null || ls -1 {}",
			fzf_opts = { ["--no-multi"] = true },
			actions = dir_actions(resolve),
		})
	end
end

-- Sibling-file search: <leader>ff walks the whole cwd, which is the wrong scope
-- when you already know the file you want sits next to the one you're in.
-- Oil buffers name a directory rather than a file, so ask oil for it; scratch
-- buffers and non-file schemes (terminal, fugitive://) have no directory at all.
local function current_file_dir()
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			-- nil for a remote adapter (oil-ssh://), which has no local path.
			local dir = oil.get_current_dir()
			-- oil hands the path back with a trailing slash; drop it so the
			-- prompt below doesn't end up with a doubled separator.
			return dir and (dir:gsub("(.)/$", "%1"))
		end
	end
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" or name:match("^%a[%w+.-]*://") then
		return nil
	end
	return vim.fs.dirname(name)
end

return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		-- The alt-f/alt-s/alt-c trio from the directory pickers, generalized to
		-- pickers whose entries are *files*. entry_to_file is what fzf-lua's own
		-- actions use — it undoes the formatter, strips grep's ":line:col"
		-- suffix and resolves buffer entries — so one implementation covers
		-- files, grep, lsp, oldfiles, quickfix and buffers.
		local function entry_dir(selected, opts)
			local entry = fzf_path.entry_to_file(selected[1], opts)
			local file = entry.path
			if not file or file == "" then
				return nil
			end
			if not fzf_path.is_absolute(file) then
				file = fzf_path.join({ opts.cwd or vim.uv.cwd(), file })
			end
			-- A directory entry is itself the target; anything else contributes
			-- its parent. Scratch and terminal buffers resolve to names like
			-- "[No Name]" and fail both tests.
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

		-- One action table for every file-ish picker. fzf-lua resolves a
		-- picker's actions to `actions.buffers or actions.files`, and only
		-- `files` and `buffers` are real scopes — grep, lsp, oldfiles, quickfix
		-- and the rest all fall through to `files` — so defining `files` alone
		-- covers the lot.
		local common_actions = {
			["default"] = fzf.actions.file_edit,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
			["ctrl-q"] = fzf.actions.file_sel_to_qf,
			["ctrl-l"] = fzf.actions.file_sel_to_ll,

			["alt-g"] = fzf.actions.toggle_ignore,
			["alt-b"] = fzf.actions.toggle_hidden,

			-- Same keys, same meaning as in the <leader>d pickers, scoped here
			-- to the focused entry's directory.
			["alt-f"] = with_dir(function(dir)
				fzf.files({ cwd = dir, prompt = vim.fn.fnamemodify(dir, ":~") .. "/ > " })
			end),
			["alt-s"] = with_dir(function(dir)
				fzf.live_grep({ cwd = dir, prompt = vim.fn.fnamemodify(dir, ":~") .. "/ > " })
			end),
			["alt-c"] = with_dir(cd),
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
			defaults = {
				hidden = true, -- Include dotfiles; alt-b toggles them back off
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
				files = common_actions,
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
		})

		fzf.register_ui_select()
	end,
	keys = {
		-- [[ <leader>f — find inside the current scope ]]
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files (cwd)" },
		-- Same scope and the same unfiltered defaults as ff (alt-g / alt-b still
		-- toggle them), just with directories mixed into the results. fd's own
		-- --exclude .git/.jj come from fzf-lua's default fd_opts, which this
		-- replaces, so they're repeated here.
		{
			"<leader>fa",
			function()
				require("fzf-lua").files({
					fd_opts = "--color=never --type f --type l --type d --exclude .git --exclude .jj",
				})
			end,
			desc = "Files and directories (cwd)",
		},
		-- Directories, but inside the current scope, so it belongs here rather
		-- than in <leader>d. Mnemonic: `-` is the key oil opens a directory
		-- with, and <CR> here hands the directory straight to oil.
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
				require("fzf-lua").files({
					cwd = dir,
					-- The picker strips `cwd` from every result, so without this
					-- the prompt is the only thing saying which directory it is.
					prompt = vim.fn.fnamemodify(dir, ":~") .. "/ > ",
				})
			end,
			desc = "Files in current file's directory",
		},
		-- The directories companion to f. — shifted `.`, matching the
		-- files/directories pairing described at the top of this file.
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

		-- [[ <leader>d — pick a directory, i.e. change the scope ]]
		-- In all three: <CR> opens it in oil, alt-f searches files in it,
		-- alt-s greps it, alt-c makes it the cwd and keeps browsing from there.
		--
		-- dd is to directories what ff is to files: the one you reach for.
		-- (Directories under *cwd* are <leader>f-, with the rest of the
		-- current-scope pickers.)
		{ "<leader>dd", dirs_in("~"), desc = "Directories under ~" },
		-- zoxide is already tracking where you actually spend time, so this is
		-- the fast path when the directory is one you've visited before.
		{
			"<leader>dz",
			function()
				local fzf = require("fzf-lua")
				-- zoxide entries are "<score>\t<path>", so the path is the last
				-- tab-separated field — but only under fzf-lua's own
				-- `path.dirname_first`, which leaves the path contiguous. The
				-- global `path.filename_first` above re-splits it into
				-- "<tail>\t<parent>", which made the last field the *parent*:
				-- every action, including fzf-lua's built-in preview and cd,
				-- landed one directory too high. Pin the formatter this picker
				-- is written against.
				local function resolve(selected)
					return selected[1]:match("[^\t]+$") or selected[1]
				end
				fzf.zoxide({
					formatter = "path.dirname_first",
					actions = vim.tbl_extend("force", dir_actions(resolve), {
						-- Same alt-c as everywhere else, plus the score bump
						-- fzf-lua's own zoxide_cd action would have done, so the
						-- entry stays near the top next time.
						["alt-c"] = function(selected)
							local d = resolve(selected)
							vim.system({ "zoxide", "add", "--", d })
							cd(d)
						end,
					}),
				})
			end,
			desc = "Zoxide directories",
		},
		-- Files rather than directories, for when the target is a file you can
		-- name and it isn't under the current project.
		{ "<leader>dh", files_in("~"), desc = "Files in ~" },
		{ "<leader>da", files_and_dirs_in("~"), desc = "Files and directories in ~" },
		-- The trash, searched rather than browsed (<leader>dt opens it in oil).
		-- hidden = true here unlike the other rooted pickers: you delete
		-- dotfiles too, and the trash is small enough that showing them costs
		-- nothing. <CR> opens the trashed copy in place — restoring is still
		-- oil's job, over in the oil-trash:// buffer.
		{ "<leader>db", files_in(trash_dir, { hidden = true }), desc = "Files in Trash" },
		{ "<leader>dB", dirs_in(trash_dir), desc = "Directories in Trash" },
		-- Cloud storage. Both live under ~/Library, which nothing else in this
		-- config looks at, and neither is ever "under the current project".
		-- macOS-only paths, so on the Pi these report the missing directory
		-- rather than opening an empty picker.
		{ "<leader>do", files_in("~/Library/CloudStorage/OneDrive-Personal"), desc = "Files in OneDrive" },
		{ "<leader>dO", dirs_in("~/Library/CloudStorage/OneDrive-Personal"), desc = "Directories in OneDrive" },
		{
			"<leader>di",
			files_in("~/Library/Mobile Documents/com~apple~CloudDocs"),
			desc = "Files in iCloud Drive",
		},
		{
			"<leader>dI",
			dirs_in("~/Library/Mobile Documents/com~apple~CloudDocs"),
			desc = "Directories in iCloud Drive",
		},
	},
}
