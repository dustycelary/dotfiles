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
			local ts = require("nvim-treesitter")
			local parsers = {
				"lua",
				"vim",
				"vimdoc",
				"python",
				"javascript",
				"typescript",
				"html",
				"css",
				"json",
				"yaml",
				"toml",
				"bash",
				"markdown",
				"markdown_inline",
			}
			for _, parser in ipairs(parsers) do
				ts.install(parser)
			end
			vim.treesitter.language.register("html", "htmldjango")
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
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
				{ "f", "@function.outer",    "@function.inner",    "function"            },
				{ "c", "@class.outer",       "@class.inner",       "class"               },
				{ "a", "@parameter.outer",   "@parameter.inner",   "argument"            },
				{ "b", "@block.outer",       "@block.inner",       "block"               },
				{ "I", "@conditional.outer", "@conditional.inner", "conditional"         },
				{ "l", "@loop.outer",        "@loop.inner",        "loop"                },
				{ "m", "@call.outer",        "@call.inner",        "call"                },
				{ "K", "@comment.outer",     "@comment.inner",     "comment"             },
				{ "=", "@assignment.outer",  "@assignment.inner",  "assignment", "assignment (rhs)" },
				{ "R", "@return.outer",      "@return.inner",      "return"              },
				{ "A", "@attribute.outer",   "@attribute.inner",   "attribute/decorator" },
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
			vim.keymap.set({ "x", "o" }, "iN", function()
				select.select_textobject("@number.inner", "textobjects")
			end, { desc = "inside number" })

			-- Indentation text object: ii = inner (same indent block), ai = around (+ line above)
			local function indent_textobj(inner)
				local cur = vim.fn.line(".")
				local total = vim.fn.line("$")
				while cur > 0 and vim.fn.getline(cur):match("^%s*$") do
					cur = cur - 1
				end
				if cur == 0 then return end
				local ref = vim.fn.indent(cur)
				local s, e = cur, cur
				while s > 1 do
					local prev = s - 1
					if not vim.fn.getline(prev):match("^%s*$") and vim.fn.indent(prev) < ref then break end
					s = prev
				end
				while e < total do
					local nxt = e + 1
					if not vim.fn.getline(nxt):match("^%s*$") and vim.fn.indent(nxt) < ref then break end
					e = nxt
				end
				if not inner and s > 1 then s = s - 1 end
				vim.cmd("normal! " .. s .. "GV" .. e .. "G")
			end
			vim.keymap.set({ "x", "o" }, "ii", function() indent_textobj(true) end,  { desc = "inside indent" })
			vim.keymap.set({ "x", "o" }, "ai", function() indent_textobj(false) end, { desc = "around indent" })

			-- Move between functions/classes
			local rep = require("nvim-treesitter-textobjects.repeatable_move")
			local func_start = rep.make_repeatable_move(function(opts)
				if opts.forward then
					move.goto_next_start("@function.outer", "textobjects")
				else
					move.goto_previous_start("@function.outer", "textobjects")
				end
			end)
			local func_end = rep.make_repeatable_move(function(opts)
				if opts.forward then
					move.goto_next_end("@function.outer", "textobjects")
				else
					move.goto_previous_end("@function.outer", "textobjects")
				end
			end)
			local class_start = rep.make_repeatable_move(function(opts)
				if opts.forward then
					move.goto_next_start("@class.outer", "textobjects")
				else
					move.goto_previous_start("@class.outer", "textobjects")
				end
			end)
			local block_motion = rep.make_repeatable_move(function(opts)
				if opts.forward then
					vim.cmd("normal! ]}")
				else
					vim.cmd("normal! [{")
				end
			end)
			local block_ts = rep.make_repeatable_move(function(opts)
				if opts.forward then
					move.goto_next_start("@block.outer", "textobjects")
				else
					move.goto_previous_start("@block.outer", "textobjects")
				end
			end)
			local section_fwd = rep.make_repeatable_move(function(opts)
				vim.cmd("normal! " .. (opts.forward and "]]" or "[["))
			end)
			local section_end = rep.make_repeatable_move(function(opts)
				vim.cmd("normal! " .. (opts.forward and "][" or "[]"))
			end)
			vim.keymap.set({ "n", "x", "o" }, "]b", function()
				block_ts({ forward = true })
			end, { desc = "next block start" })
			vim.keymap.set({ "n", "x", "o" }, "[b", function()
				block_ts({ forward = false })
			end, { desc = "prev block start" })
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				func_start({ forward = true })
			end, { desc = "next function start" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				func_start({ forward = false })
			end, { desc = "prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "]F", function()
				func_end({ forward = true })
			end, { desc = "next function end" })
			vim.keymap.set({ "n", "x", "o" }, "[F", function()
				func_end({ forward = false })
			end, { desc = "prev function end" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				class_start({ forward = true })
			end, { desc = "next class start" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				class_start({ forward = false })
			end, { desc = "prev class start" })
			vim.keymap.set({ "n", "x", "o" }, "]}", function()
				block_motion({ forward = true })
			end, { desc = "next block end" })
			vim.keymap.set({ "n", "x", "o" }, "[{", function()
				block_motion({ forward = false })
			end, { desc = "prev block start" })
			vim.keymap.set({ "n", "x", "o" }, "]]", function()
				section_fwd({ forward = true })
			end, { desc = "next section start" })
			vim.keymap.set({ "n", "x", "o" }, "[[", function()
				section_fwd({ forward = false })
			end, { desc = "prev section start" })
			vim.keymap.set({ "n", "x", "o" }, "][", function()
				section_end({ forward = true })
			end, { desc = "next section end" })
			vim.keymap.set({ "n", "x", "o" }, "[]", function()
				section_end({ forward = false })
			end, { desc = "prev section end" })

			-- Next/prev block at same indentation level
			local indent_move = rep.make_repeatable_move(function(opts)
				local cur = vim.fn.line(".")
				local total = vim.fn.line("$")
				local ref = vim.fn.indent(cur)
				if opts.forward then
					local i = cur + 1
					-- skip past current block
					while i <= total do
						if not vim.fn.getline(i):match("^%s*$") and vim.fn.indent(i) < ref then break end
						i = i + 1
					end
					-- find next line at same indent
					while i <= total do
						if not vim.fn.getline(i):match("^%s*$") and vim.fn.indent(i) == ref then
							vim.fn.cursor(i, 1)
							return
						end
						i = i + 1
					end
				else
					local i = cur - 1
					while i >= 1 do
						if not vim.fn.getline(i):match("^%s*$") and vim.fn.indent(i) < ref then break end
						i = i - 1
					end
					while i >= 1 do
						if not vim.fn.getline(i):match("^%s*$") and vim.fn.indent(i) == ref then
							vim.fn.cursor(i, 1)
							return
						end
						i = i - 1
					end
				end
			end)
			vim.keymap.set({ "n", "x", "o" }, "]i", function() indent_move({ forward = true }) end,  { desc = "next same-indent block" })
			vim.keymap.set({ "n", "x", "o" }, "[i", function() indent_move({ forward = false }) end, { desc = "prev same-indent block" })

			-- Quickfix jumps
			local qf_move = rep.make_repeatable_move(function(opts)
				if opts.forward then
					pcall(vim.cmd, "cnext")
				else
					pcall(vim.cmd, "cprev")
				end
			end)
			vim.keymap.set("n", "]q", function()
				qf_move({ forward = true })
			end, { desc = "Next quickfix" })
			vim.keymap.set("n", "[q", function()
				qf_move({ forward = false })
			end, { desc = "Prev quickfix" })

			-- Location list jumps
			local loc_move = rep.make_repeatable_move(function(opts)
				if opts.forward then
					pcall(vim.cmd, "lnext")
				else
					pcall(vim.cmd, "lprev")
				end
			end)
			vim.keymap.set("n", "]l", function()
				loc_move({ forward = true })
			end, { desc = "Next loclist" })
			vim.keymap.set("n", "[l", function()
				loc_move({ forward = false })
			end, { desc = "Prev loclist" })

			-- zH/zL (scroll half-screen left/right)
			local scroll_h = rep.make_repeatable_move(function(opts)
				vim.cmd("normal! " .. (opts.forward and "zL" or "zH"))
			end)
			vim.keymap.set({ "n", "x" }, "zL", function() scroll_h({ forward = true }) end,  { desc = "Scroll half-screen right (repeatable)" })
			vim.keymap.set({ "n", "x" }, "zH", function() scroll_h({ forward = false }) end, { desc = "Scroll half-screen left (repeatable)" })

			-- ; and , repeat the last treesitter move (or f/F/t/T if those were last)
			vim.keymap.set({ "n", "x", "o" }, ";", rep.repeat_last_move, { desc = "repeat last move" })
			vim.keymap.set(
				{ "n", "x", "o" },
				",",
				rep.repeat_last_move_opposite,
				{ desc = "repeat last move opposite" }
			)
			vim.keymap.set({ "n", "x", "o" }, "f", rep.builtin_f_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "F", rep.builtin_F_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "t", rep.builtin_t_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "T", rep.builtin_T_expr, { expr = true })
		end,
	},
}
