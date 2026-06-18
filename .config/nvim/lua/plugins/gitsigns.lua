-- gitsigns.nvim — git change indicators in the sign column.
-- Shows add/change/delete markers using ▎ and  glyphs.
-- Inline blame toggled with <leader>ub (off by default, 400ms delay when on).
-- Staged hunks shown with separate (dimmer) signs alongside unstaged ones.
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "<leader>ub", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle git blame" },
	},
	opts = {
		signs = {
			add          = { text = "▎" },
			change       = { text = "▎" },
			delete       = { text = "" },
			topdelete    = { text = "" },
			changedelete = { text = "▎" },
			untracked    = { text = "╎" },
		},
		signs_staged = {
			add          = { text = "▎" },
			change       = { text = "▎" },
			delete       = { text = "" },
			topdelete    = { text = "" },
			changedelete = { text = "▎" },
		},
		current_line_blame = false,
		current_line_blame_opts = {
			delay = 400,
			virt_text_pos = "eol",
		},
		current_line_blame_formatter = " <author>, <author_time:%Y-%m-%d> · <summary>",
	},
}
