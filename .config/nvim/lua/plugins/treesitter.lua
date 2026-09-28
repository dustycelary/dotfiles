return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main", -- Required for Neovim 0.12+
	build = ":TSUpdate",
	dependencies = { "shushtain/incselect.nvim" },
	config = function()
		require("nvim-treesitter").setup()

		-- install missing parsers asynchronously, deferred past startup
		-- (excluding Nvim built-ins: c, lua, vim, vimdoc, query, markdown, markdown_inline)
		-- install() already no-ops per-parser against what's on disk; deferring the
		-- call just keeps that check off the synchronous startup path.
		vim.schedule(function()
			-- Full list on desktop; on Pi install only what you edit daily.
			-- Each extra parser is disk + compile time + highlight cost.
			-- Add more later with :TSInstall <lang>.
			local parsers = require("is_pi").is_pi and {
				"bash",
				"python",
				"toml",
				"yaml",
			} or {
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
				"php",
				"toml",
			}
			require("nvim-treesitter").install(parsers)
		end)

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
		vim.keymap.set("n", "<S-CR>", require("incselect").init, { desc = "Select node under cursor" })
		vim.keymap.set("x", "<S-CR>", require("incselect").parent, { desc = "Expand selection to parent node" })
		vim.keymap.set("x", "<bs>", require("incselect").undo, { desc = "Shrink selection to previous node" })

		-- use bash parser for sh, zsh, conf, env, and toml files
		vim.treesitter.language.register("bash", "sh")
		vim.treesitter.language.register("bash", "zsh")
		vim.treesitter.language.register("bash", "conf")
		vim.treesitter.language.register("bash", "env")

		-- Try-except block movement options
	end,
}
