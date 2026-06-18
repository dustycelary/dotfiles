-- lsp_signature.nvim — floating signature help while typing function arguments.
-- Appears automatically on InsertEnter when inside a function call.
-- <C-s> toggles the floating window. Virtual text hints disabled (too noisy).
-- Closes automatically after 4 seconds of no typing.
return {
	"ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	opts = {
		bind = true,
		handler_opts = { border = "rounded" },
		hint_enable = false, -- virtual text hints are noisy
		floating_window = true,
		floating_window_above_cur_line = true,
		close_timeout = 4000,
		toggle_key = "<C-s>",
		toggle_key_flip_floatwin_setting = true,
	},
}
