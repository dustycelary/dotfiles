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
		-- Press <leader>ua to pop the sidebar open or closed
		{ "<leader>ua", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial Symbol Sidebar" },
		{
			"<leader>uv",
			function()
				require("aerial")
				if _G.toggle_aerial_variables then
					_G.toggle_aerial_variables()
				end
			end,
			desc = "Toggle Aerial Variables & Constants",
		},
	},
	-- opts acts as the setup() function in lazy.nvim

	opts = {
		backends = {
			["_"] = { "treesitter", "lsp" },
			markdown = { "markdown", "lsp" },
			man = { "man", "lsp" },
			toml = { "treesitter", "lsp" },
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
			"Class",
			"Component",
			"Constructor",
			"Enum",
			"EnumMember",
			"Event",
			"Field",
			"File",
			"Function",
			"Heading",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Operator",
			"Package",
			"Property",
			"Struct",
			"Type",
			"TypeParameter",
			-- Value / Data symbols
			"Variable",
			"Constant",
			"Key",
			"Array",
			"Object",
		},
	},
	config = function(_, opts)
		require("aerial").setup(opts)

		local show_vars = true
		local full_kinds = {
			"Class",
			"Component",
			"Constructor",
			"Enum",
			"EnumMember",
			"Event",
			"Field",
			"File",
			"Function",
			"Heading",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Operator",
			"Package",
			"Property",
			"Struct",
			"Type",
			"TypeParameter",
			"Variable",
			"Constant",
			"Key",
			"Array",
			"Object",
		}
		local base_kinds = {
			"Class",
			"Component",
			"Constructor",
			"Enum",
			"EnumMember",
			"Event",
			"Field",
			"File",
			"Function",
			"Heading",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Operator",
			"Package",
			"Property",
			"Struct",
			"Type",
			"TypeParameter",
		}

		function _G.toggle_aerial_variables()
			show_vars = not show_vars
			local target_kinds = show_vars and full_kinds or base_kinds

			-- Update aerial.config.filter_kind in place
			local config = require("aerial.config")
			if type(config.filter_kind) == "table" then
				for k in pairs(config.filter_kind) do
					config.filter_kind[k] = nil
				end
				for i, v in ipairs(target_kinds) do
					config.filter_kind[i] = v
				end
			end

			-- Override buffer variable for current buffer
			local bufnr = vim.api.nvim_get_current_buf()
			vim.b[bufnr].aerial_filter_kind = target_kinds

			if show_vars then
				vim.notify("Aerial: Showing variables & constants", vim.log.levels.INFO)
			else
				vim.notify("Aerial: Hiding variables & constants", vim.log.levels.INFO)
			end

			-- Force active backend to re-fetch and render symbols
			local ok, backends = pcall(require, "aerial.backends")
			if ok then
				local backend = backends.get(bufnr)
				if backend and backend.fetch_symbols then
					backend.fetch_symbols(bufnr)
				end
			end
		end

		-- Bind 'V' inside Aerial sidebar window with nowait=true
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "aerial",
			callback = function(args)
				vim.keymap.set("n", "V", function()
					if _G.toggle_aerial_variables then
						_G.toggle_aerial_variables()
					end
				end, { buffer = args.buf, nowait = true, desc = "Toggle Variables in Aerial" })
			end,
		})

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
