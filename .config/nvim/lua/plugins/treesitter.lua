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
			"zsh",
			"dockerfile",
			"gitignore",
			"python",
			"toml",
		})

		-- enable highlighting
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if lang then
					-- Enables highlighting
					pcall(vim.treesitter.start, args.buf, lang)
				end
			end,
		})

		-- set up incremental selection (undo steps back through selection history)
		vim.keymap.set("n", "<S-CR>", require("incselect").init)
		vim.keymap.set("x", "<S-CR>", require("incselect").parent)
		vim.keymap.set("x", "<bs>", require("incselect").undo)

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "conf")
		vim.treesitter.language.register("bash", "env")
		vim.treesitter.language.register("bash", "toml")
	end,
}
