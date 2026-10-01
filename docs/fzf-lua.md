# fzf-lua Cheat Sheet

Source of truth: `.config/nvim/lua/plugins/fzf-lua.lua`

Two launch groups, split by **scope** not picker type:

- `<leader>f` — **search the current scope**: cwd, or the directory of the current buffer, plus buffers, grep, LSP, diagnostics, help.
- `<leader>d` — **search somewhere that isn't the current directory**: `~`, OneDrive, iCloud Drive, the Trash, anywhere zoxide remembers.

Every fixed location has a **files** picker and a **directories** picker on the same letter, shifted = directories:

| Location | Files | Directories |
| --- | --- | --- |
| cwd | `<leader>ff` | `<leader>f-` (oil's own "open a dir" key) |
| current buffer's dir | `<leader>f.` | `<leader>f>` |
| `~` | `<leader>dh` | `<leader>dd` (predates the rule; `dH` is unused) |
| OneDrive | `<leader>do` | `<leader>dO` |
| iCloud Drive | `<leader>di` | `<leader>dI` |
| Trash | `<leader>db` (b for bin) | `<leader>dB` |

`<leader>fa` and `<leader>da` search cwd and `~` as one mixed list. `<leader>dw` / `<leader>dt` are plain oil jumps to Downloads / Trash, not pickers.

## 1. Opening pickers

### `<leader>f` — find here

| Key | Picker | Notes |
| --- | --- | --- |
| `<leader>ff` | Files (cwd) | Walks whole cwd. `hidden=true`, `no_ignore=true` by default. |
| `<leader>fa` | Files **and** directories (cwd) | Same scope and unfiltered defaults as `ff`, with `--type d` mixed in. `<CR>` on a dir hands it to oil; the builtin previewer shows `ls -la` for it. |
| `<leader>f-` | Directories (cwd) | Mnemonic: `-` is the key oil opens a dir with. `<CR>` hands it to oil. |
| `<leader>f.` | Files in current file's dir | Sibling-file search. Uses oil's dir in oil buffers; warns if buffer has no dir on disk (scratch, `terminal://`, `fugitive://`). Prompt shows the dir, e.g. `~/proj/src/ > `. |
| `<leader>f>` | Directories in current file's dir | The dirs companion to `f.` (shifted `.`). Same root resolution, same warning on a buffer with no dir. Dir-picker actions + `eza --tree` preview. |
| `<leader>fg` | Live grep (cwd) | `rg_glob=true`, so `term -- *.lua` filters by glob. See §5. |
| `<leader>fb` | Buffers | Normal buffer list. |
| `<leader><space>` | Switch buffer | `sort_lastused=true`, so `<leader><space><CR>` = `:b#` toggle. Preview forced hidden — feels like a switcher. Height 40%, width 60%. |
| `<leader>fo` | Recent files (`oldfiles`) | |
| `<leader>fr` | Resume last picker | Reopens exact state. |
| `<leader>fh` | Help tags | |
| `<leader>fk` | Keymaps | |
| `<leader>fm` | Marks | |
| `<leader>f"` | Registers | `multiline=false`, preview forced `horizontal right:65%`. |
| `<leader>f:` | Commands | Via `vim.ui.select` → also fzf (see §6). |
| `<leader>fc` | Command history | |
| `<leader>fs` | Workspace symbols | `lsp_live_workspace_symbols` |
| `<leader>fd` | Workspace diagnostics | `diagnostics_workspace` |
| `<leader>fD` | Document diagnostics | `diagnostics_document` |
| `go` | Document symbols | `lsp_document_symbols` |

### `<leader>d` — go somewhere else

In the dir pickers (`dd`, `dz`): `<CR>` opens in oil, `alt-f` / `alt-s` / `alt-c` act on the picked dir (see §3). `dw` and `dt` are plain jumps — they open one fixed location in oil.

| Key | Picker | Notes |
| --- | --- | --- |
| `<leader>dd` | Directories under `~` | The default — `ff` is to files what `dd` is to dirs. `fd --type d --hidden` + excludes. |
| `<leader>dz` | Zoxide directories | Fast path for dirs you've visited. Parses `score<TAB>path`. Uses `formatter = path.dirname_first` (required — global `filename_first` would split the path and land you one dir too high). `alt-c` also runs `zoxide add` so the entry stays ranked. |
| `<leader>dh` | Files in `~` | For when the target is a file you can name but it isn't under cwd. Uses filtered `fd` (see §6), not the global unfiltered defaults. |
| `<leader>da` | Files **and** directories in `~` | `dh` plus `--type d` — one list when you don't know whether the thing you want is a file or a folder. Same filtered `fd`. |
| `<leader>do` | Files in OneDrive | `~/Library/CloudStorage/OneDrive-Personal`. Same filtered `fd` as `dh`. macOS-only path — warns instead of opening an empty picker elsewhere. |
| `<leader>di` | Files in iCloud Drive | `~/Library/Mobile Documents/com~apple~CloudDocs`. Same filtered `fd` as `dh`. macOS-only path. |
| `<leader>dO` | Directories in OneDrive | Same root, `fd --type d`, dir-picker actions. |
| `<leader>dI` | Directories in iCloud Drive | Same root, `fd --type d`, dir-picker actions. |
| `<leader>db` | Files in Trash | Searches where oil's `delete_to_trash` writes — `~/.Trash` on macOS, `$XDG_DATA_HOME/Trash/files` under freedesktop (mirrors `oil/adapters/trash/*`). `hidden = true` here: you delete dotfiles too. `<CR>` opens the trashed copy in place; restoring is still oil's job in the `oil-trash://` buffer. |
| `<leader>dB` | Directories in Trash | Same root, `fd --type d`. |
| `<leader>dw` | Downloads | Opens `~/Downloads` in oil (owned by `plugins/oil.lua`, not fzf-lua). |
| `<leader>dt` | Trash | Opens the trash in oil via `oil-trash://` (also `plugins/oil.lua`). macOS has one system-wide trash; on Linux this is the per-directory trash for `$HOME`. |

## 2. Inside a file-ish picker — actions

Applies to **every picker whose entries are files**: `files`, `live_grep`, `buffers`, `oldfiles`, `lsp_*`, `diagnostics`, `quickfix`. Reason: fzf-lua resolves actions to `actions.buffers or actions.files`, and everything except `files`/`buffers` falls through to `files` — so `files = common_actions` covers them all.

The `alt-*` trio resolves the focused entry to a directory first: a dir entry is used as-is, a file entry contributes its **parent dir**. Scratch / `[No Name]` / terminal buffers have no dir → warns `This entry has no directory on disk` and does nothing.

| Key | Action | What happens |
| --- | --- | --- |
| `<CR>` (`default`) | Open | `file_edit` — edit file / jump to grep/LSP location. |
| `ctrl-s` | Open in split | `file_split` |
| `ctrl-v` | Open in vsplit | `file_vsplit` |
| `ctrl-t` | Open in tab | `file_tabedit` |
| `ctrl-q` | Send to quickfix | `file_sel_to_qf` — selected entries (multi-select with `tab`) go to quickfix list. |
| `ctrl-l` | Send to loclist | `file_sel_to_ll` — same but location list. |
| `alt-g` | Toggle ignored | `toggle_ignore` — toggles `no_ignore`, i.e. include/exclude `.gitignore`d files. |
| `alt-b` | Toggle hidden | `toggle_hidden` — toggles dotfiles. |
| `alt-f` | Files in entry's dir | Opens `files({ cwd = dir })` with prompt `~/path/ > `. |
| `alt-s` | Grep in entry's dir | Opens `live_grep({ cwd = dir })` with prompt `~/path/ > `. |
| `alt-c` | cd into entry's dir | `:tcd dir` (tab-local, other tabs untouched) + `:edit dir` (oil, since oil is the default explorer) + `notify: cwd → ~/path`. |

## 3. Inside a directory picker — actions

Pickers: `<leader>f-`, `<leader>dd`, `<leader>dz`. Single-select only (`--no-multi`). Preview = `eza --tree --level=1 --color=always {} || ls -1 {}` (native fzf previewer — the builtin one would try to read a dir as text).

| Key | Action | What happens |
| --- | --- | --- |
| `<CR>` (`default`) | Browse | `:edit dir` — opens dir in oil. cwd unchanged. |
| `alt-f` | Files in it | `files({ cwd = picked })`, prompt `~/picked/ > `. |
| `alt-s` | Grep in it | `live_grep({ cwd = picked })`, prompt `~/picked/ > `. |
| `alt-c` | cd into it | Same `tcd + edit + notify` as §2. On `<leader>dz` additionally runs `zoxide add -- dir` first (replaces the score bump fzf-lua's own `zoxide_cd` would have done). |

So the trio means the same thing everywhere:

- `alt-f` = "find files in it"
- `alt-s` = "live grep in it"
- `alt-c` = "cd into it (`:tcd`) and open it in oil"

## 4. Window / preview keys

| Key | Action | Notes |
| --- | --- | --- |
| `ctrl-/` / `ctrl-_` | Toggle preview | Same action. Terminals send `ctrl-/` as `ctrl-_`, both are bound. Needed because preview starts **hidden** when `columns < 100`. |
| `<F4>` | Toggle preview | fzf-lua default, still works. Awkward reach; `<F2>`/`<F3>` neighbours are swallowed by tmux (copy-mode / pane zoom). |

Layout (recomputed per invocation, so tmux-zoom `F3` applies without restart):

- Float `height 0.90`, `width 0.92` of the whole editor.
- Preview `flex`, flips at 110 cols: `horizontal right:50%` wide, `vertical down:45%` narrow, `scrollbar: float`.
- Under ~100 cols there is no room for list + preview → preview starts hidden.

## 5. fzf / filter keys (while typing)

These are stock fzf, **not** remapped — deliberately preserved by using `alt-*` for actions so `ctrl-*` keeps its line-editing meaning (`ctrl-e` = end-of-line, `ctrl-f`/`ctrl-b` = half-page scroll in preview).

| Key | Action |
| --- | --- |
| `type` | Fuzzy-filter list |
| `up` / `down`, `ctrl-j` / `ctrl-k`, `ctrl-n` / `ctrl-p` | Move selection |
| `enter` | Confirm / run `default` action above |
| `tab` / `shift-tab` | Multi-select + move (disabled in dir pickers) |
| `esc` / `ctrl-c` | Abort, close picker |
| `ctrl-a` / `ctrl-e` | Beginning / end of query line |
| `ctrl-u` | Clear query |
| `ctrl-w` / `alt-b` / `alt-f` | Delete word / back-word / forward-word in query (terminal-level readline) |
| `ctrl-?` (`ctrl-/` conflicts — see §4) | N/A — preview toggle stole this slot |
| `shift-up` / `shift-down` (builtin preview) | Scroll preview |
| `pgup` / `pgdn` | Scroll preview page |

Live-grep extras (`<leader>fg`, `alt-s`):

- Typing re-runs `rg`. Empty query = file list.
- `term -- *.lua` — anything after `--` is parsed as a glob (`rg_glob=true`).
- `rg` flags baked in: `--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git/ --glob !.venv/ --glob !venv/ --max-columns=4000`.
- Results render `filename_first`: `name  path:line:col` with `--no-hscroll` + `--ellipsis …` so long paths truncate the path, never the filename.

## 6. Defaults worth knowing

- `hidden = true` — dotfiles included; `alt-b` toggles off.
- `no_ignore = true` — `.gitignore`d files included; `alt-g` toggles off.
- **Exception:** `<leader>d*` pickers search from `~` and can't use the unfiltered defaults (would walk `~/Library`, every `node_modules`, every `.git/objects`). They opt back into `fd` filtering: `--exclude Library --exclude .git --exclude node_modules --exclude .venv --exclude venv --exclude .cache --exclude .Trash`, plus for dir search `--exclude .npm --exclude .pyenv --exclude .nvm --exclude .cargo --exclude .rustup --exclude .codex`. `alt-g` / `alt-b` still toggle the unfiltered behavior back on from inside.
- Hidden dirs stay **in** for dir search (`--type d --hidden`) — `~/.config` is a top target and dirs-only stays instant.
- **Types:** `--type f --type l` for the file pickers, `--type d` for the dir pickers, and both together for the combined `<leader>fa` / `<leader>da`. Everything else about those two is stock `fzf.files`, so they inherit `common_actions` and the builtin previewer (which runs `ls -la` on a directory entry).
- `formatter = path.filename_first` everywhere except `<leader>dz` (`path.dirname_first` — see table).
- `register_ui_select()` — any `vim.ui.select` (e.g. `<leader>f:` commands, LSP code actions) renders as an fzf picker.
- Prompt convention: scoped pickers show `~/dir/ > ` so you always know the cwd (results themselves strip it).

## 7. Common flows

```text
<leader>ff → alt-s on a result   grep the file's project dir
<leader>fg → alt-f on a hit      browse files next to the hit
<leader>dd → alt-s               grep an arbitrary project under ~
<leader>dz → alt-c               jump tabs to a frequented dir (tcd + oil, keeps zoxide rank)
<leader>f.                       sibling-file search without leaving current file's scope
<leader><space><CR>              toggle to alternate buffer (:b#)
<leader>fr                       reopen whatever you just closed
```

`alt-c` never touches other tabs (`:tcd`). If nothing on screen seems to change, check `:pwd` / the `cwd → …` notification — the cwd moved and oil opened there.
