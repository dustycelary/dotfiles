-- toggleterm.nvim — terminals that hide rather than close, so the shell (and
-- its scrollback, and whatever is still running in it) survives between visits.
--
-- [[ Keys ]]
--   <C-\>        toggle the terminal, including from inside it — one key opens
--                and hides. A count picks a slot: 2<C-\> is terminal 2.
--   <leader>t*   explicit variants (float / split / vsplit, select, new, kill).
--   q            hide the terminal, from normal mode inside it (buffer-local).
--   <Esc>        terminal mode → normal mode (global, in lua/keymaps.lua).
--
-- Hiding is not killing: <C-\> and q leave the job running, <leader>tq shuts
-- the process down and wipes the buffer.

-- The terminal <leader>tq should act on: the one you're standing in, else the
-- one you last used, else simply the newest — so it also works from a normal
-- buffer with every terminal hidden. (get_last_focused only remembers anything
-- after a ToggleTermToggleAll, hence the third fallback.)
local function current_terminal()
	local terminal = require("toggleterm.terminal")
	local id = terminal.get_focused_id()
	if id then
		return terminal.get(id, true)
	end
	local all = terminal.get_all(true) -- sorted by id, so the last is the newest
	return terminal.get_last_focused() or all[#all]
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermSelect", "TermExec" },
	keys = {
		-- Declared here as well as in `open_mapping` below: `keys` is what
		-- lazy-loads the plugin, and once loaded toggleterm re-creates the same
		-- mapping itself — that second one is the one that understands counts.
		{ [[<C-\>]], "<cmd>ToggleTerm<cr>", mode = { "n", "i", "t" }, desc = "Toggle terminal" },
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
		{ "<leader>ts", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle terminal in split" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle terminal in vertical split" },
		{ "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle all terminals" },
		{ "<leader>tl", "<cmd>TermSelect<cr>", desc = "Select terminal" },
		-- toggleterm has no :TermNew; Terminal:new() takes the next free id,
		-- which is also the count <C-\> would need to reach it later.
		{
			"<leader>tn",
			function()
				require("toggleterm.terminal").Terminal:new():open()
			end,
			desc = "New terminal",
		},
		{
			"<leader>tq",
			function()
				local term = current_terminal()
				if not term then
					vim.notify("No terminal to kill", vim.log.levels.WARN, { title = "Terminal" })
					return
				end
				term:shutdown()
			end,
			desc = "Kill terminal",
		},
	},
	opts = {
		open_mapping = [[<C-\>]],
		insert_mappings = true, -- <C-\> works from insert mode
		terminal_mappings = true, -- ...and from inside the terminal, so it hides
		start_in_insert = true,
		persist_size = true,
		persist_mode = false, -- always land back in insert, however you left it
		direction = "horizontal",
		size = function(term)
			if term.direction == "horizontal" then
				return math.max(10, math.floor(vim.o.lines * 0.3))
			elseif term.direction == "vertical" then
				return math.max(60, math.floor(vim.o.columns * 0.4))
			end
		end,
		float_opts = {
			-- vim.opt.winborder (config.lua) is nvim's global float border, but
			-- toggleterm defaults to its own "single", so pass ours through.
			border = vim.o.winborder ~= "" and vim.o.winborder or "rounded",
			width = function()
				return math.floor(vim.o.columns * 0.8)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.8)
			end,
		},
		-- The colorscheme's terminal background is already right; shading it
		-- darker just fights the transparent background.
		shade_terminals = false,
		autochdir = false,
		on_open = function(term)
			-- Hide (not kill) from normal mode inside the terminal — the same
			-- `q` convention the quickfix window uses in lua/keymaps.lua.
			vim.keymap.set("n", "q", function()
				term:close()
			end, { buffer = term.bufnr, desc = "Hide terminal" })
		end,
	},
}
