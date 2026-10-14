-- yanky.nvim — yank history ring + better put.
-- After p/P, <C-p>/<C-n> swap the put for older/newer entries in the ring.
-- Copies made in other apps join the ring too (sync_with_ring), and the ring
-- persists across restarts via shada. <leader>fy searches it.
-- y keeps the cursor where it was; yanks and puts flash briefly.
-- iy selects the last put text (>iy re-indents it, diy deletes it).
return {
	"gbprod/yanky.nvim",
	event = "VeryLazy",
	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
			ignore_registers = { "_" },
		},
		system_clipboard = { sync_with_ring = true },
		highlight = { on_put = true, on_yank = true, timer = 200 },
		preserve_cursor_position = { enabled = true },
		textobj = { enabled = true },
	},
	keys = {
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
		{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after, cursor after text" },
		{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before, cursor after text" },

		{ "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle put to older yank" },
		{ "<C-n>", "<Plug>(YankyNextEntry)", desc = "Cycle put to newer yank" },

		{ "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put line below (match indent)" },
		{ "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put line above (match indent)" },
		{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put below and indent" },
		{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put below and outdent" },
		{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after and re-indent" },
		{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before and re-indent" },

		{
			"iy",
			function()
				require("yanky.textobj").last_put()
			end,
			mode = { "o", "x" },
			desc = "Select last put text",
		},
		{ "<leader>fy", "<cmd>YankyRingHistory<cr>", desc = "Yank history" },
	},
}
