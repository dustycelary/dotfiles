-- aerial.nvim — symbol sidebar and breadcrumb winbar.
-- Shows a tree of functions/classes/headings in a right-hand split (<leader>ua).
-- Drives the winbar breadcrumbs at the top of every buffer.
-- Non-obvious: <leader>sn opens a floating nav with preview; <leader>sa searches symbols via fzf.
-- Winbar is suppressed automatically on nofile/terminal/aerial/fzf buffers.
return {
	"stevearc/aerial.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons", -- For the little function/class icons
	},
	keys = {
		-- Press <leader>a to pop the sidebar open or closed
		{ "<leader>ua", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial Symbol Sidebar" },
		{
			"<leader>sa",
			function()
				require("aerial").fzf_lua_picker()
			end,
			desc = "Fzf Aerial Symbols",
		},
		{ "<leader>sn", "<cmd>AerialNavToggle<CR>", desc = "Toggle Aerial Floating Nav" },
	},
	-- opts acts as the setup() function in lazy.nvim
	opts = {
		-- For markdown, prioritize markdown backend over LSP
		backends = { "treesitter", "lsp", "markdown", "man", "toml" },

		-- Enable preview in the right box of the nav window
		nav = {
			preview = true,
		},

		-- Explicitly enable markdown support
		disable_by_filetype = {},

		layout = {
			-- You can set this to "left" or "right"
			default_direction = "right",
			-- Controls how wide the sidebar gets
			max_width = { 40, 0.2 },
			width = 30,
			min_width = 10,
		},

		-- Show a little floating window with the symbol details when you press '?'
		show_guides = true,

		-- Better highlighting
		highlight_mode = "full_width",

		icons = {
			File = "󰈙",
			Module = "",
			Namespace = "󰌗",
			Package = "󰏗",
			Class = "󰠱",
			Method = "󰆧",
			Property = "󰜢",
			Field = "󰜢",
			Constructor = "",
			Enum = "",
			Interface = "",
			Function = "󰊕",
			Variable = "󰀫",
			Constant = "󰏿",
			String = "󰀬",
			Number = "󰎠",
			Boolean = "󰨙",
			Array = "󰅪",
			Object = "󰅩",
			Key = "󰌋",
			Null = "󰟢",
			EnumMember = "",
			Struct = "󰙅",
			Event = "󰉁",
			Operator = "󰆕",
			TypeParameter = "󰊄",
			Component = "󰅴",
			Heading = "󰉫",
			Collapsed = "",
		},

		-- Configure which symbol kinds to show
		filter_kind = {
			"File",
			"Package",
			"Namespace",
			"Class",
			"Constructor",
			"Enum",
			"EnumMember",
			"Function",
			"Interface",
			"Module",
			"Method",
			"Property",
			"Field",
			"Struct",
			"TypeParameter",
			"Event",
			"Operator",
			"Heading", -- Important for markdown
			"Type",
			"Component",
			"Collapsed",
		},
	},
	config = function(_, opts)
		require("aerial").setup(opts)

		-- Global winbar function to display breadcrumbs dynamically
		function _G.get_winbar()
			local buftype = vim.bo.buftype
			if buftype == "nofile" or buftype == "prompt" or buftype == "quickfix" or buftype == "terminal" then
				return ""
			end
			local filetype = vim.bo.filetype
			if filetype == "aerial" or filetype == "fzf" or filetype == "lazy" or filetype == "mason" or filetype == "which-key" then
				return ""
			end

			local ok, aerial = pcall(require, "aerial")
			if not ok or not aerial.get_location then
				return ""
			end

			local symbols = aerial.get_location(true)
			if not symbols or #symbols == 0 then
				return " %f"
			end

			local parts = {}
			for _, symbol in ipairs(symbols) do
				if symbol.icon and symbol.icon ~= "" then
					table.insert(parts, symbol.icon .. " " .. symbol.name)
				else
					table.insert(parts, symbol.name)
				end
			end

			return " %f  ›  " .. table.concat(parts, " › ")
		end

		vim.o.winbar = "%{%v:lua.get_winbar()%}"
	end,
}
