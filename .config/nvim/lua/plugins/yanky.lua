-- yanky.nvim — enhanced yank and paste experience for Neovim.
-- Maintains a history of yanks and provides keys to cycle through them after putting.
-- Integrates automatically with fzf-lua via vim.ui.select for visual history.
return {
	"gbprod/yanky.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			cancel_event = "update",
		},
		system_clipboard = {
			sync_with_ring = true,
		},
		highlight = {
			on_put = true,
			on_yank = true,
			timer = 200,
			highlight_group = "IncSearch",
		},
		preserve_cursor_position = {
			enabled = true,
		},
	},
	keys = {
		{ "<leader>fy", "<cmd>YankyRingHistory<cr>", desc = "Yank History" },
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put text after cursor" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put text before cursor" },
		{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put text after selection" },
		{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put text before selection" },
		{ "[y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
		{ "]y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
		{ "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle to previous yank history entry" },
		{ "<c-n>", "<Plug>(YankyNextEntry)", desc = "Cycle to next yank history entry" },
		-- Indent put
		-- { "]p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
		-- { "[p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
		-- { "]P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
		-- { "[P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
		-- { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
		-- { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
		-- { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
		-- { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
		-- Filter put
		-- { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying filter" },
		-- { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying filter" },
	},
}
