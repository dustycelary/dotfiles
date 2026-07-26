-- aerial.nvim — symbol sidebar and breadcrumb winbar.
-- Shows a tree of functions/classes/headings in a right-hand split (<leader>ua).
-- Drives the winbar breadcrumbs at the top of active code buffers.
return {
	"stevearc/aerial.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>ua", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial Symbol Sidebar" },
	},
	opts = {
		layout = {
			default_direction = "right",
			width = 30,
			min_width = 10,
		},
		show_guides = true,
		attach_mode = "global",
	},
	config = function(_, opts)
		require("aerial").setup(opts)

		-- Clean global winbar breadcrumbs function
		function _G.get_winbar()
			local ft, bt = vim.bo.filetype, vim.bo.buftype
			if bt ~= "" or ft == "aerial" or ft == "fzf" or ft == "lazy" or ft == "mason" or ft == "which-key" then
				return ""
			end
			local ok, aerial = pcall(require, "aerial")
			if not ok then
				return " %f"
			end
			local symbols = aerial.get_location(true)
			if #symbols == 0 then
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
