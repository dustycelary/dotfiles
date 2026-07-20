# Neovim Plugins

## aerial.nvim
Symbol sidebar and breadcrumb winbar. Shows a tree of functions, classes, headings and other symbols in a right-hand split. Also drives the breadcrumb path shown in the winbar at the top of each buffer.

| Key | Action |
|-----|--------|
| `<leader>ua` | Toggle sidebar |
| `<leader>sa` | Search symbols (fzf) |
| `<leader>sn` | Toggle floating nav (with preview) |

The winbar is suppressed automatically on nofile, terminal, aerial, fzf, lazy, and mason buffers. The sidebar width is preserved when you equalize windows with `<C-w>=`.

---

## nvim-autopairs
Auto-closes brackets, quotes, and parens on insert. Treesitter-aware — won't close pairs inside Lua strings or JS template literals. Integrated with nvim-cmp: automatically appends `()` when confirming a function or method completion.

---

## bufferline.nvim
Tab bar across the top showing all open buffers with LSP diagnostic counts per buffer. Close icons hidden to reduce noise.

| Key | Action |
|-----|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<leader>bd` | Close buffer |
| `<leader>ba` | Close all other buffers |

---

## nvim-cmp
Completion engine. Sources in priority order: lazydev (lua files only) → LSP → LuaSnip snippets → path → buffer words (min 3 chars).

Ghost text shows the top suggestion inline as you type.

| Key | Action |
|-----|--------|
| `<C-n>` / `<Down>` | Next item |
| `<C-p>` / `<Up>` | Previous item |
| `<C-y>` | Confirm (accept top recommendation) |
| `<CR>` | Confirm selection (only if an item is explicitly selected) |
| `<C-e>` | Abort |
| `<Tab>` | Next item or jump snippet stop |
| `<S-Tab>` | Previous item or jump snippet stop back |
| `<C-b>` / `<C-f>` | Scroll docs |
| `<C-Space>` | Force open completion |

Sort order: exact match → score → recently used → locality → kind → length. Formatting shows a kind icon with the kind name (e.g. Function, Variable) rather than the source name.

## nightfox.nvim (terafox)
Colorscheme using the Terafox variant from `EdenEast/nightfox.nvim`. Other available palettes include `nightfox`, `dayfox`, `dawnfox`, `duskfox`, `nordfox`, and `carbonfox`.

---

## conform.nvim
Format on save with a 2 second timeout. Manual format with `<leader>cf`.

| Filetype | Formatter |
|----------|-----------|
| python | ruff_fix → ruff_format → ruff_organize_imports |
| lua | stylua |
| c, json | clang-format |
| yaml | prettier |
| htmldjango | djlint |
| markdown | markdownlint |
| jsonl | jq -c (custom — compacts each line) |

---

## csvview.nvim
Renders CSV and TSV files as an aligned table with cell borders. Auto-enables on `*.csv` and `*.tsv`. Sticky header stays visible while scrolling. Delimiter auto-detected in order: `;`, `,`, `\t`, `|`.

| Command | Action |
|---------|--------|
| `:CsvViewToggle` | Toggle table view |
| `:CsvViewEnable` | Enable |
| `:CsvViewDisable` | Disable |
| `:CsvViewInfo` | Show detected delimiter info |

---

## fzf-lua
Fuzzy finder for files, grep, buffers, LSP symbols, diagnostics, and more.

Files use `fd` (includes gitignored files by default, includes hidden files, excludes `.git`, `.venv`, `node_modules`, `__pycache__`, etc.). Grep uses `ripgrep` with hidden files included. The `<leader>sF` keymap respects `.gitignore`, and the `<leader>sG` variant bypasses `.gitignore`.

| Key | Action |
|-----|--------|
| `<leader>sf` | Files (including gitignored) |
| `<leader>sF` | Files (respecting gitignore) |
| `<leader>sg` | Live grep |
| `<leader>sG` | Live grep (including gitignored) |
| `<leader>sb` | Buffers |
| `<leader>sh` | Help tags |
| `<leader>sr` | Resume last picker |
| `<leader>s:` | Command history |
| `<leader>sk` | Keymaps |
| `<leader>so` | Old files (recently opened) |
| `<leader>sm` | Marks |
| `<C-x>` | Delete selected file(s) in `files` |
| `<leader>sw` | Search word under cursor |
| `<leader>ss` | Workspace LSP symbols |
| `<leader>sd` | Document diagnostics |
| `<leader>sD` | Workspace diagnostics |
| `<leader>sc` | Commands |
| `<leader>sa` | Aerial symbols |
| `<leader>st` | Markdown and .env TODO search |
| `grd` | Go to definition |
| `grr` | References |
| `gri` | Implementations |
| `go` | Document symbols |

Project-wide rename: `<leader>cR` prompts for search and replacement strings, opens fzf grep, and on confirm sends matches to quickfix then runs `cfdo %s/.../.../ | update` across all matched files.

---

## gitsigns.nvim
Git change indicators in the sign column. Staged and unstaged hunks shown with separate signs.

| Sign | Meaning |
|------|---------|
| `▎` | Added / changed / changedeleted |
| `` | Deleted / topdeleted |
| `╎` | Untracked |

| Key | Action |
|-----|--------|
| `<leader>ub` | Toggle inline git blame |

Blame shows author, date, and commit summary at end of line with a 400ms delay.

---

## guttermarks.nvim
Shows vim marks (`a-z`, `A-Z`) as indicators in the sign column. No configuration needed — marks appear automatically as you set them with `m{letter}`.

---

## hardtime.nvim
Prevents bad habits by blocking the spamming of movement keys (like `h`, `j`, `k`, `l`), mouse wheel, etc.

| Key | Action |
|-----|--------|
| `<leader>uh` | Toggle hardtime |

| Command | Action |
|---------|--------|
| `:Hardtime toggle` | Toggle hardtime |
| `:Hardtime enable` | Enable |
| `:Hardtime disable` | Disable |
| `:Hardtime report` | View habit warnings report |

---

## harpoon2
Quick-access bookmarks for up to 4 files per project. List is saved automatically on toggle (`save_on_toggle = true`).

Also includes a custom Terminal Command Runner. If inside Tmux, commands are automatically sent to the other pane (splitting the window if only Neovim is open) without changing editor focus. If run outside Tmux, it falls back to a Neovim split terminal.

| Key | Action |
|-----|--------|
| `<leader>ha` | Add current file to list |
| `<leader>hh` | Open file menu |
| `<leader>1` – `<leader>4` | Jump to file slot 1–4 |
| `<leader>hn` | Next file in list |
| `<leader>hp` | Previous file in list |
| `<leader>hc` | Open command menu |
| `<leader>hC` | Prompt to add a new command |
| `<leader>x1` – `<leader>x4` | Run command slot 1–4 (Tmux or Vim terminal) |

---

## indent-blankline.nvim
Vertical indent guides using `│`. The current scope (the function or block your cursor is inside) is highlighted in a distinct color (`IblScope`) so you can see your current nesting level at a glance.

---

## lazydev.nvim
Neovim Lua API type stubs for `lua_ls` and `nvim-cmp`. Only active in lua filetype. Provides completions and type info for `vim.*`, `vim.api.*`, `vim.fn.*`, etc. Its cmp source is registered at `group_index = 0`, so it takes priority over the LSP source in neovim lua files.

---

## lsp_signature.nvim
Floating signature help while typing function arguments. Appears automatically on `InsertEnter` when the cursor is inside a function call.

| Key | Action |
|-----|--------|
| `<C-s>` | Toggle floating window |

Virtual text hints are disabled (too noisy). The window closes automatically after 4 seconds of inactivity.

---

## LSP (mason + mason-lspconfig + nvim-lspconfig)
LSP client setup. Mason installs and manages language server binaries.

| Server | Languages |
|--------|-----------|
| basedpyright | Python (type checking off, open files only) |
| lua_ls | Lua (neovim API stubs via lazydev) |
| clangd | C/C++ |
| html | HTML, HTMLDjango |
| bashls | sh, bash, zsh |
| marksman | Markdown |
| dockerls | Dockerfile |
| yamlls | YAML (schemastore schemas, formatter disabled) |

| Key | Action |
|-----|--------|
| `grd` | Go to definition (fzf) |
| `grD` | Go to declaration |
| `grr` | References (fzf) |
| `gri` | Implementations (fzf) |
| `go` | Document symbols (fzf) |
| `<leader>cn` | Rename symbol |
| `<leader>ca` | Code actions (normal + visual) |
| `<leader>cs` | Signature help |
| `<leader>ci` | Show attached LSP clients |
| `]d` / `[d` | Next/prev diagnostic (repeatable) |
| `]e` / `[e` | Next/prev error (repeatable) |
| `<leader>de` | Open diagnostic float |
| `<leader>dq` | Diagnostics → quickfix |
| `<leader>dl` | Diagnostics → loclist |

Diagnostic virtual text and virtual lines are disabled globally in `init.lua` — `tiny-inline-diagnostic` handles all display.

---

## neoscroll.nvim
Smooth animated scrolling for `<C-u>`, `<C-d>`, `<C-b>`, `<C-f>`, `<C-y>`, `<C-e>`, `zt`, `zz`, `zb`. Cursor is hidden during scroll. Does not respect `scrolloff`. Stops at EOF.

## mini.files
Miller columns (cascading floating window panels) file explorer. Allows navigating directories like macOS Finder column view using `h`/`j`/`k`/`l`, creating/moving files, and live file preview.

| Key | Action |
|-----|--------|
| `<leader>ef` | Toggle mini.files (Column Explorer) |
| `l` / `<CR>` | Enter directory / open file |
| `h` | Go up to parent directory column |
| `=` | Synchronize/save changes to disk |
| `q` | Close mini.files |
| `g?` | Show help |

---

## oil.nvim
File explorer that lets you edit the filesystem like a normal Vim buffer. Replaces netrw. You can create, rename, delete, move, and copy files and directories using standard Vim commands (`dd`, `cw`, `o`, `:%s`, `:w`).

| Key | Action |
|-----|--------|
| `-` / `<leader>e` | Open parent/directory in Oil |
| `<CR>` | Open file or enter directory |
| `-` | Go up to parent directory |
| `<C-p>` | Toggle live floating preview |
| `<C-v>` | Open file in vertical split |
| `<C-t>` | Open file in new tab |
| `g.` | Toggle hidden files (dotfiles) |
| `_` | Open Neovim's working directory (`cwd`) |
| `` ` `` | `:cd` Neovim working directory to current Oil directory |
| `g\` | Toggle trash mode |
| `gx` | Open file/folder in system app (Finder) |
| `g?` | Show help overlay |

### Workflows & Features
- **Rename**: Edit filename text on line (`cw`) and save (`:w`).
- **Move**: Change path text on line (e.g. `subfolder/file.txt` or `../file.txt`) and save (`:w`). Or cut lines (`dd`), navigate to target folder in Oil, paste (`p`), and save (`:w`).
- **Create**: Insert new line (`o`), type filename or `nested/dir/file.txt`, and save (`:w`).
- **Batch Operations**: Use Vim commands like `:%s/old/new/g`, Visual Block (`<C-v>`), or macros (`q`), then save (`:w`).
- **Delete**: Delete lines (`dd`) and save (`:w`).

---

## precognition.nvim
Guides Neovim motions by showing inline hints for available movement options (like `w`, `b`, `e`, `$`, `0`, etc.).

| Key | Action |
|-----|--------|
| `<leader>up` | Toggle precognition |

---

## quick-scope
Highlights the best `f`/`F`/`t`/`T` jump target on each line when you press those keys — underlines the first unique character per word so you can pick your target immediately. No configuration needed.

---

## render-markdown.nvim
Renders markdown in-buffer: styled headings, concealed syntax markers, code block backgrounds, list bullets, and checkboxes. Only active in markdown buffers.

| Key | Action |
|-----|--------|
| `<leader>um` | Toggle render markdown |

---

## nvim-scrollview
Scrollbar on the right edge of windows. Semi-transparent (`winblend 50`). Hides automatically when it would overlap text content. Shown on all windows simultaneously, not just the focused one.

---

## tiny-inline-diagnostic.nvim
Inline diagnostic display using the powerline preset. Replaces nvim's built-in virtual text (which is disabled in `init.lua`).

All diagnostics under the cursor are shown simultaneously. Long messages wrap at 40 characters and break onto continuation lines at 70. Multiple diagnostics on the same line are separated by a blank line.

| Key | Action |
|-----|--------|
| `<leader>ut` | Toggle inline diagnostics |

---

## todo-comments.nvim
Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `WARN`, `PERF`, `TEST` comments with colored icons. The jump motions are repeatable (using treesitter-textobjects repeat system).

| Key | Action |
|-----|--------|
| `]t` | Next TODO comment (repeatable) |
| `[t` | Previous TODO comment (repeatable) |
| `<leader>st` | Search Markdown and .env TODOs (fzf) |

---

## trouble.nvim
Pretty split panel list for showing diagnostics, LSP references, definitions, quickfix, and location lists.

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle workspace diagnostics panel |
| `<leader>xX` | Toggle buffer diagnostics panel |
| `<leader>xs` | Toggle symbols outline panel |
| `<leader>xl` | Toggle LSP definitions/references split |
| `<leader>xq` | Toggle quickfix panel |
| `<leader>xL` | Toggle location list panel |

---

## treesitter
Three plugins bundled together.

**nvim-treesitter-context** — shows the current function/class signature pinned to the top of the window (max 3 lines) so you always know where you are in deep code.

**nvim-treesitter** — syntax parsing for lua, python, js/ts, html, css, json, yaml, toml, bash, markdown and more. HTMLDjango is aliased to the HTML parser.

**nvim-treesitter-textobjects** — text objects and motions based on the syntax tree and document structure.

Text objects (use with operators like `v`, `d`, `c`, `y`):

| Key | Object | Meaning / Selection |
|-----|--------|---------------------|
| `af` / `if` | Function | around function (def & body) vs inside function body |
| `ac` / `ic` | Class | around class (def & body) vs inside class body |
| `aa` / `ia` | Argument / Parameter | around parameter (incl. comma) vs inside parameter |
| `ab` / `ib` | Block | around block / curly braces `{}` vs inside block contents |
| `aI` / `iI` | Conditional | around `if`/`else` statement vs inside conditional body |
| `al` / `il` | Loop | around `for`/`while` statement vs inside loop body |
| `am` / `im` | Function Call | around function call (`func(a, b)`) vs inside call args (`a, b`) |
| `aK` / `iK` | Comment | around comment block vs inside comment text |
| `a=` / `i=` | Assignment | around full assignment (`var = val`) vs inside RHS value (`val`) |
| `aR` / `iR` | Return | around return statement (`return val`) vs inside return expression (`val`) |
| `aA` / `iA` | Attribute | around decorator/attribute (`@decorator`) vs inside attribute name |
| `ai` / `ii` | Indent Block | around indent block (+ line above) vs inside same-indent block |
| `ak` / `ik` | Dict / JSON Key | around key (`"key":`) vs inside key name (`"key"`) |
| `av` / `iv` | Dict / JSON Value | around value (`: "val"`) vs inside value text (`"val"`) |
| `ao` / `io` | Dict / JSON Object | around object/pair (`{...}` / `"k": "v"`) vs inside pair content |
| `aq` / `iq` | Any Quote | around any quote (`"`, `'`, `` ` ``) vs inside quote contents |
| `ag` / `ig` | Buffer / File | around entire file vs inside buffer (excl. blank margins) |
| `au` / `iu` | URL | around URL/link vs inside URL |
| `iN` | Number | inside number literal |

Motions:

| Key | Motion | Explanation |
|-----|--------|-------------|
| `]i` / `[i` | Same-Indent Block | Jump to next / previous block at the same indent level (e.g. between `{}` blocks in JSON or code) |
| `]s` / `[s` | AST Sibling | Jump to next / previous AST sibling node in treesitter |
| `]f` / `[f` | Function Start | Jump to next / previous function definition start |
| `]F` / `[F` | Function End | Jump to next / previous function definition end |
| `]c` / `[c` | Class Start | Jump to next / previous class definition start |
| `]b` / `[b` | Block Start | Jump to next / previous block start |
| `]}` / `[{` | Brace End/Start | Jump to next closing brace `}` / previous unclosed opening brace `{` |
| `]]` / `[[` | Section Start | Jump to next / previous section start |
| `][` / `[]` | Section End | Jump to next / previous section end |
| `]d` / `[d` | Diagnostic | Jump to next / previous diagnostic / error |
| `]e` / `[e` | Error | Jump to next / previous error diagnostic |
| `]t` / `[t` | TODO Comment | Jump to next / previous TODO comment |
| `]q` / `[q` | Quickfix | Jump to next / previous quickfix item |
| `]l` / `[l` | Loclist | Jump to next / previous loclist item |

---

## vim-sandwich
Add, delete, and replace surrounding pairs (brackets, quotes, tags, custom strings).

| Key | Action |
|-----|--------|
| `<leader>wa` | Add surrounding |
| `<leader>wd` | Delete surrounding (prompted) |
| `<leader>wD` | Delete surrounding (auto-detect) |
| `<leader>wr` | Replace surrounding (prompted) |
| `<leader>wR` | Replace surrounding (auto-detect) |

The `i` recipe lets you type arbitrary open/close strings when adding or replacing, e.g. `<leader>wa` then `i` then type `<!--` / `-->` to wrap in an HTML comment.

---

## which-key.nvim
Popup showing available keymaps, text objects, and motions after a short pause (300ms). Helix preset, displayed in a rounded floating panel.

When pressing an operator like `d`, `c`, `y`, or entering visual mode `v`, typing `a` or `i` opens WhichKey showing a complete, categorized breakdown of all available **Around** and **Inside** text objects with detailed explanations of what will be selected.

Key group prefixes:

| Prefix | Group |
|--------|-------|
| `<leader>b` | Buffers / Tabs |
| `<leader>c` | Code / LSP |
| `<leader>h` | Harpoon |
| `<leader>s` | Search / Find |
| `<leader>u` | UI Toggles |
| `<leader>w` | Surrounds (sandwich) |
| `<leader>x` | Trouble / Diagnostics |
| `gr` | LSP / References |
| `]` / `[` | Next / Prev Motions |
| `a` / `i` (in `o`/`x` mode) | Around / Inside Text Objects |

---

## yanky.nvim
Enhanced yank and paste experience. Maintains a history of yanks, highlights put/yank actions, preserves cursor position on yank, and allows cycling through history after pasting. Integrates with fzf-lua for a searchable yank history.

| Key | Action |
|-----|--------|
| `<leader>sy` | Open yank history (fzf) |
| `y` | Yank text (preserves cursor position) |
| `p` / `P` | Put text after/before cursor |
| `gp` / `gP` | Put text after/before selection |
| `[y` / `]y` | Cycle backward/forward through yank history |
| `<C-p>` / `<C-n>` | Cycle backward/forward through history (only after put) |
| `[p` / `]p` | Put and indent left/right |
| `[P` / `]P` | Put before and indent left/right |
| `>p` / `<p` | Put and indent right/left |
| `>P` / `<P` | Put before and indent right/left |
| `=p` / `=P` | Put after/before applying filter |
