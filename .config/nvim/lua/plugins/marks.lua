-- marks.nvim — visual mark indicators in the sign column & mark navigation/quickfix.
return {
	"chentoast/marks.nvim",
	event = "VeryLazy",
	opts = {
		default_mappings = true,
		builtin_marks = { ".", "^", "<", ">" },
		cyclic = true,
		force_write_shada = false,
		refresh_interval = 250,
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		bookmark_0 = {
			sign = "⚑",
			virt_text = "bookmark",
			annotate = false,
		},
		mappings = {},
	},
	config = function(_, opts)
		require("marks").setup(opts)

		local function marks_to_list(is_workspace, use_loclist)
			local items = {}
			local mark_list = is_workspace and vim.fn.getmarklist() or vim.fn.getmarklist("%")

			for _, mark in ipairs(mark_list) do
				local name = mark.mark:sub(2)
				if name:match("[a-zA-Z0-9'\".^<>[]]") then
					local bufnr = mark.pos[1]
					local lnum = mark.pos[2]
					local col = mark.pos[3]
					local filename = mark.file or (bufnr > 0 and vim.api.nvim_buf_get_name(bufnr) or "")

					if lnum > 0 then
						local line_text = ""
						if bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
							local lines = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)
							line_text = lines[1] or ""
						elseif filename ~= "" and vim.fn.filereadable(filename) == 1 then
							local read_lines = vim.fn.readfile(filename, "", lnum)
							line_text = read_lines[#read_lines] or ""
						end

						table.insert(items, {
							bufnr = bufnr > 0 and bufnr or nil,
							filename = filename ~= "" and filename or nil,
							lnum = lnum,
							col = col,
							text = string.format("Mark '%s': %s", name, vim.trim(line_text)),
						})
					end
				end
			end

			if #items == 0 then
				vim.notify("No marks found", vim.log.levels.WARN)
				return
			end

			table.sort(items, function(a, b)
				if a.filename and b.filename and a.filename ~= b.filename then
					return a.filename < b.filename
				end
				return a.lnum < b.lnum
			end)

			local title = is_workspace and "Workspace Marks" or "Active File Marks"
			if use_loclist then
				vim.fn.setloclist(0, {}, " ", { title = title, items = items })
				vim.cmd("lopen")
			else
				vim.fn.setqflist({}, " ", { title = title, items = items })
				vim.cmd("copen")
			end
		end

		-- Keymaps for Marks -> Quickfix / Loclist
		vim.keymap.set("n", "<leader>mq", function()
			marks_to_list(false, false)
		end, { desc = "Active file marks → Quickfix" })

		vim.keymap.set("n", "<leader>ml", function()
			marks_to_list(false, true)
		end, { desc = "Active file marks → Loclist" })

		vim.keymap.set("n", "<leader>mQ", function()
			marks_to_list(true, false)
		end, { desc = "Workspace marks → Quickfix" })
	end,
}
