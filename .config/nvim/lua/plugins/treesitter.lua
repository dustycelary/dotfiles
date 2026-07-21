-- return {
-- 	"nvim-treesitter/nvim-treesitter",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	branch = "master", -- The 'main' branch is a full rewrite that removes incremental selection.
-- 	build = ":TSUpdate",
-- 	config = function()
-- 		local configs = require("nvim-treesitter.configs")
--
-- 		-- configure treesitter
-- 		configs.setup({
-- 			-- ensure these language parsers are installed
-- 			ensure_installed = {
-- 				"json",
-- 				"javascript",
-- 				"typescript",
-- 				"tsx",
-- 				"yaml",
-- 				"html",
-- 				"css",
-- 				"prisma",
-- 				"markdown",
-- 				"markdown_inline",
-- 				"svelte",
-- 				"graphql",
-- 				"bash",
-- 				"lua",
-- 				"vim",
-- 				"dockerfile",
-- 				"gitignore",
-- 				"query",
-- 				"vimdoc",
-- 				"c",
-- 				"python",
-- 			},
--
-- 			-- enable syntax highlighting
-- 			highlight = {
-- 				enable = true,
-- 			},
-- 			-- enable indentation
-- 			indent = { enable = true },
--
-- 			incremental_selection = {
-- 				enable = true,
-- 				keymaps = {
-- 					-- NOTE: <C-CR> might not work in many terminals as they don't distinguish it from <CR>.
-- 					-- If it still doesn't work, consider changing these to something like "<C-Space>" or "grn".
-- 					init_selection = "<C-CR>",
-- 					node_incremental = "<C-CR>",
-- 					scope_incremental = false,
-- 					node_decremental = "<bs>",
-- 				},
-- 			},
-- 		})
--
-- 		-- use bash parser for zsh files
-- 		vim.treesitter.language.register("bash", "zsh")
-- 		vim.treesitter.language.register("bash", "conf")
-- 		vim.treesitter.language.register("bash", "env")
-- 	end,
-- }
--

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main", -- Required for Neovim 0.12+
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		-- install parsers asynchronously (excluding Nvim built-ins: c, lua, vim, vimdoc, query, markdown, markdown_inline)
		require("nvim-treesitter").install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"prisma",
			"svelte",
			"graphql",
			"bash",
			"dockerfile",
			"gitignore",
			"python",
		})

		-- enable highlighting
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if lang then
					pcall(vim.treesitter.start, args.buf, lang)
				end
			end,
		})

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")
		vim.treesitter.language.register("bash", "conf")
		vim.treesitter.language.register("bash", "env")
	end,
}
