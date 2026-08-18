# Neovim Configuration Changes (Commit `44a8788` → `62ff535`)

This document contains a complete list of all features, plugins, and keymaps introduced in commit `62ff535` (`feat(nvim): enhance edgy resizing, buffer switching, and diagnostics hub`), relative to the base configuration at commit `44a8788`.

---

## 1. Summary of Changes by Category

### AI Code Completion
* **`supermaven-nvim`** (`.config/nvim/lua/plugins/supermaven.lua`)
  * Ultra-fast AI inline code completion engine.
  * Keymaps: `<C-a>` to accept suggestion, `<C-j>` to accept word, `<C-]>` to clear suggestion.
  * Command: `:SupermavenStatus`, `:SupermavenUseFree`, `:SupermavenUsePro`

### Snippets & Templating
* **`LuaSnip` & Custom Snippets** (`.config/nvim/lua/plugins/luasnip.lua`, `.config/nvim/snippets/`)
  * Custom snippet expansion integrated into `nvim-cmp`.
  * Included custom snippet files:
    * `snippets/lua.json`: `req` for `require()`, `pp` for `vim.inspect()`.
    * `snippets/python.json`: `main` block `if __name__ == "__main__":`.
    * `snippets/package.json`: VSCode-style snippet manifest.

### Navigation & Code Structure
* **`treesitter-context`** (`.config/nvim/lua/plugins/treesitter-context.lua`)
  * Sticky header pinned to the top of the buffer showing current function/class signature.
  * Keymap: `<leader>ut` to toggle on/off.
* **`flash.nvim`** (`.config/nvim/lua/plugins/flash.lua`)
  * 2-character label motion navigation (`s`, `S`).
* **`marks.nvim`** (`.config/nvim/lua/plugins/marks.lua`)
  * Enhanced Vim mark indicators in sign column and mark navigation (`]'` / `['`).

### Window & Panel Management
* **`edgy.nvim`** (`.config/nvim/lua/plugins/edgy.lua`)
  * Sidebar and bottom panel management with keybindings to resize split windows (`<M-H>`, `<M-L>`, `<C-Arrow>`).
* **`nvim-tree.lua`** (`.config/nvim/lua/plugins/nvim-tree.lua`)
  * File explorer tree sidebar (`<leader>ue` to toggle, `<leader>fe` to locate file).
* **`toggleterm.nvim`** (`.config/nvim/lua/plugins/toggleterm.lua`)
  * Floating, horizontal, and vertical terminal splits (`<C-\>`, `<leader>tt`, `<leader>tf`, `<leader>th`, `<leader>tv`).

### UI, Diagnostics & Buffer Navigation
* **`tiny-inline-diagnostics`** (`.config/nvim/lua/plugins/tiny-inline-diagnostics.lua`)
  * Powerline-style multiline diagnostic callouts beneath code lines (`<leader>xt` / `<leader>ud` to toggle).
* **Bufferline Navigation** (`.config/nvim/lua/plugins/bufferline.lua`, `.config/nvim/lua/keymaps.lua`)
  * `<S-h>` / `<S-l>` for previous/next buffer navigation.
  * `<leader><space>` for fast buffer toggle (`<C-^>`).
  * Removed `<Tab>` / `<S-Tab>` from bufferline to prevent conflicts with autocomplete and jumplists.
* **Diagnostics Hub in WhichKey** (`.config/nvim/lua/plugins/trouble.lua`, `.config/nvim/lua/plugins/which-key.lua`)
  * Consolidated all diagnostic search tools under `<leader>x` (`<leader>xx`, `<leader>xX`, `<leader>xd`, `<leader>xD`, `<leader>xe`).

---

## 2. Restore Commands

### Restore Individual Features

Run any of the following commands in your shell to bring back a specific feature:

```bash
# 1. Supermaven AI Completion
git checkout 62ff535 -- .config/nvim/lua/plugins/supermaven.lua

# 2. LuaSnip & Custom Snippets
git checkout 62ff535 -- .config/nvim/lua/plugins/luasnip.lua .config/nvim/snippets/

# 3. Treesitter Sticky Context Headers
git checkout 62ff535 -- .config/nvim/lua/plugins/treesitter-context.lua

# 4. Edgy Sidebar Resizing
git checkout 62ff535 -- .config/nvim/lua/plugins/edgy.lua

# 5. Nvim-Tree File Explorer Sidebar
git checkout 62ff535 -- .config/nvim/lua/plugins/nvim-tree.lua

# 6. ToggleTerm Floating Terminals
git checkout 62ff535 -- .config/nvim/lua/plugins/toggleterm.lua

# 7. Marks Indicator Plugin
git checkout 62ff535 -- .config/nvim/lua/plugins/marks.lua

# 8. Flash Motion Jumps
git checkout 62ff535 -- .config/nvim/lua/plugins/flash.lua

# 9. Tiny Inline Diagnostics
git checkout 62ff535 -- .config/nvim/lua/plugins/tiny-inline-diagnostics.lua

# 10. Buffer Navigation Keys (<S-h>/<S-l>/<leader><space>)
git checkout 62ff535 -- .config/nvim/lua/plugins/bufferline.lua .config/nvim/lua/keymaps.lua

# 11. Diagnostics Hub (<leader>x)
git checkout 62ff535 -- .config/nvim/lua/plugins/trouble.lua .config/nvim/lua/plugins/which-key.lua
```

### Restore All Features from Commit `62ff535` at Once

```bash
git checkout 62ff535 -- .config/nvim
```
