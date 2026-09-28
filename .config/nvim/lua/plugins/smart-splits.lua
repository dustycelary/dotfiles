-- smart-splits.nvim — makes <C-hjkl> cross the nvim/tmux boundary.
--
-- Moving left from the leftmost nvim split used to be a no-op; now it selects
-- the tmux pane to the left instead. Resizing is handled by the same plugin so
-- <S-arrows> resize the tmux pane once an nvim split is already at the edge.
-- Both directions talk to tmux over its CLI; the only thing that needs a tmux
-- binding is getting *back into* nvim from another pane — see the C-hjkl
-- passthrough block in .tmux.conf.
return {
	"mrjones2014/smart-splits.nvim",
	opts = {
		multiplexer_integration = "tmux",
		-- Don't wrap around to the far side of the editor when there's nothing
		-- in that direction — with tmux integration on, "stop" means the edge
		-- hands off to the multiplexer instead of teleporting the cursor.
		at_edge = "stop",
		-- <S-arrows> moved 2 columns/rows at a time before; keep that feel.
		default_amount = 2,
	},
	keys = {
		{ "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Focus split/pane left" },
		{ "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Focus split/pane down" },
		{ "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Focus split/pane up" },
		{ "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Focus split/pane right" },

		{ "<S-Left>", function() require("smart-splits").resize_left() end, desc = "Decrease window width" },
		{ "<S-Right>", function() require("smart-splits").resize_right() end, desc = "Increase window width" },
		{ "<S-Up>", function() require("smart-splits").resize_up() end, desc = "Increase window height" },
		{ "<S-Down>", function() require("smart-splits").resize_down() end, desc = "Decrease window height" },

		-- Swap this split's buffer with the neighbour in that direction.
		{ "<leader>wh", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
		{ "<leader>wj", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
		{ "<leader>wk", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
		{ "<leader>wl", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" },
	},
}
