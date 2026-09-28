# todo

- [ ] add settings that make it easier to navigate files or windows/splits
- [ ] add comamnds like:
  - <leader>ff → files in current project
  - <leader>fh → files in home directory
  - <leader>fu → files in ~/Uni
  - <leader>dn → files in ~/Documents
- [ ] another way to quickly search buffers.
- [ ] can i bookmark directories or files that i can access from any working directory, that just makes it easy to find them, persistent and global, and easy to search them all.

- [ ] how to change fzf lua so i don't have this issue with not enough space [image]('/Users/fungus/Documents/screenshots/Screenshot\ 2026-09-28\ at\ 04.44.27.png')
- [ ] change <leader>space so it does a quick search of buffers?

- [x] add vim fugitive
- [x] change toggle git blame to <leader>ub, then remove the now empty which-key group.
- [x] revert indent blankline to how it was.

# questions

- [x] what is the dots appearing after i'm doing spaces after - [ ] in markdown file?
- [x] How did you change blink? wahts the new settings? whats the new ui?
- [x] how did you change indent logic? did you do the point about improving it to treeistter based indentation?
- [x] how to use new notifiy plugin?

## Tier 0 — things that were actually broken (re-audited 2026-09-28: all resolved)

- [x] **1. `conform` couldn't find mason-installed `ruff`** — `config.lua:7-17` now prepends `stdpath("data")/mason/bin` to `$PATH`.
- [x] **2. `nvim-autopairs` was wired to deleted `nvim-cmp`** — `autopairs.lua` no longer depends on or `pcall(require, "cmp")`; brackets-on-accept is handled by blink's own `completion.accept.auto_brackets`.
- [x] **3. `[d`/`]d`/`[e`/`]e` didn't exist without an LSP attached** — moved to `keymaps.lua:10-21`, loaded unconditionally.
- [x] **4. Phantom which-key groups** (`<leader>g`, `<leader>w`, `<leader>t`) — `which-key.lua`'s spec no longer declares them; no dead-end menus.
- [x] **5. `lazy-lock.json` out of sync** — no stale `nvim-cmp`/`lsp_signature`/`csvview` entries; `blink.cmp` and `persistence.nvim` are pinned.
- [x] **6. `yamlls` capability hack** — now disables `documentFormattingProvider` via `on_init` (`lsp.lua:149-151`), before the client is live, instead of mutating an attached client inside `LspAttach`.

## Tier 0 — LSP / completion modernization (re-audited: all resolved)

- [x] **7. Manual enable loop** — removed; `lsp.lua` only declares `vim.lsp.config` per server and relies on mason-lspconfig's `automatic_enable`.
- [x] **8. `basedpyright` deprecated `pythonPath`** — replaced with dynamic `venvPath`/`venv` resolution (`lsp.lua:50-81`, `before_init`), plus `analysis.pythonVersion`.
- [ ] **9. `lazydev` blink integration** — still registered manually via `sources.providers.lazydev` (`completion.lua:104-110`) rather than `lazydev.nvim`'s `integrations.blink_cmp = true`. Both work; low priority to change.
- [x] **10. `use_nvim_cmp_as_default`** — gone from `completion.lua`.
- [x] **11. LuaSnip vs blink** — only `change_choice` is still wired to LuaSnip directly (the one thing blink has no command for); forward/backward jump is owned by blink. `version = "v2.*"` pin removed in favor of `version = "*"`.
- [x] **12. blink keymap nits** — keymap `preset` is now `"enter"` (accepts only when something is explicitly selected); the old `default`-preset/Helix mismatch no longer applies.

## Tier 1 — 0.11/0.12 built-ins (re-audited: all resolved)

- [x] **13. Treesitter-based indentation** — `config.lua:40-53` sets `indentexpr` to `nvim-treesitter`'s per-buffer when a parser has an `indents` query, falling back to `autoindent` otherwise.
- [x] **14. `vim.opt.winborder = "rounded"`** — set globally (`config.lua:94`); removed the one remaining redundant per-plugin `border = "rounded"` in `which-key.lua`.
- [x] **15. Missing options** — `inccommand`, `splitkeep`, `completeopt`, `timeoutlen` were already set; added `list` + `listchars` (`config.lua`).
- [x] **16. Notifications** — `snacks.notifier` enabled (`snacks.lua`).
- [x] **17. lazy.nvim checker** — `checker.enabled` and `change_detection.notify` already set in `init.lua`.

## Tier 2 — startup (re-audited 2026-09-28)

- [x] `vim.loader.enable()` added (`init.lua:1-3`) — caches compiled Lua bytecode.
- [x] `mason.nvim` / `mason-lspconfig` — already event-loaded (`BufReadPre`/`BufNewFile`), not `lazy = false`.
- [x] `nvim-treesitter` parser install — deferred via `vim.schedule` and no-ops per-parser already on disk; not a real per-launch cost.
- [x] `snacks.nvim` switched from `lazy = false` to `event = "VeryLazy"`.
- **`oil.nvim` stays `lazy = false` — deliberately.** It's `default_file_explorer = true` with netrw disabled, so it needs to be loaded *before* a directory buffer is created (e.g. `nvim .` or `:e some_dir/`) to intercept it. Lazy-loading only via the `keys = { "-" }` trigger would silently break "open a directory, get the Oil explorer" on cold start. Per your own `--startuptime` log, `oil` + its deps cost ~2ms total — not worth trading that behavior away for.

Re-measure with `nvim --startuptime /tmp/st.log +q` and `:Lazy profile` if startup ever regresses again.
