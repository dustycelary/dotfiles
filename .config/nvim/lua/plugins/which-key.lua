-- which-key.nvim — popup showing available keymaps after a 1500ms pause.
-- Helix preset. Appears at bottom center. LSP mappings hidden when no LSP attached.
-- Treesitter mappings hidden when no parser active in the buffer.
-- Descriptions truncated to 20 chars. Group prefixes: <leader>b=buffers, c=code,
--   h=harpoon, s=search, u=UI, w=windows/surrounds.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	enabled = true,
	opts = {
		preset = "helix",
		delay = 1500,
		win = {
			col = 0.5, -- Centered at the bottom
			row = -1,
			width = { min = 30, max = 0.9 }, -- Dynamic width (no full-screen gray bar)
			height = { min = 5, max = 5 },
			border = "none",
			title = false,
			padding = { 0, 0 },
			wo = {
				winblend = 15,
			},
		},
		show_help = false,
		show_keys = false,
		layout = {
			width = { min = 15, max = 25 },
			spacing = 2, -- Reduced spacing between columns from 3 to 2
		},
		icons = {
			mappings = false,
			rules = false,
			group = "",
			separator = "⠂",
		},
		replace = {
			key = {
				function(key)
					return require("which-key.view").format(key)
				end,
			},
			desc = {
				{ "<Plug>%(?(.*)%)?", "%1" },
				{ "^%+", "" },
				{ "<[cC]md>", "" },
				{ "<[cC][rR]>", "" },
				{ "<[sS]ilent>", "" },
				{ "^lua%s+", "" },
				{ "^call%s+", "" },
				{ "^:%s*", "" },
				function(desc)
					-- Limit the description to 20 characters
					if #desc > 20 then
						return desc:sub(1, 18) .. "…"
					end
					return desc
				end,
			},
		},
		filter = function(mapping)
			-- Hide LSP mappings if no LSP client is active in the current buffer
			local is_lsp = false
			if
				mapping.desc
				and (
					mapping.desc:lower():find("lsp")
					or mapping.desc:lower():find("definition")
					or mapping.desc:lower():find("declaration")
					or mapping.desc:lower():find("references")
					or mapping.desc:lower():find("outline")
					or mapping.desc:lower():find("rename")
				)
			then
				is_lsp = true
			elseif type(mapping.rhs) == "string" and mapping.rhs:find("vim%.lsp") then
				is_lsp = true
			end

			if is_lsp then
				local clients = vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = 0 }) or {}
				if #clients == 0 then
					return false
				end
			end

			-- Hide Treesitter mappings if Treesitter parser is not active in the current buffer
			local is_ts = false
			if
				mapping.desc
				and (
					mapping.desc:lower():find("class")
					or mapping.desc:lower():find("function")
					or mapping.desc:lower():find("textobject")
					or mapping.desc:lower():find("treesitter")
				)
			then
				is_ts = true
			end

			if is_ts then
				local ok, parser = pcall(vim.treesitter.get_parser, 0)
				if not ok or not parser then
					return false
				end
			end

			return true
		end,
		spec = {
			{ "<leader>b", group = "Buffers/Tabs" },
			{ "<leader>c", group = "Code/LSP" },
			{ "<leader>h", group = "Harpoon" },
			{ "<leader>s", group = "Search/Find" },
			{ "<leader>u", group = "UI Toggles" },
			{ "<leader>w", group = "Sandwich" },
			{ "<leader>x", group = "Trouble/Diagnostics" },
			-- Clean up 'g' command descriptions
			{ "gb", desc = "Bookmarks (netrw)" },
			{ "gd", desc = "Go to definition" },
			{ "gf", desc = "Go to file" },
			{ "gh", desc = "Toggle dotfiles (netrw)" },
			{ "gn", desc = "Select next match" },
			{ "gp", desc = "Preview position (netrw)" },
			{ "gN", desc = "Select prev match" },
			{ "go", desc = "Document outline" },
			{ "gt", desc = "Next tab" },
			{ "gT", desc = "Prev tab" },
			{ "g%", desc = "Cycle match groups" },
			{ "g,", desc = "Newer change" },
			{ "g;", desc = "Older change" },
			{ "g~", desc = "Toggle case" },
			{ "gr", group = "LSP/References" },
			-- Jump/navigation groups
			{ "]", group = "Next" },
			{ "[", group = "Prev" },
			-- Treesitter
			{ "]c", desc = "Next class" },
			{ "[c", desc = "Prev class" },
			{ "]f", desc = "Next function" },
			{ "[f", desc = "Prev function" },
			{ "]b", desc = "Next block" },
			{ "[b", desc = "Prev block" },
			{ "]F", desc = "Next function end" },
			{ "[F", desc = "Prev function end" },
			{ "]m", desc = "Next method start" },
			{ "[m", desc = "Prev method start" },
			{ "]M", desc = "Next method end" },
			{ "[M", desc = "Prev method end" },
			{ "]}", desc = "Next block end" },
			{ "[{", desc = "Prev block start" },
			{ "]]", desc = "Next section start" },
			{ "[[", desc = "Prev section start" },
			{ "][", desc = "Next section end" },
			{ "[]", desc = "Prev section end" },
			-- Diagnostics
			{ "]d", desc = "Next diagnostic" },
			{ "[d", desc = "Prev diagnostic" },
			{ "]D", desc = "Last diagnostic" },
			{ "[D", desc = "First diagnostic" },
			{ "]e", desc = "Next error" },
			{ "[e", desc = "Prev error" },
			-- Spell
			{ "]s", desc = "Next misspelled" },
			{ "[s", desc = "Prev misspelled" },
			-- Quickfix
			{ "]q", desc = "Next quickfix" },
			{ "[q", desc = "Prev quickfix" },
			{ "]Q", desc = "Last quickfix" },
			{ "[Q", desc = "First quickfix" },
			{ "]<C-Q>", desc = "Next file in quickfix" },
			{ "[<C-Q>", desc = "Prev file in quickfix" },
			-- Location list
			{ "]l", desc = "Next in loclist" },
			{ "[l", desc = "Prev in loclist" },
			{ "]L", desc = "Last in loclist" },
			{ "[L", desc = "First in loclist" },
			{ "]<C-L>", desc = "Next file in loclist" },
			{ "[<C-L>", desc = "Prev file in loclist" },
			-- Buffers / arglist
			{ "]B", desc = "Last buffer" },
			{ "[B", desc = "First buffer" },
			{ "]a", desc = "Next arglist" },
			{ "[a", desc = "Prev arglist" },
			{ "]A", desc = "Last arglist" },
			{ "[A", desc = "First arglist" },
			-- Tags
			{ "]t", desc = "Next TODO comment" },
			{ "[t", desc = "Prev TODO comment" },
			{ "]T", desc = "Last tag" },
			{ "[T", desc = "First tag" },
			{ "]<C-T>", desc = "Next preview tag" },
			{ "[<C-T>", desc = "Prev preview tag" },
		},
	},
}
