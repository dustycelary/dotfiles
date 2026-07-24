return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main", -- Required for Neovim 0.12+
	build = ":TSUpdate",
	dependencies = { "shushtain/incselect.nvim" },
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
			"toml",
		})

		-- enable highlighting and indenting
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if lang then
					-- Enables highlighting
					pcall(vim.treesitter.start, args.buf, lang)
					-- Enables indenting
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- set up incremental selection
		vim.keymap.set("n", "<C-CR>", require("incselect").init)
		vim.keymap.set("x", "<C-CR>", require("incselect").parent)
		vim.keymap.set("x", "<bs>", require("incselect").child)

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")
		vim.treesitter.language.register("bash", "conf")
		vim.treesitter.language.register("bash", "env")
		vim.treesitter.language.register("bash", "toml")
	end,
}
