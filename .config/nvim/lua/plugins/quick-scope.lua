-- quick-scope — highlights the best f/F/t/T jump targets on the current line.
-- Runs in "vanilla" mode (highlights live as the cursor moves) rather than
-- quick-scope's own "keys" mode, which maps f/F/t/T itself only if those keys
-- are still unmapped when it loads (see `:h quick-scope-mappings`). This repo
-- remaps f/F/t/T globally in nvim-treesitter-text-objects.lua for repeatable
-- motions, which always wins the race since that plugin loads eagerly
-- (lazy = false) before quick-scope's VeryLazy-triggered setup runs — so
-- quick-scope's own mappings were silently skipped and highlighting never
-- fired. Vanilla mode sidesteps this entirely by not needing its own f/F/t/T
-- mappings at all.
return {
	"unblevable/quick-scope",
	event = "VeryLazy",
}
