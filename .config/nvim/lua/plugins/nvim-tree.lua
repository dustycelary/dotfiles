-- nvim-tree.lua — file tree sidebar plugin.
return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
	keys = {
		{ "<leader>ue", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file sidebar (NvimTree)" },
		{ "<leader>fe", "<cmd>NvimTreeFindFile<cr>", desc = "Find file in file sidebar" },
	},
	opts = {
		disable_netrw = false,
		hijack_netrw = false,
		sort = {
			sorter = "case_sensitive",
		},
		view = {
			width = 32,
			side = "left",
		},
		renderer = {
			group_empty = true,
			highlight_git = true,
			icons = {
				show = {
					file = true,
					folder = true,
					folder_arrow = true,
					git = true,
				},
				glyphs = {
					git = {
						unstaged = "~",
						staged = "✓",
						unmerged = "",
						renamed = "➜",
						untracked = "★",
						deleted = "",
						ignored = "◌",
					},
				},
			},
		},
		filters = {
			dotfiles = false,
		},
		actions = {
			open_file = {
				quit_on_open = false,
				window_picker = {
					enable = false,
				},
			},
		},
	},
}
