-- Completion Domain — nvim-cmp, LuaSnip, lazydev, and Supermaven AI
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
	-- 3. Supermaven AI inline completion
	{
		"supermaven-inc/supermaven-nvim",
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
	-- 4. Autocompletion Engine (nvim-cmp)
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered({
						scrollbar = false,
						col_offset = -3,
						side_padding = 0,
						max_height = 8,
					}),
					documentation = cmp.config.window.bordered({
						scrollbar = false,
					}),
				},
				experimental = {
					ghost_text = true,
				},
				sorting = {
					comparators = {
						cmp.config.compare.exact,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.kind,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<Down>"] = cmp.mapping.select_next_item(),
					["<Up>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
							cmp.confirm({ select = false })
						else
							fallback()
						end
					end, { "i", "s" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "lazydev", group_index = 0 },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer", keyword_length = 3 },
				}),
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},
}
