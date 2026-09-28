-- tiny-inline-diagnostic.nvim — inline diagnostic display replacing nvim's built-in virtual text.
-- nvim's virtual_text and virtual_lines are disabled in init.lua; this plugin handles all display.
-- Displays diagnostics inline across all lines in the buffer when enabled.
-- Keymaps: <leader>ud toggles inline diagnostics on/off.
return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000,
	-- Wraps + renders virtual text for every line; on Pi fall back to the
	-- native float (<leader>ce) which is already wired in lsp.lua.
	enabled = not require("is_pi").is_pi,
	keys = {
		{
			"<leader>ud",
			function()
				require("tiny-inline-diagnostic").toggle()
			end,
			desc = "Toggle inline diagnostics",
		},
	},
	opts = {
		preset = "powerline",
		signs = {
			left = "",
			right = "",
			diag = "●",
			arrow = " ➜ ",
			up_arrow = " ⬆ ",
			vertical = " │",
			vertical_end = " └",
		},
		options = {
			throttle = 50,
			softwrap = 40,
			overflow = { mode = "wrap" },
			break_line = {
				enabled = true,
				after = 70,
			},
			multiple_diag_under_cursor = true,
			show_all_diags_on_cursorline = true,
			multilines = {
				enabled = true,
				always_show = true, -- Shows inline diagnostics for ALL lines across the file
			},
			add_messages = true,
			virt_texts = { priority = 2048 },
		},
	},
}
