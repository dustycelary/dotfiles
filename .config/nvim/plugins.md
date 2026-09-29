# Neovim Plugins

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
| `<M-Space>` / `<C-e>` | Force open completion / toggle docs |

Sort order: exact match → score → recently used → locality → kind → length. Formatting shows a kind icon with the kind name (e.g. Function, Variable) rather than the source name.

## colorscheme (catppuccin)
Default colorscheme is Catppuccin Mocha via `catppuccin/nvim`,
with terminal colors and automatic plugin integrations enabled
(cmp, gitsigns, treesitter, which-key, etc.). To switch flavour,
change `flavour` in `lua/plugins/colorscheme.lua` to `latte`,
`frappe`, `macchiato`, or `mocha`.

---

## conform.nvim
Format on save with a 500ms timeout.
- Manual format: `<leader>cf`
- Toggle format-on-save for active buffer: `<leader>tf`
- Commands: `:FormatDisable[!]`, `:FormatEnable[!]`, `:FormatToggle[!]` (use `!` for global toggle)

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

Two keymap groups, split by **scope**: `<leader>f` searches *inside* the current scope (cwd, buffer list, project), `<leader>d` picks a *directory* — i.e. changes the scope itself, and is the group that can leave the current project.

Files use `fd` and grep uses `ripgrep`, both including hidden and gitignored files by default (`alt-b` / `alt-g` toggle that inside the picker). The `<leader>d` pickers are the exception: pointed at `$HOME` an unfiltered walk drags in `~/Library` and every `node_modules`, so they apply fd's normal filtering plus an exclude list.

### Inside any picker
These act on the **focused entry's directory** — the entry itself when it's a directory, its parent when it's a file — and work in every picker: files, grep, LSP, buffers, oldfiles, quickfix, the `<leader>d` directory pickers and the bookmarks picker.

| Key | Action |
|-----|--------|
| `<M-f>` | Find files in that directory |
| `<M-s>` | Live grep in that directory |
| `<M-c>` | `:tcd` into it **and open it in Oil** |
| `<M-g>` / `<M-b>` | Toggle gitignore / hidden files |
| `<CR>` `<C-s>` `<C-v>` `<C-t>` | Open · split · vsplit · tab (directories open in Oil) |
| `<C-q>` / `<C-l>` | Send selection to quickfix / location list |
| `<C-/>` | Toggle preview (starts hidden below 100 columns) |

### `<leader>f` — find in the current scope

| Key | Action |
|-----|--------|
| `<leader>ff` | Files (cwd) |
| `<leader>f.` | Files in the current file's directory |
| `<leader>f-` | Directories under cwd (`-` is Oil's key; `<CR>` opens the directory in Oil) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader><space>` | Quick buffer switcher (alternate buffer first) |
| `<leader>fo` | Recent files |
| `<leader>fr` | Resume last picker |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>fm` | Marks |
| `<leader>f"` | Registers |
| `<leader>f:` | Commands |
| `<leader>fc` | Command history |
| `<leader>fs` | Workspace symbols (live LSP query) |
| `<leader>fd` / `<leader>fD` | Workspace / document diagnostics |
| `<leader>fq` / `<leader>fl` | Quickfix / location list |
| `go` | Document symbols |

### `<leader>d` — pick a directory

| Key | Action |
|-----|--------|
| `<leader>dd` | Search directories under `~` (what `<leader>ff` is for files) |
| `<leader>dz` | Zoxide directories (ranked by where you actually work) |
| `<leader>dh` | Files under `~` |

`<leader>fs` performs a live LSP workspace-symbol search, which is compatible with language servers such as BasedPyright that require a non-empty symbol query. In a grep picker, `<C-g>` switches between live ripgrep/regex and fuzzy filtering; `rg_glob` is on, so `search_term -- *.lua` restricts the glob. In the document-symbol picker, use `<M-a>` to select every symbol, then `<C-q>` / `<C-l>` for quickfix / location list.

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

## marks.nvim
Shows vim marks (`a-z`, `A-Z`) as indicators in the sign column. Provides keymaps for toggling marks (`mx`), deleting marks (`dmx`), and populating Quickfix/Loclist with marks.

| Key | Action |
|-----|--------|
| `mx` | Toggle mark `x` |
| `dmx` | Delete mark `x` |
| `dm-` | Delete all marks in buffer |
| `]m` / `[m` | Jump to next / previous mark |
| `<leader>mq` | Send active file marks → Quickfix |
| `<leader>ml` | Send active file marks → Location list |
| `<leader>mQ` | Send workspace global marks → Quickfix |
| `<leader>fm` | Fuzzy search marks (fzf-lua) |

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
Quick-access bookmarks for up to 4 files per project, scoped to the current directory — each project gets its own file list. List is saved automatically on toggle (`save_on_toggle = true`).

Also includes a custom Terminal Command Runner. Unlike files, commands are shared **globally** across every project (same 4 slots everywhere) rather than scoped per directory. If inside Tmux, commands are automatically sent to the other pane (splitting the window if only Neovim is open) without changing editor focus. If run outside Tmux, it falls back to a Neovim split terminal.

| Key | Action |
|-----|--------|
| `<leader>ha` | Add current file to Harpoon |
| `<leader>hh` | Open file quick menu |
| `<leader>1` – `<leader>4` | Jump to file slot 1–4 |
| `<leader>hn` | Next file in list |
| `<leader>hp` | Previous file in list |
| `<leader>hc` | Prompt to add a new command |
| `<leader>hm` | Open command quick menu |
| `<leader>9` / `<leader>8` / `<leader>7` / `<leader>6` | Run command slot 1 / 2 / 3 / 4 |

---

## indent-blankline.nvim
Vertical indent guides using `│`. The current scope (the function or block your cursor is inside) is highlighted in a distinct color (`IblScope`) so you can see your current nesting level at a glance.

---

## lazydev.nvim
Neovim Lua API type stubs for `lua_ls` and `nvim-cmp`. Only active in lua filetype. Provides completions and type info for `vim.*`, `vim.api.*`, `vim.fn.*`, etc. Its cmp source is registered at `group_index = 0`, so it takes priority over the LSP source in neovim lua files.

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
| taplo | TOML |

| Key | Action |
|-----|--------|
| `grd` | Go to definition (fzf) |
| `grD` | Go to declaration |
| `grr` | References (fzf) |
| `gri` | Implementations (fzf) |
| `go` | Document symbols (Markdown shows searchable H1-H6 heading paths) |
| `<leader>cn` | Rename symbol |
| `<leader>ca` | Code actions (normal + visual) |
| `<leader>cs` | Signature help |
| `<leader>ci` | Show attached LSP clients |
| `]d` / `[d` | Next/prev diagnostic (repeatable) |
| `]e` / `[e` | Next/prev error (repeatable) |
| `<leader>ce` | Open diagnostic float |
| `<leader>cq` | Diagnostics → quickfix |
| `<leader>cl` | Diagnostics → loclist |

Diagnostic virtual text and virtual lines are disabled globally in `init.lua` — `tiny-inline-diagnostic` handles all display.

---

## neoscroll.nvim
Smooth animated scrolling for `<C-u>`, `<C-d>`, `<C-b>`, `<C-f>`, `<C-y>`, `<C-e>`, `zt`, `zz`, `zb`. Cursor is hidden during scroll. Does not respect `scrolloff`. Stops at EOF.

## oil.nvim
File explorer that lets you edit the filesystem like a normal Vim buffer. Replaces netrw. You can create, rename, delete, move, and copy files and directories using standard Vim commands (`dd`, `cw`, `o`, `:%s`, `:w`).

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Oil file explorer sidebar (left split, 30 columns) |
| `q` | Close Oil file explorer sidebar |
| `-` | Open parent directory in Oil (full window) |
| `<CR>` | Open file in main window & keep Oil sidebar open |
| `o` / `<S-CR>` / `l` | Open file in main window & close Oil sidebar |
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

## flash.nvim
Jump anywhere on screen fast: type a search prefix and flash labels every match with a highlighted character to jump straight to it. Also supports jumping to Treesitter nodes.

| Key | Mode | Action |
|-----|------|--------|
| `s` | Normal/Visual/Op-pending | Flash jump (label-based search jump) |
| `S` | Normal/Visual/Op-pending | Flash Treesitter jump |
| `r` | Op-pending | Remote Flash (operate on a remote match) |
| `R` | Op-pending/Visual | Treesitter search |
| `<c-s>` | Command-line | Toggle Flash during `/` or `?` search |

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
| `ax` / `ix` (`ae` / `ie`) | Try/Except | around try-except block vs inside try/except block body |
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
| `]x` / `[x` | Try/Except Start | Jump to next / previous try-except block start |
| `]X` / `[X` | Try/Except End | Jump to next / previous try-except block end |
| `]o` / `[o` | Loop Start | Jump to next / previous loop start |
| `]O` / `[O` | Loop End | Jump to next / previous loop end |
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
| `<leader>l/` | Loclist | Replace it with matches from the last `/` search and open it |

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
| `<leader>x` | Diagnostics |
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
