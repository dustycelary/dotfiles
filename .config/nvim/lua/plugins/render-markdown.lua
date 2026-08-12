-- render-markdown.nvim — renders markdown in-buffer: styled headings, concealed syntax,
-- code block backgrounds, list bullets, and checkboxes. Only active in markdown buffers.
-- <leader>um toggles render-markdown on/off.
-- return {
-- 	"MeanderingProgrammer/render-markdown.nvim",
-- 	dependencies = { "nvim-treesitter/nvim-treesitter" },
-- 	ft = { "markdown" },
-- 	keys = {
-- 		{ "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Render Markdown" },
-- 	},
-- 	opts = {
--
-- 		html = {
-- 			comment = {
-- 				conceal = false,
-- 			},
-- 		},
-- 	},
-- }
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "markdown" },
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Render Markdown" },
	},
	opts = {
		heading = {
			enabled = true,
			sign = true,
			icons = { "󰲡  ", "󰲣  ", "󰲥  ", "󰲧  ", "󰲩  ", "󰲫  " },
		},
		bullet = {
			enabled = true,
			icons = { "● ", "○ ", "◆ ", "◇ " },
			right_pad = 1,
		},
		checkbox = {
			enabled = true,
			left_pad = 0,
			right_pad = 1,
			unchecked = {
				icon = "󰄱 ",
				highlight = "RenderMarkdownUnchecked",
			},
			checked = {
				icon = "󰄵 ",
				highlight = "RenderMarkdownChecked",
				scope_highlight = "@markup.strikethrough",
			},
			custom = {
				todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
				important = { raw = "[!]", rendered = "󰀦 ", highlight = "DiagnosticWarn" },
			},
		},
		quote = {
			enabled = true,
			icon = "▋ ",
		},
		callout = {
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownNote" },
			tip = { raw = "[!TIP]", rendered = "󰌵 Tip", highlight = "RenderMarkdownTip" },
			warning = { raw = "[!WARNING]", rendered = "󰀦 Warning", highlight = "RenderMarkdownWarn" },
			caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
		},
		html = {
			comment = {
				conceal = false,
			},
		},
	},
}
