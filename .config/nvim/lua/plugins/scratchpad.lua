-- scratchpad.nvim — a per-project notes buffer in a floating window.
-- Each project root gets its own scratchpad file, persisted under
-- stdpath("data")/scratchpad/, so notes survive restarts and travel with the
-- project rather than the session. Pushing the current line or a visual
-- selection appends to it without opening the float.
return {
	"athar-qadri/scratchpad.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		settings = {
			-- The float is torn down on BufLeave/q/Esc, and this is what saves
			-- its contents first — without it, closing the window drops the text.
			sync_on_ui_close = true,
			title = "Scratch Pad",
		},
		default = {
			root_patterns = { ".git", "package.json", "pyproject.toml", "go.mod", "Cargo.toml" },
		},
	},
	-- scratchpad declares setup() as a method (`:`), but lazy.nvim's implicit
	-- setup call for opts-only specs is a plain `require(mod).setup(opts)`, so
	-- it never wires up the ui/data singletons. Call it explicitly.
	config = function(_, opts)
		require("scratchpad"):setup(opts)
	end,
	keys = {
		{
			"<leader>ps",
			function()
				require("scratchpad").ui:new_scratchpad()
			end,
			desc = "Scratchpad",
		},
		{
			"<leader>pS",
			function()
				require("scratchpad").ui:sync()
			end,
			desc = "Push line/selection to scratchpad",
			mode = { "n", "v" },
		},
	},
}