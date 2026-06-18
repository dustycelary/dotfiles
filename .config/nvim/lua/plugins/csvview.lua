-- csvview.nvim — renders CSV/TSV files as an aligned table with borders.
-- Auto-enables on *.csv and *.tsv. Sticky header stays visible while scrolling.
-- Delimiter auto-detected (tries ; , \t | in order). Toggle with :CsvViewToggle.
return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
	opts = {
		parser = {
			delimiter = {
				ft = { tsv = "\t" },
				fallbacks = { ";", ",", "\t", "|" },
			},
		},
		view = {
			display_mode = "border",
			sticky_header = { enabled = true },
			max_column_width = 30,
		},
	},
	init = function()
		local group = vim.api.nvim_create_augroup("csvview_auto_enable", { clear = true })
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
			group = group,
			pattern = { "*.csv", "*.tsv" },
			callback = function()
				vim.schedule(function()
					pcall(vim.cmd, "CsvViewEnable")
				end)
			end,
		})
	end,
}
