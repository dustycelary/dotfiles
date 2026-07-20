-- treesitter — syntax parsing, textobjects, context, and repeatable motions.
-- Three plugins bundled here:
--   nvim-treesitter-context: shows current function/class at top of window (max 3 lines).
--   nvim-treesitter + nvim-treesitter-textobjects: textobjects (af/if, ac/ic, aa/ia, etc.)
--     and motions (]f/[f functions, ]c/[c classes, ]b/[b blocks, etc.).
-- Non-obvious: ; and , repeat the last treesitter move (overrides default ; and ,).
--   f/F/t/T are wrapped to participate in the same repeat system.
-- htmldjango is registered as an alias for the html parser.
-- Folding is driven by treesitter (foldmethod=expr in init.lua).
return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = { max_lines = 3 },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
				highlight = { enable = true }, -- This replaces the need for the autocmd
			})
			vim.treesitter.language.register("html", "htmldjango")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { { "nvim-treesitter/nvim-treesitter", branch = "main" } },
		event = { "BufReadPost", "BufNewFile" },
		init = function()
			vim.g.no_plugin_maps = true
		end,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					include_surrounding_whitespace = false,
				},
				move = {
					set_jumps = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			local textobjects = {
				{ "f", "@function.outer", "@function.inner", "function definition & body", "function body" },
				{ "c", "@class.outer", "@class.inner", "class definition & body", "class body" },
				{
					"a",
					"@parameter.outer",
					"@parameter.inner",
					"argument/parameter (incl. comma)",
					"argument/parameter",
				},
				{ "B", "@block.outer", "@block.inner", "block / braces {}", "block contents" },
				{ "I", "@conditional.outer", "@conditional.inner", "conditional (if/else)", "conditional body" },
				{ "l", "@loop.outer", "@loop.inner", "loop statement", "loop body" },
				{ "m", "@call.outer", "@call.inner", "function call (name & args)", "call arguments" },
				{ "K", "@comment.outer", "@comment.inner", "comment block", "comment text" },
				{ "=", "@assignment.outer", "@assignment.inner", "full assignment", "assignment RHS value" },
				{ "R", "@return.outer", "@return.inner", "return statement", "return expression" },
				{ "A", "@attribute.outer", "@attribute.inner", "attribute/decorator", "attribute name" },
			}
			for _, obj in ipairs(textobjects) do
				local key, outer, inner, name, iname = obj[1], obj[2], obj[3], obj[4], obj[5]
				vim.keymap.set({ "x", "o" }, "a" .. key, function()
					select.select_textobject(outer, "textobjects")
				end, { desc = "around " .. name })
				vim.keymap.set({ "x", "o" }, "i" .. key, function()
					select.select_textobject(inner, "textobjects")
				end, { desc = "inside " .. (iname or name) })
			end

			-- Move between functions/classes/blocks directly
			vim.keymap.set({ "n", "x", "o" }, "]b", function()
				move.goto_next_start("@block.outer", "textobjects")
			end, { desc = "next block start" })
			vim.keymap.set({ "n", "x", "o" }, "[b", function()
				move.goto_previous_start("@block.outer", "textobjects")
			end, { desc = "prev block start" })
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "next function start" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "]F", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "next function end" })
			vim.keymap.set({ "n", "x", "o" }, "[F", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "prev function end" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "next class start" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "prev class start" })
		end,
	},
}
