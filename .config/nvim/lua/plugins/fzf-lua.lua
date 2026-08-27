local function markdown_headings()
	local fzf = require("fzf-lua")
	local actions = require("fzf-lua.actions")
	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buf)

	if filename == "" then
		vim.notify("Save the Markdown file before searching its headings", vim.log.levels.WARN)
		return
	end

	local entries = {}
	local parents = {}
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local fence_char
	local fence_length

	local function add_heading(line_number, level, title)
		title = vim.trim(title:gsub("%s+#+%s*$", ""))
		parents[level] = title
		for deeper = level + 1, 6 do
			parents[deeper] = nil
		end

		local path = {}
		for depth = 1, level do
			if parents[depth] then
				path[#path + 1] = parents[depth]
			end
		end

		entries[#entries + 1] =
			string.format("%s:%d:1:H%d  %s", filename, line_number, level, table.concat(path, " › "))
	end

	for line_number, line in ipairs(lines) do
		local ticks = line:match("^%s*(`+)")
		local tildes = line:match("^%s*(~+)")
		local marker = ticks or tildes

		if marker and #marker >= 3 then
			local marker_char = marker:sub(1, 1)
			if not fence_char then
				fence_char = marker_char
				fence_length = #marker
			elseif marker_char == fence_char and #marker >= fence_length then
				fence_char = nil
				fence_length = nil
			end
		elseif not fence_char then
			local hashes, title = line:match("^%s*(#+)%s+(.+)$")
			if hashes and #hashes <= 6 then
				add_heading(line_number, #hashes, title)
			elseif line_number < #lines and line:match("%S") then
				local underline = lines[line_number + 1]
				if underline:match("^%s*=+%s*$") then
					add_heading(line_number, 1, line)
				elseif underline:match("^%s*%-+%s*$") then
					add_heading(line_number, 2, line)
				end
			end
		end
	end

	if #entries == 0 then
		vim.notify("No Markdown headings found", vim.log.levels.INFO)
		return
	end

	fzf.fzf_exec(entries, {
		prompt = "Markdown Headings> ",
		previewer = "builtin",
		actions = {
			["default"] = actions.file_edit,
			["ctrl-s"] = actions.file_split,
			["ctrl-v"] = actions.file_vsplit,
			["ctrl-t"] = actions.file_tabedit,
			["ctrl-q"] = actions.file_sel_to_qf,
			["ctrl-l"] = actions.file_sel_to_ll,
		},
		fzf_opts = {
			["--delimiter"] = ":",
			["--with-nth"] = "2..",
			["--nth"] = "4..",
			["--multi"] = true,
		},
	})
end

return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		local fzf_path = require("fzf-lua.path")

		-- 1. Unify actions in one table so we don't repeat ourselves
		local common_actions = {
			["default"] = fzf.actions.file_edit,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
			["ctrl-q"] = fzf.actions.file_sel_to_qf,
			["ctrl-l"] = fzf.actions.file_sel_to_ll,

			-- Note: Fixed alt-h to match your prompt's comment (was alt-u in your code)
			["alt-i"] = fzf.actions.toggle_ignore,
			["alt-u"] = fzf.actions.toggle_hidden,
		}

		fzf.setup({
			-- 2. Global settings for hidden and ignored files
			defaults = {
				hidden = false, -- Hide dotfiles by default; alt-u toggles them
				no_ignore = true, -- Include files ignored by .gitignore
				formatter = "path.filename_first",
			},
			lsp = {
				formatter = "path.filename_first",
			},
			actions = {
				-- Apply the exact same keymaps to files, grep, and LSP pickers
				files = common_actions,
				grep = common_actions,
				lsp = common_actions,
			},
			registers = {
				multiline = false,
				winopts = {
					preview = {
						layout = "horizontal",
						horizontal = "right:65%",
					},
				},
			},
			-- 3. We completely removed the hardcoded 'cmd' overrides and 'fd_excludes'.
			-- fzf-lua's defaults are already perfectly tuned for fd and ripgrep.
			-- By not hardcoding exclusions, your alt-i/alt-h toggles will now work correctly!
		})

		fzf.register_ui_select()
	end,
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Fzf Files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Fzf Grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Fzf Buffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Fzf Help" },
		{ "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Fzf Resume" },
		{ "<leader>fc", "<cmd>FzfLua command_history<cr>", desc = "Fzf Command History" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Fzf Keymaps" },
		{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Fzf Old Files" },
		{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Fzf Marks" },
		{ '<leader>f"', "<cmd>FzfLua registers<cr>", desc = "Fzf Registers" },
		{ "<leader>fs", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Fzf Workspace Symbols" },
		{ "<leader>fd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Fzf Workspace Diagnostics" },
		{ "<leader>fD", "<cmd>FzfLua diagnostics_document<cr>", desc = "Fzf Document Diagnostics" },
		{
			"go",
			function()
				if vim.bo.filetype == "markdown" then
					markdown_headings()
				else
					require("fzf-lua").lsp_document_symbols()
				end
			end,
			desc = "Document Symbols",
		},
		{ "<leader>f:", "<cmd>FzfLua commands<cr>", desc = "Fzf Commands" },
	},
}
