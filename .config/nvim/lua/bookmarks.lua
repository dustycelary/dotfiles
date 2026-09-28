-- Global, persistent bookmarks for files *and* directories.
--
-- Unlike Harpoon's file list (scoped to cwd) or uppercase marks (26 slots,
-- files only, positions drift), this is a flat list of absolute paths stored
-- outside any project, so the same bookmarks are reachable from every working
-- directory. Directories open in Oil — `:edit <dir>` is enough, since oil is
-- default_file_explorer with netrw disabled.

local M = {}

local store = vim.fn.stdpath("data") .. "/bookmarks.json"

local function read()
	local fd = io.open(store, "r")
	if not fd then
		return {}
	end
	local content = fd:read("*a")
	fd:close()
	local ok, data = pcall(vim.json.decode, content)
	return (ok and type(data) == "table") and data or {}
end

local function write(list)
	local fd, err = io.open(store, "w")
	if not fd then
		vim.notify("Could not write bookmarks: " .. tostring(err), vim.log.levels.ERROR)
		return false
	end
	fd:write(vim.json.encode(list))
	fd:close()
	return true
end

-- Absolute, no trailing slash, so `~/Documents` and `~/Documents/` are one entry.
local function normalize(path)
	path = vim.fn.fnamemodify(path, ":p")
	if #path > 1 then
		path = path:gsub("/+$", "")
	end
	return path
end

-- What <leader>ma should grab: the Oil directory when browsing, otherwise the
-- current file, falling back to cwd for unnamed buffers.
local function current()
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			local dir = oil.get_current_dir()
			if dir then
				return dir
			end
		end
	end
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return vim.uv.cwd()
	end
	return name
end

function M.add(path)
	path = normalize(path or current())
	local list = read()
	for _, p in ipairs(list) do
		if p == path then
			vim.notify("Already bookmarked: " .. vim.fn.fnamemodify(path, ":~"))
			return
		end
	end
	table.insert(list, path)
	table.sort(list)
	if write(list) then
		vim.notify("Bookmarked " .. vim.fn.fnamemodify(path, ":~"))
	end
end

function M.add_cwd()
	M.add(vim.uv.cwd())
end

function M.remove(path)
	path = normalize(path)
	local list = read()
	for i, p in ipairs(list) do
		if p == path then
			table.remove(list, i)
			if write(list) then
				vim.notify("Removed bookmark " .. vim.fn.fnamemodify(path, ":~"))
			end
			return
		end
	end
end

local function open(path, cmd)
	if vim.fn.isdirectory(path) == 0 and vim.fn.filereadable(path) == 0 then
		vim.notify("Bookmark no longer exists: " .. path .. " (ctrl-x in the picker to remove)", vim.log.levels.WARN)
		return
	end
	vim.cmd((cmd or "edit") .. " " .. vim.fn.fnameescape(path))
end

function M.pick()
	local list = read()
	if vim.tbl_isempty(list) then
		vim.notify("No bookmarks yet — <leader>ma adds the current file/dir", vim.log.levels.WARN)
		return
	end

	-- Mirror fzf-lua's `path.filename_first` formatter: basename first, parent
	-- directory dimmed off to the right. Without this a long path is truncated
	-- from the right and every entry reads as an indistinguishable
	-- "~/Library/CloudStorage/OneDrive-Personal/Documents/tech...".
	local utils = require("fzf-lua.utils")

	local rows, width = {}, 0
	for _, p in ipairs(list) do
		local isdir = vim.fn.isdirectory(p) == 1
		local row = {
			path = p,
			icon = (not isdir and vim.fn.filereadable(p) == 0) and "" or (isdir and "" or ""),
			name = vim.fn.fnamemodify(p, ":t"),
			parent = vim.fn.fnamemodify(vim.fn.fnamemodify(p, ":h"), ":~"),
		}
		if row.name == "" then -- e.g. "/" — nothing to split off
			row.name, row.parent = p, ""
		end
		width = math.max(width, vim.fn.strdisplaywidth(row.name))
		table.insert(rows, row)
	end
	width = math.min(width, 40) -- don't let one long name push every path off-screen

	-- fzf hands back the display string, so keep a map back to the real path.
	-- Key it on the *uncolored* text: whether fzf strips the ANSI escapes from
	-- its output depends on the code path, so normalize both sides.
	local by_display, entries = {}, {}
	for _, row in ipairs(rows) do
		local pad = string.rep(" ", math.max(1, width - vim.fn.strdisplaywidth(row.name) + 2))
		local prefix = string.format("%s  %s%s", row.icon, row.name, pad)
		by_display[prefix .. row.parent] = row.path
		table.insert(entries, prefix .. utils.ansi_codes.grey(row.parent))
	end

	local function selected(sel)
		if not (sel and sel[1]) then
			return nil
		end
		return by_display[utils.strip_ansi_coloring(sel[1])]
	end

	require("fzf-lua").fzf_exec(entries, {
		prompt = "Bookmarks❯ ",
		winopts = {
			title = " Bookmarks ",
			title_pos = "center",
			height = 0.45,
			width = 0.70,
			preview = { hidden = true },
		},
		actions = {
			["default"] = function(sel)
				local p = selected(sel)
				if p then
					open(p)
				end
			end,
			["ctrl-s"] = function(sel)
				local p = selected(sel)
				if p then
					open(p, "split")
				end
			end,
			["ctrl-v"] = function(sel)
				local p = selected(sel)
				if p then
					open(p, "vsplit")
				end
			end,
			["ctrl-t"] = function(sel)
				local p = selected(sel)
				if p then
					open(p, "tabedit")
				end
			end,
			-- Jump the *picker* into that bookmark rather than opening it: find
			-- files under it (or under its parent, for a file bookmark).
			["ctrl-f"] = function(sel)
				local p = selected(sel)
				if not p then
					return
				end
				local dir = vim.fn.isdirectory(p) == 1 and p or vim.fn.fnamemodify(p, ":h")
				vim.schedule(function()
					require("fzf-lua").files({ cwd = dir })
				end)
			end,
			["ctrl-x"] = function(sel)
				local p = selected(sel)
				if p then
					M.remove(p)
					vim.schedule(M.pick)
				end
			end,
		},
	})
end

-- Keymaps live here rather than in lua/keymaps.lua so the whole feature is one
-- file. Called from init.lua; the which-key group for <leader>m is declared in
-- plugins/which-key.lua. fzf-lua is only required inside pick(), so loading
-- this module at startup pulls in nothing else.
function M.setup()
	vim.keymap.set("n", "<leader>mm", M.pick, { desc = "Find bookmark" })
	vim.keymap.set("n", "<leader>ma", function()
		M.add()
	end, { desc = "Bookmark current file/dir" })
	vim.keymap.set("n", "<leader>mc", M.add_cwd, { desc = "Bookmark cwd" })
end

return M
