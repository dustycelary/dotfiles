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
			"php",
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

		-- use bash parser for sh, zsh, conf, env, and toml files
		vim.treesitter.language.register("bash", "sh")
		vim.treesitter.language.register("bash", "zsh")
		vim.treesitter.language.register("bash", "conf")
		vim.treesitter.language.register("bash", "env")
		vim.treesitter.language.register("bash", "toml")

		-- Try-except block movement options
		vim.keymap.set({ "n", "x", "o" }, "]x", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_next_start("@exception.outer", "textobjects")
			end
		end, { desc = "Next try-except block start" })

		vim.keymap.set({ "n", "x", "o" }, "[x", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_previous_start("@exception.outer", "textobjects")
			end
		end, { desc = "Prev try-except block start" })

		vim.keymap.set({ "n", "x", "o" }, "]X", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_next_end("@exception.outer", "textobjects")
			end
		end, { desc = "Next try-except block end" })

		vim.keymap.set({ "n", "x", "o" }, "[X", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_previous_end("@exception.outer", "textobjects")
			end
		end, { desc = "Prev try-except block end" })

		vim.keymap.set({ "n", "x", "o" }, "]e", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_next_start("@exception.outer", "textobjects")
			end
		end, { desc = "Next try-except block start" })

		vim.keymap.set({ "n", "x", "o" }, "[e", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_previous_start("@exception.outer", "textobjects")
			end
		end, { desc = "Prev try-except block start" })

		vim.keymap.set({ "n", "x", "o" }, "]E", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_next_end("@exception.outer", "textobjects")
			end
		end, { desc = "Next try-except block end" })

		vim.keymap.set({ "n", "x", "o" }, "[E", function()
			local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
			if ok then
				move.goto_previous_end("@exception.outer", "textobjects")
			end
		end, { desc = "Prev try-except block end" })

		-- Select try-except block textobjects
		vim.keymap.set({ "x", "o" }, "ax", function()
			local ok, select = pcall(require, "nvim-treesitter-textobjects.select")
			if ok then
				select.select_textobject("@exception.outer", "textobjects")
			end
		end, { desc = "Select outer part of a try-except block" })

		vim.keymap.set({ "x", "o" }, "ix", function()
			local ok, select = pcall(require, "nvim-treesitter-textobjects.select")
			if ok then
				select.select_textobject("@exception.inner", "textobjects")
			end
		end, { desc = "Select inner part of a try-except block" })

		vim.keymap.set({ "x", "o" }, "ae", function()
			local ok, select = pcall(require, "nvim-treesitter-textobjects.select")
			if ok then
				select.select_textobject("@exception.outer", "textobjects")
			end
		end, { desc = "Select outer part of a try-except block" })

		vim.keymap.set({ "x", "o" }, "ie", function()
			local ok, select = pcall(require, "nvim-treesitter-textobjects.select")
			if ok then
				select.select_textobject("@exception.inner", "textobjects")
			end
		end, { desc = "Select inner part of a try-except block" })

		-- Highlight current try-except block under cursor
		local function highlight_try_except()
			local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
			local node = ok and ts_utils.get_node_at_cursor() or vim.treesitter.get_node()
			while node do
				local node_type = node:type()
				if
					node_type:match("try")
					or node_type:match("except")
					or node_type:match("catch")
					or node_type:match("finally")
				then
					local current = node
					while current:parent() do
						local ptype = current:parent():type()
						if ptype:match("try") or ptype:match("except") or ptype:match("catch") or ptype:match("finally") then
							current = current:parent()
						else
							break
						end
					end
					local srow, scol, erow, ecol = current:range()
					local ns = vim.api.nvim_create_namespace("treesitter_try_except_hl")
					vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
					vim.hl.range(0, ns, "CurSearch", { srow, scol }, { erow, ecol }, { timeout = 2000 })
					vim.notify("Highlighted try-except block", vim.log.levels.INFO, { title = "Treesitter" })
					return
				end
				node = node:parent()
			end
			vim.notify("No try-except block found under cursor", vim.log.levels.WARN, { title = "Treesitter" })
		end

		vim.keymap.set("n", "<leader>hx", highlight_try_except, { desc = "Highlight try-except block" })
		vim.keymap.set("n", "<leader>he", highlight_try_except, { desc = "Highlight try-except block" })
	end,
}
