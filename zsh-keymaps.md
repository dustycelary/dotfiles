# Zsh Keymaps (fuzzy finding)

Scope: explicit `bindkey` in `.zshrc` + stock `fzf` / `fzf-marks` keys inherited via `plugins=(... fzf ... fzf-marks ...)`.

## 1. Custom widgets (explicit in `.zshrc`)

| Key | Widget / action | Source |
| --- | --- | --- |
| `Ctrl+R` | `fzf-history-widget-sync` — `fc -R` reload from disk, then `fzf-history-widget` | `.zshrc:111-116` |
| `Alt+V` (`Esc` `v`) | `edit-command-line` — edit current line in `$EDITOR` (`nvim`) | `.zshrc:118-120` |
| `Alt+Z` (`Esc` `z`) | `recent-directory-widget` — `zoxide query --interactive`, inserts shell-escaped dir | `.zshrc:150-166` |
| `Ctrl+G` | `content-search-widget` — `rga` content search, inserts shell-escaped file path | `.zshrc:254-269` |
| Paste seq `^[[200~` | `bracketed-paste` — re-bound last so pastes stay one block, fixes stray `~` | `.zshrc:392-396` |

Related OMZ default, still active: `Ctrl+X` `Ctrl+E` → `edit-command-line` (`~/.oh-my-zsh/lib/key-bindings.zsh:121-123`). `Alt+V` is an extra single-tap alias for it.

## 2. Stock `fzf` keys (inherited)

Loaded via `plugins+=(fzf)` (`.zshrc:64-71`) → `~/.oh-my-zsh/plugins/fzf/fzf.plugin.zsh` → `eval "$(fzf --zsh)"` (fzf 0.74.3).

| Key | Widget / action | Status |
| --- | --- | --- |
| `Ctrl+T` | `fzf-file-widget` — fuzzy file finder, inserts selected path | Active |
| `Alt+C` (`Esc` `c`) | `fzf-cd-widget` — fuzzy directory finder, `cd`s into selection | Active |
| `Ctrl+R` | `fzf-history-widget` — fuzzy history | Overridden by `fzf-history-widget-sync` above |
| `Tab` (`^I`) | `fzf-completion` — fuzzy completion wrapper around stock completion | Active |

File source respects `FZF_DEFAULT_COMMAND` (`.zshrc:53`): `fd --type f --hidden $FD_EXCLUDES`.

## 3. `fzf-marks` (inherited, modified)

Default jump key is `Ctrl+G` (`bindkey ${FZF_MARKS_JUMP:-'^g'} fzm` in `fzf-marks.plugin.zsh:199`), but `.zshrc:63,269` rebinds `Ctrl+G` to `content-search-widget`. Call `fzm` explicitly.

Bookmark file: `~/.fzf-marks` (`$FZF_MARKS_FILE`).

| Context | Key | Action |
| --- | --- | --- |
| Shell | `fzm [query]` | Open bookmark picker |
| Picker | `Enter` | Jump (`cd`) to selection |
| Picker | `Ctrl+Y` | Accept / jump (`--bind=ctrl-y:accept`) |
| Picker | `Ctrl+T` | Toggle multi-select + move down |
| Picker | `Ctrl+D` | Delete bookmark (`dmark`) |
| Picker | `Ctrl+V` | Paste path without jumping (`pmark`) |

Helpers: `mark [<name>]` save cwd, `jump <name>` cd, `dmark` delete, `pmark` print/paste path (`.zshrc:59-62`).

## 4. Content-search widget details

Defined in `.zshrc:244-269`:

* Prompt: `Content>`, header: `Type to search contents; Enter inserts the selected path`.
* Typing reloads: `rga --files-with-matches --hidden --smart-case --glob "!.git/**" --glob "!venv/**" --glob "!.venv/**" --glob "!node_modules/**" --glob "!__pycache__/**" -- {q} .`
* Preview: `rga --pretty --context 4 --colors "match:fg:black" --colors "match:bg:yellow" -- {q} {}`.
* `Enter` inserts the file shell-escaped at the cursor; `Esc`/`Ctrl+C` cancels.

## 5. Fuzzy functions (no keybind)

| Command | Action | Source |
| --- | --- | --- |
| `f` | `fzf` file picker, copies containing dir to clipboard (`pbcopy`) | `.zshrc:202-206` |
| `fa` | Fuzzy alias picker, `Enter` puts choice on line via `print -z` | `.zshrc:273-280` |
| `fsearch` | External Alfred content-search script alias | `.zshrc:367` |

## 6. Defaults affecting all of the above

* `FD_EXCLUDES` (`.zshrc:50`): skips `.git Library node_modules .venv venv __pycache__ .cache .Trash .DS_Store`.
* `FZF_DEFAULT_COMMAND` (`.zshrc:53`): `fd --type f --hidden $FD_EXCLUDES`.
* `FZF_DEFAULT_OPTS` (`.zshrc:56`): `--height=60% --layout=reverse --border`.
* `KEYTIMEOUT=1` (`.zshrc:19`): 10ms `Esc` delay so `Alt+` (`^[`) bindings feel instant.
