- how to remap keys to make them make more sense.
- how to increase speed of nvim?

- is there a better use for <space><space>

# todo

- [x] change toggle git blame to <leader>ub, then remove the now empty which-key group.
- [x] revert indent blankline to how it was.

# questions

- [x] what is the dots appearing after i'm doing spaces after - [ ] in markdown file?
- [ ] How did you change blink? wahts the new settings? whats the new ui?
- [ ] how did you change indent logic? did you do the point about improving it to treeistter based indentation?
- [ ] how to use new notifiy plugin?

## Tier 0 — things that are actually broken

**1. `conform` can't find your mason-installed `ruff`**
`lua/config.lua:6` prepends only Homebrew paths, never `$MASON/bin`. `ruff` exists *only* in `~/.local/share/nvim/mason/bin` (I checked — it's there, along with `stylua`, `clang-format`, `prettier`, `markdownlint`, which resolve via nvm/homebrew). Result: `python = { "ruff_fix", "ruff_format", "ruff_organize_imports" }` (`lua/plugins/lsp.lua:229`) silently no-ops on save, because `lsp_fallback` can't save you either (basedpyright isn't a formatter). `djlint` (`lsp.lua:228`) isn't installed anywhere at all.
→ Add `vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH` to `config.lua`, and decide on `djlint` (install via mason, or drop the `htmldjango` entry — `black`+`isort` are already installed for Python anyway).

**2. `nvim-autopairs` is still wired to the plugin you deleted**
`lua/plugins/autopairs.lua:7` has `dependencies = { "hrsh7th/nvim-cmp" }` and `autopairs.lua:19` does `pcall(require, "cmp")`. You migrated to blink.cmp, so `confirm_done` never fires and the auto-`()` on function completion is dead. `nvim-cmp` is still being installed because of this.
→ Drop the dep and the `pcall` block. blink's own `completion.accept.auto_brackets.enabled` (used by LazyVim) covers it.

**3. `[d` `]d` `[e` `]e` don't exist in a fresh `nvim`**
They're defined inside `nvim-lspconfig`'s `config = function()` (`lsp.lua:197-209`), which lazy only loads on `BufReadPre`. Open `nvim` with no file and the diagnostic jumps are unmapped. Also `lsp.lua:188-196` is a `pcall` fallback to `goto_next`/`goto_prev` — dead code on 0.12, and those calls are deprecated for 0.13.
→ Move the four maps to `keymaps.lua`, delete the fallback shim.

**4. Three phantom which-key groups**
`which-key.lua:37` advertises `<leader>g` "Git & Diffview" and `:48` advertises `<leader>w` "Windows & Splits"; `:46` advertises `<leader>t` "Tabs". You deleted `diffview.lua` (uncommitted) and there are zero `<leader>w*`, `<leader>t*`, or `<leader>g*` mappings in the repo. Pressing space shows three dead-end menus.
→ Either fill them (lazygit + diffview, or `snacks`) or delete the three spec entries.

**5. `lazy-lock.json` is out of sync in both directions**
Stale entries for the deleted plugins: `nvim-cmp`, `cmp-buffer`, `cmp-cmdline`, `cmp-nvim-lsp`, `cmp-path`, `cmp_luasnip`, `lsp_signature`, `csvview`. Missing entirely: **`blink.cmp` and `persistence.nvim` are unpinned** — so your actual completion engine has no lock entry. Also two broken clone dirs in `lazy/`: `cmp-path DONE.cloning` and `golf.vim.cloning`.
→ `:Lazy clean`, then `:Lazy sync` to regenerate the lock, and commit it.

**6. `yamlls` capability hack**
`lsp.lua:152-156` mutates `client.server_capabilities.documentFormattingProvider` inside `LspAttach` — the effect is racy and mutates a live client.
→ Declare it in config instead: build per-server capabilities with that field removed and pass them via `vim.lsp.config("yamlls", { capabilities = ... })`.

## Tier 0 — LSP / completion modernization

**7. Your manual enable loop duplicates mason-lspconfig.** `lsp.lua:140-148` loops `get_installed_servers()` and calls `vim.lsp.config` + `vim.lsp.enable` for each. `automatic_enable` is now mason-lspconfig's default. Simplify to: only `vim.lsp.config(name, overrides)` for servers you customize, and use `automatic_enable = { exclude = { "emmet-ls", "tailwindcss", "dockerls" } }` — you currently have ~20 servers enabled, several overlapping (`html` + `emmet-ls`, `jsonls` + `vscode-json-language-server`).

**8. `basedpyright` uses a deprecated setting.** `python.pythonPath` (`lsp.lua:86`) is deprecated in favor of `venvPath` + `venv`. Also worth adding `analysis.pythonVersion`.

**9. `lazydev` blink integration missing.** `completion.lua:5-11` registers the provider by hand but omits `integrations = { blink_cmp = true }`, the documented way. Harmless today, breaks if lazydev's auto-detect changes.

**10. `appearance.use_nvim_cmp_as_default = true`** (`completion.lua:99`) is deprecated in blink — the nixvim docs even say "will be removed in a future release." Delete it.

**11. LuaSnip is fighting blink.** `completion.lua:36-50` maps raw `luasnip.jump`/`change_choice` to `<C-l>`/`<C-h>`, bypassing blink, which desyncs the menu's selected index. And blink's own UPGRADE.md says to *remove* the `version = "v2.*"` pin and the `make install_jsregexp` build (`completion.lua:17-18`) now that main-branch LuaSnip is supported.

**12. blink keymap nits.** `<C-e>` is remapped to `show/show_documentation/hide_documentation` (`completion.lua:94`) — that's not scroll-docs. `<CR> = { "accept", "fallback" }` means Enter inserts a newline whenever the menu is open-but-unselected. `preset = "default"` also means your completion keys don't match the Helix-flavored which-key layout; blink ships a `helix` preset.

## Tier 1 — adopt what 0.11/0.12 gives you for free

**13. Treesitter-based indentation.** You install `indents.scm` parsers but never enable them; `config.lua:27` is plain `autoindent`. One `FileType` line (`vim.bo.indentexpr = require("nvim-treesitter").indentexpr()`) gives real indentation for Python/Lua/YAML. Biggest single quality-of-life win on this list.

**14. `vim.opt.winborder = "rounded"`** replaces the per-plugin `border = "rounded"` scattered across `lsp.lua:33-36`, `oil.lua:41,57`, `bqf.lua:11`, `which-key.lua:18`.

**15. Missing options worth adding:** `inccommand = "nosplit"` (big win with treesitter on big files), `splitkeep = "screen"`, `completeopt = { "menuone", "noselect" }` (blink), `list` + `listchars`, `showmode`, `timeoutlen = 300` (1000 makes LSP/blink feel laggy).

**16. Notifications.** You're on raw `vim.notify` — `lsp.lua:49` tries to print a multi-line client list through it. `snacks.notifier` or `nvim-notify` fixes that.

**17. lazy.nvim itself:** `checker = { enabled = true }` and `change_detection.notify` in `init.lua:17-32` — you have neither, so you get no update notifications.

## Tier 2 — startup

Measured targets, not guesses: `mason.nvim` + `mason-lspconfig` are both `lazy = false` (`lsp.lua:2-12`) — switch to `mason-tool-installer` with `run_on_start = false` or `VeryLazy`. `nvim-treesitter` runs `install({...17 parsers})` on **every** startup (`treesitter.lua:11`). `oil.nvim` is `lazy = false` with a single `cmd` trigger available. Then measure with `nvim --startuptime /tmp/st.log +q` and `:Lazy profile`.
