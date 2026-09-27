-- Completion Domain — blink.cmp, LuaSnip, lazydev, and Supermaven AI (disabled)
return {
	-- 1. Neovim Lua API type stubs for lua_ls
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- 2. LuaSnip snippet engine
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			local luasnip = require("luasnip")

			luasnip.config.setup({
				history = true,
				update_events = "TextChanged,TextChangedI",
				delete_check_events = "TextChanged",
			})

			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
			require("luasnip.loaders.from_lua").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(1)
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { desc = "LuaSnip jump forward / choice" })

			vim.keymap.set({ "i", "s" }, "<C-h>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(-1)
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				end
			end, { desc = "LuaSnip jump backward / choice" })
		end,
	},
	-- 3. Supermaven AI inline completion (DISABLED: change enabled = true to turn back on)
	{
		"supermaven-inc/supermaven-nvim",
		enabled = false,
		event = "VeryLazy",
		cmd = {
			"SupermavenUseFree",
			"SupermavenUsePro",
			"SupermavenStatus",
			"SupermavenToggle",
			"SupermavenLogout",
			"SupermavenShowLog",
		},
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<C-a>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-j>",
				},
				ignore_filetypes = {},
				color = {
					suggestion_color = "#888888",
					cterm = 244,
				},
				disable_inline_completion = false,
				disable_keymaps = false,
			})
		end,
	},
	-- 4. Next-Gen Autocompletion Engine (blink.cmp)
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets", "L3MON4D3/LuaSnip" },
		version = "*",
		opts = {
			keymap = {
				preset = "default",
				["<C-y>"] = { "select_and_accept" },
				["<CR>"] = { "accept", "fallback" },
				["<M-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			snippets = { preset = "luasnip" },
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},
			completion = {
				menu = {
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "kind" },
							{ "source_name" },
						},
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true },
			},
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
	},
}
