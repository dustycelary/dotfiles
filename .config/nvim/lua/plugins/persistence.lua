-- Persistence — automated session management per workspace
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	keys = {
		{
			"<leader>Sr",
			function()
				require("persistence").load()
			end,
			desc = "Restore session for current dir",
		},
		{
			"<leader>Ss",
			function()
				require("persistence").select()
			end,
			desc = "Select session to restore",
		},
		{
			"<leader>Sl",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore last session",
		},
		{
			"<leader>Sd",
			function()
				require("persistence").stop()
			end,
			desc = "Don't save current session",
		},
	},
}
