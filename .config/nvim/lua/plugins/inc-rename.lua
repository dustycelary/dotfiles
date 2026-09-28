-- inc-rename.nvim — LSP symbol rename with live preview.
--
-- Replaces the bare `vim.lsp.buf.rename` prompt (which showed nothing until you
-- confirmed) with an Ex command that renders every edit in place as you type,
-- using 'inccommand' — already "nosplit" in config.lua, which this needs.
-- File renames are a different thing and stay with Snacks (<leader>cr).
--
-- Loaded on LspAttach rather than `cmd = "IncRename"`: lazy's command stub would
-- create the command but not the preview callback, so the first rename of a
-- session would have no live preview.
return {
	"smjonas/inc-rename.nvim",
	event = "LspAttach",
	opts = {},
	keys = {
		{
			"<leader>cn",
			function()
				return ":IncRename " .. vim.fn.expand("<cword>")
			end,
			expr = true,
			desc = "Rename symbol (live preview)",
		},
	},
}
