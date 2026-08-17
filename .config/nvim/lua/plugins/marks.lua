-- marks.nvim — Enhanced Vim marks & bookmarks management.
-- Features:
--   m,         Toggle next available mark
--   m;         Toggle mark on current line
--   dm{mark}   Delete specified mark (or dm<Space> for current line mark, dm<BS> for all buffer marks)
--   m:         Preview mark at current line
--   ]' / ['    Jump to next / previous mark
--   m0-m9      Set bookmark (numbered bookmark groups)
return {
	"chentoast/marks.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		default_mappings = true,
		builtin_marks = { ".", "<", ">", "^" },
		cyclic = true,
		force_write_shada = false,
		refresh_interval = 250,
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		mappings = {
			next = "]'",
			prev = "['",
		},
		excluded_filetypes = {
			"aerial",
			"fzf",
			"lazy",
			"mason",
			"oil",
			"terminal",
		},
		excluded_buftypes = {
			"nofile",
			"prompt",
			"quickfix",
			"terminal",
		},
		bookmark_0 = {
			sign = "⚑",
			virt_text = "bookmark 0",
			annotate = false,
		},
	},
}
