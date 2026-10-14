-- neotest — run tests from the editor with results in the sign column,
-- inline error messages on failing lines, and a summary tree.
-- Python via pytest; neotest-python picks up the project's .venv/venv on its
-- own, so pytest must be installed in that venv.
-- <leader>tt nearest test, tf file, ta whole suite, tl rerun last.
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					runner = "pytest",
				}),
			},
			output = { open_on_run = false },
			quickfix = { open = false },
		})
	end,
	keys = {
		{ "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
		{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file" },
		{ "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all tests" },
		{ "<leader>tl", function() require("neotest").run.run_last() end, desc = "Rerun last test" },
		{ "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop running tests" },
		{ "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle watch (file)" },
		{ "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
		{
			"<leader>to",
			function() require("neotest").output.open({ enter = true, auto_close = true }) end,
			desc = "Show test output",
		},
		{ "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
		{ "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
		{ "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Previous failed test" },
	},
}
