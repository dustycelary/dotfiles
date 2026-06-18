-- neoscroll.nvim — smooth animated scrolling for <C-u/d/b/f> and zt/zz/zb.
-- Cursor hidden during scroll. Stops at EOF. Does not respect scrolloff.
return {
	"karb94/neoscroll.nvim",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("neoscroll").setup({
			mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
			hide_cursor = true,          -- Hide cursor while scrolling
			stop_eof = true,             -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin
			cursor_scrolls_alone = true, -- The cursor will scroll on its own
		})
	end,
}
