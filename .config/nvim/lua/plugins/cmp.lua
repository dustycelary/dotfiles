-- nvim-cmp — completion engine.
-- Sources: LSP, LuaSnip snippets, path, buffer words. lazydev takes priority for lua files.
-- Ghost text shows the top suggestion inline as you type.
-- Non-obvious: <C-y> or <CR> confirms; <C-e> aborts; <Tab>/<S-Tab> cycle or jump snippet stops.
-- Custom sort order: exact match → score → recently used → locality → kind.
-- Formatting shows kind icon + kind name instead of source label.
return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		-- lazydev source for neovim lua API completions
		"folke/lazydev.nvim",
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
				["<C-n>"]    = cmp.mapping.select_next_item(),
				["<C-p>"]    = cmp.mapping.select_prev_item(),
				["<Down>"]   = cmp.mapping.select_next_item(),
				["<Up>"]     = cmp.mapping.select_prev_item(),
				["<C-b>"]    = cmp.mapping.scroll_docs(-4),
				["<C-f>"]    = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"]    = cmp.mapping.abort(),
				["<C-y>"]    = cmp.mapping.confirm({ select = true }),
				["<CR>"]     = cmp.mapping.confirm({ select = true }),
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
				{ name = "lazydev", group_index = 0 }, -- takes priority over lsp for lua files
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "path" },
			}, {
				{ name = "buffer", keyword_length = 3 },
			}),
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, item)
					local icons = {
						Text = "", Method = "󰆧", Function = "󰊕", Constructor = "",
						Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "",
						Module = "", Property = "󰜢", Unit = "", Value = "󰎠",
						Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
						File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "",
						Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕",
						TypeParameter = "󰅲",
					}
					local source_labels = {
						nvim_lsp = "[LSP]", luasnip = "[Snip]", buffer = "[Buf]",
						path = "[Path]", lazydev = "[Dev]",
					}
					local kind_name = item.kind
					item.kind = string.format(" %s ", icons[item.kind] or "")
					item.menu = kind_name
					return item
				end,
			},
		})

		-- Cmdline completion for search
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = { { name = "buffer" } },
		})

		-- Cmdline completion for ":"
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
		})
	end,
}
