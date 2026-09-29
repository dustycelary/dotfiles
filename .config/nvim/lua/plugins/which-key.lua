-- which-key.nvim — vertical floating popup for keymaps.
-- Helix preset presents keymaps in a sleek vertical side panel.
--
-- [[ Description conventions ]]
-- Every mapping in this config carries a `desc`, written to these rules so the
-- popup reads as one list instead of a pile of plugin jargon:
--   * Verb first, sentence case: "Close window", "Toggle pin", "Live grep".
--   * No group prefix on keys that sit *inside* that group — the panel header
--     already says "Git", so <leader>gs is "Status", not "Git status". Keys at
--     the root keep their context ("Harpoon file 1", "Next buffer").
--   * "Previous"/"Next" spelled out, never "Prev".
--   * "→" means "sends its results to": "Diagnostics → quickfix".
--
-- [[ Icons ]]
-- Group icons are set in `spec` below. Per-mapping icons come from
-- `icons.rules`: which-key checks these before its own built-in rules, matching
-- `plugin` (for keys lazy manages) first, then `pattern` against the lowercased
-- desc, first match winning — so order matters and specific patterns sit above
-- general ones. Anything unmatched still falls through to which-key's built-ins.
-- All glyphs are Font Awesome (U+F0xx), the block the rest of this config uses.

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix", -- Vertical side layout
		delay = 300, -- Delay in ms before showing popup
		keys = {
			scroll_down = "<c-d>",
			scroll_up = "<c-u>",
		},
		win = {
			-- border comes from the global vim.opt.winborder default
			padding = { 1, 2 }, -- Balanced inner padding
			title = true,
			title_pos = "center",
			wo = {
				winblend = 0,
			},
			height = { max = 25 },
		},
		layout = {
			align = "left",
		},
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
			colors = true,
			mappings = true,
			rules = {
				-- Whole plugins first: lazy manages these keys, so they match on
				-- plugin name and don't depend on how each desc is worded.
				{ plugin = "harpoon", icon = "", color = "azure" },
				{ plugin = "vim-fugitive", icon = "", color = "orange" },
				{ plugin = "bufferline.nvim", icon = "", color = "azure" },
				{ plugin = "oil.nvim", icon = "", color = "yellow" },
				{ plugin = "persistence.nvim", icon = "", color = "azure" },
				{ plugin = "inc-rename.nvim", icon = "", color = "orange" },
				{ plugin = "vim-sandwich", icon = "", color = "purple" },
				{ plugin = "flash.nvim", icon = "", color = "yellow" },
				{ plugin = "smart-splits.nvim", icon = "", color = "blue" },

				-- Then desc patterns, specific → general.
				{ pattern = "bookmark", icon = "", color = "yellow" },
				{ pattern = "rename", icon = "", color = "orange" },
				{ pattern = "%f[%a]git", icon = "", color = "orange" },
				{ pattern = "signature", icon = "", color = "cyan" },
				{ pattern = "code action", icon = "", color = "yellow" },
				{ pattern = "reference", icon = "", color = "blue" },
				{ pattern = "implementation", icon = "", color = "blue" },
				{ pattern = "diagnostic", icon = "", color = "red" },
				{ pattern = "%f[%a]error", icon = "", color = "red" },
				{ pattern = "virtual text", icon = "", color = "cyan" },
				{ pattern = "quickfix", icon = "", color = "cyan" },
				{ pattern = "location list", icon = "", color = "cyan" },
				{ pattern = "format", icon = "", color = "cyan" },
				{ pattern = "swap", icon = "", color = "purple" },
				{ pattern = "zoom", icon = "", color = "blue" },
				{ pattern = "split", icon = "", color = "blue" },
				{ pattern = "window", icon = "", color = "blue" },
				{ pattern = "clipboard", icon = "", color = "yellow" },
				{ pattern = "surround", icon = "", color = "purple" },
				{ pattern = "terminal", icon = "", color = "red" },
				{ pattern = "session", icon = "", color = "azure" },
				{ pattern = "director", icon = "", color = "yellow" },
				{ pattern = "files in", icon = "", color = "yellow" },
				{ pattern = "grep", icon = "", color = "green" },
				{ pattern = "keymap", icon = "", color = "green" },
				{ pattern = "snippet", icon = "", color = "purple" },
				{ pattern = "symbol", icon = "", color = "purple" },
				{ pattern = "repeat", icon = "", color = "yellow" },
				{ pattern = "command", icon = "", color = "red" },
				{ pattern = "register", icon = "", color = "yellow" },
				{ pattern = "%f[%a]marks?%f[%A]", icon = "", color = "yellow" },
				{ pattern = "resume", icon = "", color = "green" },
				{ pattern = "help", icon = "", color = "green" },
				{ pattern = "%f[%a]lsp", icon = "", color = "blue" },
				{ pattern = "buffer", icon = "", color = "azure" },
			},
		},
		spec = {
			{ "<leader>b", group = "Buffers", icon = "" },
			{ "<leader>c", group = "Code & LSP", icon = "" },
			{ "<leader>d", group = "Directories (change scope)", icon = "" },
			{ "<leader>f", group = "Find & search (current scope)", icon = "" },
			{ "<leader>g", group = "Git", icon = "" },
			{ "<leader>h", group = "Harpoon (project files)", icon = "" },
			{ "<leader>l", group = "Location list", icon = "" },
			{ "<leader>m", group = "Bookmarks (global)", icon = "" },
			{ "<leader>n", group = "Swap with next (Treesitter)", icon = "" },
			{ "<leader>N", group = "Swap with previous (Treesitter)", icon = "" },
			{ "<leader>q", group = "Quickfix", icon = "" },
			{ "<leader>S", group = "Sessions", icon = "" },
			{ "<leader>s", group = "Surround", icon = "" },
			{ "<leader>u", group = "UI toggles", icon = "" },
			{ "<leader>w", group = "Windows & splits", icon = "" },
			{ "<leader>?", "<cmd>FzfLua keymaps<cr>", desc = "Search all keymaps", icon = "" },
			{ "gr", group = "LSP navigation", icon = "" },
			{ "]", group = "Next motion", icon = "" },
			{ "[", group = "Previous motion", icon = "" },

			-- Labels for keys owned by a plugin or by Nvim itself, which ship without
			-- a `desc` of their own. These entries carry no rhs, so which-key only
			-- labels the existing mapping — it does not re-map the key.
			{ "f", desc = "Find char forward (repeatable)", mode = { "n", "x", "o" }, icon = "" },
			{ "F", desc = "Find char backward (repeatable)", mode = { "n", "x", "o" }, icon = "" },
			{ "t", desc = "Till char forward (repeatable)", mode = { "n", "x", "o" }, icon = "" },
			{ "T", desc = "Till char backward (repeatable)", mode = { "n", "x", "o" }, icon = "" },
			{ ";", desc = "Repeat last move forward", mode = { "n", "x", "o" }, icon = "" },
			{ ",", desc = "Repeat last move backward", mode = { "n", "x", "o" }, icon = "" },
			{ "%", desc = "Jump to matching pair", mode = { "n", "x", "o" }, icon = "" },
			{ "g%", desc = "Jump to previous matching pair", mode = { "n", "x", "o" }, icon = "" },
			{ "[%", desc = "Previous unmatched group start", mode = { "n", "x", "o" }, icon = "" },
			{ "]%", desc = "Next unmatched group end", mode = { "n", "x", "o" }, icon = "" },
			{ "a%", desc = "Select matched group", mode = { "x", "o" }, icon = "" },
			{ "ab", desc = "Select surrounding (auto-detect, outer)", mode = { "x", "o" }, icon = "" },
			{ "ib", desc = "Select surrounding (auto-detect, inner)", mode = { "x", "o" }, icon = "" },
			{ "as", desc = "Select surrounding (query, outer)", mode = { "x", "o" }, icon = "" },
			{ "is", desc = "Select surrounding (query, inner)", mode = { "x", "o" }, icon = "" },
			{ "y<C-G>", desc = "Yank path of current fugitive object", icon = "" },
		},
	},
}
