# Neovim config changes — 2026-10-14

Everything changed or added in one session: completion fixes, keymap
clean-ups, and four new features (neotest, grug-far, yanky, markdown spell
check). Each section says which file it lives in and how to use it.

---

## 1. Completion & snippets (blink.cmp + LuaSnip)

**File:** `lua/plugins/completion.lua`

| Change | Why |
|---|---|
| `<Tab>` / `<S-Tab>` now jump snippet placeholders **first**, then move through the menu | Before, if the menu popped up inside a snippet (e.g. typing in a markdown table cell), `<Tab>` moved through the menu instead of jumping to the next placeholder |
| Removed `history = true` from LuaSnip | Finished snippets no longer stay "jumpable", so `<Tab>` can't throw the cursor back into an old snippet |
| `<C-l>` / `<C-h>` fall back to their normal behaviour when no snippet choice is active | They used to swallow the key; `<C-h>` is backspace in insert mode |
| Removed the unused `from_lua` snippet loader and blink's duplicate friendly-snippets dependency | Clean-up, no behaviour change |

### Completion keymaps (insert mode)

| Key | Action |
|---|---|
| `<C-Space>` / `<M-Space>` | Open menu; again toggles the documentation popup |
| `<C-e>` | Close menu |
| `<CR>` | Accept selected item (newline if nothing selected) |
| `<C-y>` | Select first item and accept |
| `<Tab>` / `<S-Tab>` | Next / previous snippet placeholder; otherwise next / previous menu item |
| `<C-n>` / `<C-p>`, `<Up>` / `<Down>` | Next / previous menu item (use these inside a snippet) |
| `<C-f>` / `<C-b>` | Scroll documentation popup |
| `<C-k>` | Toggle signature help |
| `<C-l>` / `<C-h>` | Next / previous option in a snippet choice (e.g. `TODO|FIXME|…`) |

The documentation popup opens automatically 200 ms after an item is
**selected**. Nothing is preselected, so select something to see docs.

### Using snippets

1. Type the prefix (e.g. `table` or `tc` in markdown), select it, press `<CR>`.
2. Type over the selected placeholder text, then `<Tab>` to the next one
   (`<Tab>` without typing keeps the default text). `<S-Tab>` goes back.
3. Custom snippets: add a JSON file to `snippets/` and register its language
   in `snippets/package.json`.

---

## 2. Colours

**File:** `lua/plugins/colorscheme.lua`

- Catppuccin integration `cmp = true` (nvim-cmp) → `blink_cmp = true`, so
  the completion menu is themed.

---

## 3. LSP & formatting

**File:** `lua/plugins/lsp.lua`

- Removed `vim.g.lsp_no_default_keymaps = true`. That setting doesn't exist,
  so it did nothing. Neovim's built-in LSP maps are active: `K` (hover),
  `grn`, `gra`, `grr`, `gri`, `grt`, `gO`.
- conform `format_on_save`: deprecated `lsp_fallback = true` →
  `lsp_format = "fallback"` (same behaviour, current option name).

**File:** `lua/plugins/snacks.lua`

- **Rename file** moved from `<leader>cr` → **`<leader>cR`**. `<leader>cr`
  was also References, and References won in every LSP buffer, so Rename
  file was unreachable there. Both are still in the Code & LSP group.

### LSP keymaps (normal mode)

| Key | Action |
|---|---|
| `K` | Hover documentation |
| `<leader>cd` / `cD` / `ct` / `cI` | Definition / declaration / type definition / implementations |
| `<leader>cr` | References → quickfix |
| `<leader>cR` | Rename file (updates imports via LSP) |
| `<leader>cn` | Rename symbol |
| `<leader>ca` | Code actions (also visual mode) |
| `<leader>cs` | Toggle signature help |
| `<leader>ce` / `cq` / `cl` | Diagnostic float / → quickfix / → location list |
| `<leader>cf` | Format buffer |
| `<leader>uf` / `ul` / `uV` | Toggle format on save / LSP for buffer / native virtual text |
| `<leader>ci` | Show attached LSP clients |

---

## 4. Markdown spell check

**File:** `lua/config.lua`, a `FileType` autocmd in the `UserConfig` group

Opening a markdown file runs `setlocal spell spelllang=en_us`. It's
buffer-local, so code files aren't affected. Treesitter limits checking to prose,
so code blocks and links aren't flagged. To cover more filetypes, extend the
pattern, e.g. `pattern = { "markdown", "gitcommit", "text" }`.

**File:** `lua/plugins/nvim-treesitter-text-objects.lua`

- Removed the `]s` "Next scope" motion. It overrode Vim's "next misspelled
  word" and had no `[s` partner.
- `]s` / `[s` are wrapped with the treesitter repeatable-move helper, so
  `;` / `,` repeat them like the other `]`/`[` motions.
- Class jumps moved from `]c` `[c` `]C` `[C` to **`]k` `[k` `]K` `[K`**
  (still repeatable with `;` / `,`). This gives `]c` / `[c` back to Vim, so
  in diff mode they jump between changes again.
- Class text objects renamed `ac` / `ic` → **`ak` / `ik`**, so every class
  key uses `k`: `dak` deletes a whole class, `yik` copies its body,
  `vak` selects it.

| Key | Action |
|---|---|
| `<leader>us` | Toggle spell check for this buffer (any filetype) |
| `]s` / `[s` | Next / previous misspelled word (`;` / `,` repeat) |
| `z=` | Spelling suggestions in an fzf-lua picker (fuzzy filter, `<C-j>`/`<C-k>` to move, `<CR>` to replace). Defined in `lua/keymaps.lua` |
| `1z=` | Take the first suggestion straight away (any count works, as in the built-in) |
| `zg` | Add word to dictionary |
| `zw` | Mark word as wrong |
| `zug` | Undo `zg` |

---

## 5. neotest — run tests in the editor

**File:** `lua/plugins/neotest.lua` (new). Plugins: `neotest`,
`nvim-nio`, `neotest-python`.

Python tests run with pytest. The adapter finds the project's `.venv` / `venv` on
its own, and pytest must be installed there (or in system Python). Pass/fail
marks appear in the sign column; failures show inline on the failing line.

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite (cwd) |
| `<leader>tl` | Rerun last test (works from any file) |
| `<leader>tw` | Toggle watch mode: rerun file's tests on save |
| `<leader>to` | Output of the test under the cursor |
| `<leader>tO` | Toggle output panel |
| `<leader>ts` | Toggle summary tree |
| `<leader>tS` | Stop running tests |
| `]T` / `[T` | Next / previous failed test |

Inside the summary tree: `r` run, `o` output, `i` jump to test,
`m` mark, `R` run marked, `J` / `K` next / previous failure.

To add another language, install its adapter (e.g. `neotest-jest`,
`neotest-vitest`) and add it to `adapters`.

---

## 6. grug-far — project-wide search & replace

**File:** `lua/plugins/grug-far.lua` (new). Needs ripgrep (`rg`).

| Key | Action |
|---|---|
| `<leader>rr` | Replace in project (prefilled with word under cursor) |
| `<leader>rr` (visual) | Replace in project (prefilled with selection) |
| `<leader>rf` | Replace in current file only |

Workflow:

1. Open it. The **Search** field is prefilled.
2. Type in **Replace**. Results and a preview update live.
3. Optional: **Files Filter** (`*.py`, `!tests/**`) and **Flags** (`-i`,
   `--fixed-strings`). Regex groups can be used as `$1` in Replace.
4. `<Space>r` applies the replacement everywhere.

Inside the grug-far buffer (`<Space>` = localleader):

| Key | Action |
|---|---|
| `<Space>r` | Replace all (short pause, because `<leader>r` is also a group) |
| `<CR>` | Go to match |
| `<Space>s` | Sync edits you made to result lines back to the files |
| `<Space>q` | Results → quickfix |
| `<Space>t` | Search history |
| `g?` | Help (all keys) |

---

## 7. System clipboard by default

**File:** `lua/config.lua`

- `clipboard = "unnamedplus"`, set in `vim.schedule` so the clipboard
  provider check stays off the startup path. `y`, `d`, `c`, `x` and `p` all
  use the system clipboard.

**File:** `lua/keymaps.lua`

- Removed `<leader>y` / `<leader>p` (copy and paste to the system
  clipboard). They're redundant now, and `<leader>p` was also the start of
  the scratchpad keys (`<leader>ps` / `pS`), which made it wait 0.3 s.

**Note:** every delete and change now overwrites the clipboard. To delete
without it, use the black-hole register: `"_dd`, `"_x`, `"_ciw`.

---

## 8. yanky — yank history & better paste

**File:** `lua/plugins/yanky.lua` (new)

Settings:

- **Ring:** last 100 copies, saved in shada so the history survives restarts.
- **Black hole register `"_` ignored:** `"_d` deletes stay out of the history.
- **System clipboard sync:** copies made in other apps join the ring.
- **Highlight:** copied and pasted text flashes for 200 ms.
- **Cursor stays put after `y`:** `yip` / `yG` don't move the cursor.
- **Text object:** `iy` = last pasted text.

| Key | Action |
|---|---|
| `y` | Yank (cursor stays put) |
| `p` / `P` | Put after / before |
| `<C-p>` / `<C-n>` | Right after a put: swap it for an older / newer yank |
| `gp` / `gP` | Put, cursor ends after the pasted text |
| `]p` / `[p` | Put line below / above, matching indent |
| `>p` / `<p` | Put below and indent / outdent |
| `=p` / `=P` | Put after / before and re-indent |
| `iy` | Last pasted text (`>iy`, `diy`, `viy`) |
| `<leader>fy` | Search yank history and paste (fzf-lua) |

The history picker goes through fzf-lua's `vim.ui.select`, so its only
action is "put after". Paste before, set register and delete entry exist
only in yanky's Telescope and Snacks pickers.

---

## 9. which-key

**File:** `lua/plugins/which-key.lua`

- New groups: `<leader>t` **Tests**, `<leader>r` **Replace (grug-far)**.
- Icons for neotest, grug-far and yanky keys.

---

## New and changed keys at a glance

| Key | Mode | Action | Status |
|---|---|---|---|
| `<Tab>` / `<S-Tab>` | i | Snippet jump first, then menu | changed |
| `<C-l>` / `<C-h>` | i, s | Snippet choice, else normal key | changed |
| `<leader>cR` | n | Rename file | moved from `<leader>cr` |
| `]s` / `[s` | n, x, o | Next / previous misspelling, repeatable with `;` / `,` | restored (was "Next scope") |
| `]k` / `[k` | n, x, o | Next / previous class start (repeatable) | moved from `]c` / `[c` |
| `]K` / `[K` | n, x, o | Next / previous class end (repeatable) | moved from `]C` / `[C` |
| `]c` / `[c` | n | Next / previous change in diff mode (Vim built-in) | restored |
| `ak` / `ik` | x, o | Around / inside class | renamed from `ac` / `ic` |
| `<leader>t*`, `]T`, `[T` | n | neotest | new |
| `<leader>rr`, `<leader>rf` | n, x | grug-far | new |
| `y p P gp gP` | n, x | yanky versions | changed |
| `<C-p>` / `<C-n>` | n | Cycle yank ring | new |
| `]p [p >p <p =p =P` | n | Indented / filtered put | new |
| `iy` | o, x | Last pasted text | new |
| `<leader>fy` | n | Yank history | new |
| `<leader>y` / `<leader>p` | n, v | Copy / paste to system clipboard | removed |
