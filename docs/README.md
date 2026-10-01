# docs

Central home for dotfiles documentation. Structure mirrors `~/` for config; docs live here.

## Index

- [fzf-lua cheat sheet](fzf-lua.md) — all `<leader>f` / `<leader>d` launchers + in-picker actions (`enter`, `ctrl-s/v/t/q/l`, `alt-g/b/f/s/c`), preview toggles, fzf filter keys, defaults. Source: `.config/nvim/lua/plugins/fzf-lua.lua`.
- [zsh keymaps](zsh-keymaps.md) — `bindkey` widgets + inherited `fzf` / `fzf-marks` keys.
- [zsh hooks](zsh-hooks.md) — `add-zsh-hook`, `autoload`, standard + ZLE hook events.
- [macOS default text keys](default-keys.md) — Cocoa `NSTextView` Emacs bindings.
- [neovim recent changes](neovim_recent_changes.md) — what commit `62ff535` added over `44a8788`.
- [uncommitted changes post-62ff535](uncommitted_changes_post_62ff535.md) — WIP snapshot on top of `62ff535`.

## Adding a new doc

Put it in `docs/` and link it here. Keep the filename scoped to the tool (`<tool>.md`) and state the source file(s) at the top so the doc stays traceable to config.
