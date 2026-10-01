-- snacks.nvim — notifier replaces raw vim.notify (which can't render
-- multi-line messages like the LSP client list). rename gives LSP-aware
-- file renaming; the Oil hookup lives in oil.lua's OilActionsPost autocmd.
-- quickfile renders the initial buffer before other plugins load, which
-- only works if snacks itself loads eagerly — hence lazy = false, per
-- upstream's own recommended config for bigfile/quickfile/dashboard users.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		notifier = { enabled = true },
		quickfile = { enabled = true },
		-- image renders pictures, PDFs and LaTeX math as real pixels via the
		-- Kitty graphics protocol, which Ghostty implements. Math needs the
		-- `latex` treesitter parser to locate expressions and `tectonic` to
		-- typeset them; `magick` crops the result.
		image = {
			enabled = true,
			-- conceal defaults to true for math, which overlays the image onto
			-- existing buffer lines instead of reserving space. A formula taller
			-- than one cell row (46px vs this terminal's 29px) then spills its
			-- second row over the next line of text. false switches snacks to
			-- virt_lines, which reserve real rows, at the cost of still showing
			-- the $$...$$ source above the render.
			doc = { conceal = false },
		},
	},
	keys = {
		{
			"<leader>cr",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename file",
		},
	},
}
