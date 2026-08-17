-- LuaSnip — Snippet engine & snippet library integration.
-- Integrates rafamadriz/friendly-snippets for multi-language snippets.
-- Supports custom snippets in ~/.config/nvim/snippets/ (VSCode JSON and Lua formats).
return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local luasnip = require("luasnip")

		luasnip.config.setup({
			history = true,
			update_events = "TextChanged,TextChangedI",
			delete_check_events = "TextChanged",
		})

		-- Load community snippets from friendly-snippets
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Load custom VSCode-style snippets from ~/.config/nvim/snippets
		require("luasnip.loaders.from_vscode").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})

		-- Load custom Lua-style snippets from ~/.config/nvim/snippets
		require("luasnip.loaders.from_lua").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})

		-- Snippet tabstop jump & choice node cycling (Insert & Select modes)
		vim.keymap.set({ "i", "s" }, "<C-l>", function()
			if luasnip.choice_active() then
				luasnip.change_choice(1)
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			end
		end, { desc = "LuaSnip jump forward or next choice" })

		vim.keymap.set({ "i", "s" }, "<C-h>", function()
			if luasnip.choice_active() then
				luasnip.change_choice(-1)
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			end
		end, { desc = "LuaSnip jump backward or previous choice" })
	end,
}
