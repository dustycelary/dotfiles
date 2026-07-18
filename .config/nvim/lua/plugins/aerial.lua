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
		backends = {
			["_"] = { "treesitter", "lsp" },
			markdown = { "markdown", "lsp" },
			man = { "man", "lsp" },
			toml = { "toml", "lsp" },
			python = { "treesitter", "lsp" },
		},

		nav = {
			preview = true,
		},

		disable_by_filetype = {},

		layout = {
			default_direction = "right",
			max_width = { 40, 0.2 },
			width = 30,
			min_width = 10,
		},

		show_guides = true,
		highlight_mode = "full_width",

		icons = {
			-- ... (Keep your existing icons table here) ...
		},

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
			"Heading",
			"Type",
			"Component",
			"Collapsed",
			"Variable", -- Added so Python scripts don't appear empty
		},
	},
	config = function(_, opts)
		require("aerial").setup(opts)

		-- Global winbar function to display breadcrumbs dynamically
		function _G.get_winbar()
			return vim.b.winbar_cache or " %f"
		end

		local winbar_group = vim.api.nvim_create_augroup("AerialWinbar", { clear = true })
		vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
			group = winbar_group,
			callback = function()
				local buftype = vim.bo.buftype
				if buftype == "nofile" or buftype == "prompt" or buftype == "quickfix" or buftype == "terminal" then
					vim.b.winbar_cache = ""
					return
				end
				local filetype = vim.bo.filetype
				if
					filetype == "aerial"
					or filetype == "fzf"
					or filetype == "lazy"
					or filetype == "mason"
					or filetype == "which-key"
				then
					vim.b.winbar_cache = ""
					return
				end

				local ok, aerial = pcall(require, "aerial")
				if not ok or not aerial.get_location then
					vim.b.winbar_cache = ""
					return
				end

				local symbols = aerial.get_location(true)
				if not symbols or #symbols == 0 then
					vim.b.winbar_cache = " %f"
					return
				end

				local parts = {}
				for _, symbol in ipairs(symbols) do
					if symbol.icon and symbol.icon ~= "" then
						table.insert(parts, symbol.icon .. " " .. symbol.name)
					else
						table.insert(parts, symbol.name)
					end
				end

				vim.b.winbar_cache = " %f  ›  " .. table.concat(parts, " › ")
			end,
		})

		vim.o.winbar = "%{%v:lua.get_winbar()%}"
	end,
}
