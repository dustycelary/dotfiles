-- indent-blankline.nvim — vertical indent guides with scope highlighting.
-- Current scope highlighted with a distinct color (IblScope) on the vertical guide.
-- show_start/show_end draw a horizontal underline at the first and last line of the
-- current scope, making block boundaries immediately obvious.
-- Uses │ for guide lines.
return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	-- Per-line extmarks + scope redraws are one of the heaviest UI costs on
	-- weak ARM cores; disable on Pi, keep on desktop.
	enabled = not require("is_pi").is_pi,
	opts = {
		indent = {
			char = "│",
		},
		scope = {
			enabled = true,
			highlight = "IblScope",
			show_start = true, -- underline on the opening line of current scope
			show_end = true, -- underline on the closing line of current scope
		},
	},
}
