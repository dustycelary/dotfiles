-- nvim-autopairs — auto-closes brackets, quotes, parens on insert.
-- Treesitter-aware: won't close pairs inside lua strings or js template literals.
-- Integrated with nvim-cmp: automatically appends () when confirming a function completion.
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	dependencies = { "hrsh7th/nvim-cmp" },
	config = function()
		local npairs = require("nvim-autopairs")
		npairs.setup({
			check_ts = true,
			ts_config = {
				lua = { "string" }, -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" },
			},
		})

		-- If nvim-cmp is installed, integrate it to automatically add () on function/method confirmation
		local cmp_status, cmp = pcall(require, "cmp")
		if cmp_status then
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end
	end,
}
