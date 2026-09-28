-- nvim-autopairs — auto-closes brackets, quotes, parens on insert.
-- Treesitter-aware: won't close pairs inside lua strings or js template literals.
-- Auto-() on function completion is handled by blink.cmp's own
-- completion.accept.auto_brackets, not nvim-autopairs.
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local npairs = require("nvim-autopairs")
		npairs.setup({
			check_ts = true,
			ts_config = {
				lua = { "string" }, -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" },
			},
		})
	end,
}
