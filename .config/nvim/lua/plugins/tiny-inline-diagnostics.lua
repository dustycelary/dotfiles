-- tiny-inline-diagnostic.nvim — inline diagnostic display replacing nvim's built-in virtual text.
-- nvim's virtual_text and virtual_lines are disabled in init.lua; this plugin handles all display.
-- Powerline preset. Shows all diagnostics under cursor simultaneously.
-- Long messages wrap at 40 chars and break onto continuation lines at 70.
-- <leader>ut toggles it on/off.
return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000,
	keys = {
		{ "<leader>ut", function() require("tiny-inline-diagnostic").toggle() end, desc = "Toggle inline diagnostics" },
	},
	opts = {
		-- Presets: "modern" | "powerline" (needs nerd/powerline font) |
		--          "ghost" | "simple" | "amongst" | "classic"
		preset = "powerline",

		-- Custom signs per severity (Nerd Font icons)
		signs = {
			left        = "",
			right       = "",
			diag        = "●",
			arrow       = "    ",
			up_arrow    = "    ",
			vertical    = " │",
			vertical_end = " └",
		},

		options = {
			-- Snap to cursor movement with no delay
			throttle = 0,

			-- Wrap long messages instead of truncating
			softwrap = 40,
			overflow = { mode = "wrap" },

			-- Break very long messages onto a continuation line
			break_line = {
				enabled = true,
				after = 70,
			},

			-- Show all diagnostics under cursor, not just the first
			multiple_diag_under_cursor = true,

			-- Show all severities on the cursor line at once
			show_all_diags_on_cursorline = true,

			-- Show multiline diagnostics for the current line;
			-- set always_show = true to show them on every line in the buffer
			multilines = {
				enabled = true,
				always_show = false,
			},

			-- Add a blank separator line between each diagnostic when multiple
			-- are shown on the same line, so they don't run together
			add_messages = true,

			-- Keep virtual text above other decorations
			virt_texts = { priority = 2048 },
		},
	},
}
