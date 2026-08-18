# Uncommitted Neovim Changes (Work-in-Progress on top of `62ff535`)

This document records the exact set of uncommitted working tree changes that were present on top of commit `62ff535` (`feat(nvim): enhance edgy resizing, buffer switching, and diagnostics hub`) before the configuration was reset.

---

## 1. Plugins Removed / Deleted

The following 6 plugin configuration files were deleted from `.config/nvim/lua/plugins/`:

1. **`bufferline.lua`** (`.config/nvim/lua/plugins/bufferline.lua`)
   * Removed the top tab bar displaying open buffers (`bufferline.nvim`).
2. **`lsp-signature.lua`** (`.config/nvim/lua/plugins/lsp-signature.lua`)
   * Removed floating parameter signature help popups (`lsp_signature.nvim`).
3. **`neoscroll.lua`** (`.config/nvim/lua/plugins/neoscroll.lua`)
   * Removed smooth animated scrolling (`neoscroll.nvim`).
4. **`scrollview.lua`** (`.config/nvim/lua/plugins/scrollview.lua`)
   * Removed scrollbar on the right window edge (`nvim-scrollview`).
5. **`tiny-inline-diagnostics.lua`** (`.config/nvim/lua/plugins/tiny-inline-diagnostics.lua`)
   * Removed powerline-style inline diagnostic error callouts (`tiny-inline-diagnostic.nvim`).
6. **`trouble.lua`** (`.config/nvim/lua/plugins/trouble.lua`)
   * Removed the diagnostics and symbol list split panel (`trouble.nvim`).

---

## 2. Configuration Files & Plugins Modified

### `keymaps.lua` (`.config/nvim/lua/keymaps.lua`)
* **Cleaned up legacy mappings**:
  * Removed `S` (re-indent line matching previous row and enter insert mode).
  * Removed `zF` (close outermost enclosing fold).
  * Removed `<leader>cd` (cd to current buffer file directory).
  * Cleaned out old `bnext`/`bprevious` and `tab` keymap blocks.
* **Added new mappings**:
  * Added `<C-Left>`, `<C-Right>`, `<C-Up>`, `<C-Down>` for window split resizing.
  * Added `<leader><space>` (`<cmd>b#<cr>`) to toggle the last active buffer.
  * Added window split shortcuts: `<leader>w-`, `<leader>wh` (horizontal split), `<leader>w|`, `<leader>wv` (vertical split), `<leader>wd`, `<C-q>` (close window).
  * Added tab page shortcuts: `<leader>tn` (new tab), `<leader>tc` (close tab).
  * Added UI toggles: `<leader>ua` (toggle Aerial symbol sidebar), `<leader>uz` (toggle window zoom / maximize tab split).

### `lsp.lua` (`.config/nvim/lua/plugins/lsp.lua`)
* Consolidated LSP server configurations into clean autocmd.
* Removed `lsp_signature` helper integrations.
* Updated diagnostic jump keymaps (`]d`/`[d` and `]e`/`[e`) to use `nvim-treesitter-textobjects.repeatable_move`.

### `fzf-lua.lua` (`.config/nvim/lua/plugins/fzf-lua.lua`)
* Set `defaults.hidden = true` (show hidden dotfiles by default in fzf pickers).
* Simplified `common_actions` by removing custom `<C-e>` (open parent in Oil) and `<C-d>` (delete file) actions.

### `edgy.lua` (`.config/nvim/lua/plugins/edgy.lua`)
* Configured edgy window resizing keys table (`<M-H>`, `<M-L>`, `<C-Arrow>`) for smooth sidebar adjustments.

### `colorscheme.lua` (`.config/nvim/lua/plugins/colorscheme.lua`)
* Streamlined Gruvbox & Carbonfox theme highlight definitions and background transparency rules.

### `aerial.lua` (`.config/nvim/lua/plugins/aerial.lua`)
* Simplified Aerial code outline sidebar settings.

### `which-key.lua` (`.config/nvim/lua/plugins/which-key.lua`)
* Updated WhichKey preset/style and added `]` / `[` navigation group descriptions.

### `nvim-treesitter-text-objects.lua` (`.config/nvim/lua/plugins/nvim-treesitter-text-objects.lua`)
* Refactored text object motions into `bind_repeatable_pairs` using `make_repeatable_move` to handle forward and backward repeat movements (`/`, `;`, `,`).

### `init.lua` (`.config/nvim/init.lua`)
* Streamlined startup settings and diagnostic display options.

---

## 3. Git Status Summary

```
Changes uncommitted on top of 62ff535:
	modified:   .config/nvim/init.lua
	modified:   .config/nvim/lua/keymaps.lua
	modified:   .config/nvim/lua/plugins/aerial.lua
	deleted:    .config/nvim/lua/plugins/bufferline.lua
	modified:   .config/nvim/lua/plugins/colorscheme.lua
	modified:   .config/nvim/lua/plugins/edgy.lua
	modified:   .config/nvim/lua/plugins/fzf-lua.lua
	deleted:    .config/nvim/lua/plugins/lsp-signature.lua
	modified:   .config/nvim/lua/plugins/lsp.lua
	deleted:    .config/nvim/lua/plugins/neoscroll.lua
	modified:   .config/nvim/lua/plugins/nvim-treesitter-text-objects.lua
	deleted:    .config/nvim/lua/plugins/scrollview.lua
	deleted:    .config/nvim/lua/plugins/tiny-inline-diagnostics.lua
	deleted:    .config/nvim/lua/plugins/trouble.lua
	modified:   .config/nvim/lua/plugins/which-key.lua
```
