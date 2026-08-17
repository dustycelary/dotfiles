-- edgy.nvim — manages left sidebar layout to stack NvimTree and Aerial top & bottom.
return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.splitkeep = "screen"
	end,
	opts = {
		left = {
			{
				title = "Files",
				ft = "NvimTree",
				pinned = true,
				open = "NvimTreeOpen",
				size = { height = 0.5 },
			},
			{
				title = "Aerial Outline",
				ft = "aerial",
				pinned = true,
				open = "AerialOpen",
				size = { height = 0.5 },
			},
		},
		options = {
			left = { size = 32 },
		},
		keys = {
			-- Edgebar window resizing keymaps (works when focused in edgy buffers)
			["<M-L>"] = function(win)
				win:resize("width", 2)
			end,
			["<M-H>"] = function(win)
				win:resize("width", -2)
			end,
			["<M-K>"] = function(win)
				win:resize("height", 2)
			end,
			["<M-J>"] = function(win)
				win:resize("height", -2)
			end,
			["<C-Right>"] = function(win)
				win:resize("width", 2)
			end,
			["<C-Left>"] = function(win)
				win:resize("width", -2)
			end,
			["<C-Up>"] = function(win)
				win:resize("height", 2)
			end,
			["<C-Down>"] = function(win)
				win:resize("height", -2)
			end,
		},
	},
}
