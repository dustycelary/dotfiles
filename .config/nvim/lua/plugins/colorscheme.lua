-- nightfox.nvim — colorscheme, using the carbonfox variant (dark, IBM Carbon-inspired).
-- Deuteranomaly colorblind correction enabled at severity 0.6.
-- Styles: italic comments/types, bold keywords/functions.
-- Visual selection overridden to steel blue (#1e3a5f) — the default is near-invisible.
-- Run :NightfoxCompile after changing config here to recompile the cache.
return {
	"EdenEast/nightfox.nvim",
	lazy = false, -- load during startup, it's the main UI theme
	priority = 1000, -- load before all other plugins so highlights are correct
	config = function()
		require("nightfox").setup({
			options = {
				-- compile_path = vim.fn.stdpath("cache") .. "/nightfox"  -- default
				-- compile_file_suffix = "_compiled"                       -- default
				transparent = false, -- disable setting background
				terminal_colors = true, -- set vim.g.terminal_color_* for :terminal
				dim_inactive = false, -- dim non-focused panes to alternative bg
				module_default = true, -- enable all plugin modules by default

				-- colorblind = {
				-- 	enable = true,         -- daltonize palette for deuteranomaly
				-- 	simulate_only = false, -- false = actually shift colors (not just simulate)
				-- 	severity = {
				-- 		protan = 0,   -- no red weakness
				-- 		deutan = 0.6, -- moderate green weakness
				-- 		tritan = 0,   -- no blue weakness
				-- 	},
				-- },

				-- Style applied to syntax groups. Any valid :help attr-list value.
				styles = {
					comments = "italic", -- grey italics; visually recede
					conditionals = "NONE",
					constants = "NONE",
					functions = "bold", -- function names stand out
					keywords = "bold", -- if/for/return etc pop without color change
					numbers = "NONE",
					operators = "NONE",
					strings = "NONE",
					types = "italic", -- type names subtly distinct from identifiers
					variables = "NONE",
				},

				inverse = {
					match_paren = false, -- invert matched parentheses highlight
					visual = false, -- invert visual selection colors
					search = false, -- invert search highlight
				},

				-- terminal_colors: when true, sets vim.g.terminal_color_0..15 so that
				-- :terminal buffers use carbonfox's palette instead of your terminal app's
				-- theme. Keeps colors consistent inside nvim. Leave on unless you have a
				-- carefully tuned terminal theme you'd rather keep.

				-- dim_inactive: when true, non-focused splits use bg0 (the darker
				-- background, ~#0f0f0f) instead of bg1 (#161616). Makes the active window
				-- clearly stand out when you have multiple splits open. Minor effect in
				-- practice; taste-dependent.

				-- colorblind: only relevant if you have a color vision deficiency. It
				-- runs a daltonization algorithm — simulates what you'd see with CVD, then
				-- shifts all palette colors toward your visible spectrum. severity 0 = off,
				-- 1 = full dichromacy. Leave disabled if you have normal color vision;
				-- it will make the theme look wrong.

				-- modules = {}  -- override individual plugin module settings here
			},

			groups = {
				carbonfox = {
					Visual = { bg = "#1e3a5f" }, -- bright steel blue selection

					-- CursorLine: carbonfox default is bg3 (#282828) — only 1 stop above
					-- bg1 (#161616), barely perceptible. Bumped to a blue-tinted grey so
					-- the current line has clear presence without being distracting.
					CursorLine = { bg = "#1a2233" },

					-- WinSeparator: the │ line between splits. Carbonfox leaves this at
					-- bg4 (#333333), which nearly disappears. Set to a muted blue-grey
					-- so splits have a visible boundary without looking aggressive.
					WinSeparator = { fg = "#3b4a6b" },

					-- PmenuSel: the selected item in completion menus, wildmenu, etc.
					-- Nightfox sets this per-theme in editor.lua but carbonfox inherits
					-- a generic value that doesn't match the Visual color — so menus and
					-- selections look inconsistent. Match it to Visual for coherence.
					PmenuSel = { bg = "#1e3a5f", fg = "fg1" },
				},
			},
		})

		vim.cmd.colorscheme("carbonfox")
	end,
}
