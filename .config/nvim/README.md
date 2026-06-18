# nvim config

Personal Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. Targets Neovim 0.10+.

## Requirements

### All platforms

- **Neovim** 0.10 or newer
- **git** (lazy.nvim uses it to clone plugins)
- **A Nerd Font** — icons throughout the UI require one (bufferline, aerial, completion menu, etc.)
- **fzf** — the fuzzy finder binary used by fzf-lua
- **fd** — fast file finder used by `<leader>sf`
- **ripgrep** (`rg`) — used by `<leader>sg` for live grep
- **Node.js** — required by Mason-installed LSP servers (bashls, html, dockerls, yamlls, marksman)

### Formatters (installed outside Mason)

These are called by conform.nvim on save and must be on your `PATH`:

| Formatter | For |
|-----------|-----|
| `ruff` | Python |
| `stylua` | Lua |
| `clang-format` | C, JSON |
| `prettier` | YAML |
| `djlint` | HTML/Django templates |
| `markdownlint` | Markdown |
| `jq` | JSONL |

### LSP servers

Mason installs these automatically on first launch: `basedpyright`, `lua_ls`, `html`, `bashls`, `marksman`, `dockerls`, `yamlls`.

**`clangd` is not managed by Mason** — it must be installed manually on every platform (see the platform sections below). After installing it, uncomment the `clangd` lines in `lua/plugins/lsp.lua`:

```lua
-- in ensure_installed:
"clangd",

-- in the servers table:
clangd = {},
```

---

## macOS

### 1. Install Neovim

```sh
brew install neovim
```

### 2. Install system dependencies

```sh
brew install git fzf fd ripgrep node
```

### 3. Install a Nerd Font

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

Then set it as your terminal font. Any Nerd Font works.

### 4. Install clangd

The simplest option is the Xcode command-line tools, which include `clangd` as part of the Apple Clang toolchain:

```sh
xcode-select --install
```

If you want a newer upstream LLVM clangd instead:

```sh
brew install llvm
echo 'export PATH="$(brew --prefix llvm)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify: `which clangd` should print a path.

Then uncomment the `clangd` lines in `lua/plugins/lsp.lua` (see the note in Requirements above).

### 5. Install formatters

```sh
brew install stylua prettier jq
pip3 install ruff djlint
npm install -g markdownlint-cli
```

`clang-format` is included with the Xcode command-line tools installed in step 4. If you installed LLVM via brew instead, `clang-format` comes with it.

### 6. Clone this config

```sh
git clone <your-repo-url> ~/.config/nvim
```

### 7. Launch Neovim

```sh
nvim
```

lazy.nvim bootstraps itself on first launch, then installs all plugins. Mason then installs LSP servers automatically.

---

## Raspberry Pi (Linux / ARM64)

The setup follows the same pattern as macOS but uses `apt` for packages. Mason cannot install `clangd` on ARM64 (its binaries are x86_64-only), so it is excluded from Mason on all platforms — install it from apt the same way as below.

### 1. Install Neovim

Raspberry Pi OS ships an outdated Neovim. Install a recent release manually:

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
tar xzf nvim-linux-arm64.tar.gz
sudo mv nvim-linux-arm64 /opt/nvim
sudo ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim
```

Verify: `nvim --version` should show 0.10 or newer.

### 2. Install system dependencies

```sh
sudo apt update
sudo apt install -y git fzf fd-find ripgrep nodejs npm curl unzip
```

`fd` is installed as `fdfind` on Debian/Ubuntu — symlink it so the config can find it:

```sh
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd
```

Make sure `~/.local/bin` is on your `PATH`. Add this to `~/.bashrc` or `~/.zshrc` if it isn't:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Install a Nerd Font

Download a Nerd Font (e.g. JetBrainsMono) from [nerdfonts.com](https://www.nerdfonts.com/), unzip it, and install:

```sh
mkdir -p ~/.local/share/fonts
unzip JetBrainsMono.zip -d ~/.local/share/fonts/
fc-cache -fv
```

Then set the font in your terminal emulator.

### 4. Install clangd

Mason's clangd binary is x86_64-only and will not run on ARM64. Install from apt:

```sh
sudo apt install -y clangd
```

This installs the default version (typically clangd-14 or clangd-16 depending on your Raspberry Pi OS release). To install a specific newer version:

```sh
sudo apt install -y clangd-16   # substitute the version available to you
sudo update-alternatives --install /usr/local/bin/clangd clangd /usr/bin/clangd-16 100
```

Verify: `which clangd` should print a path.

Then uncomment the `clangd` lines in `lua/plugins/lsp.lua` (see the note in Requirements above).

### 5. Install formatters

```sh
sudo apt install -y clang-format jq
pip3 install ruff djlint
npm install -g prettier markdownlint-cli
```

`stylua` has no apt package — install the ARM64 binary from its GitHub releases:

```sh
curl -LO https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-linux-aarch64.zip
unzip stylua-linux-aarch64.zip
chmod +x stylua
sudo mv stylua /usr/local/bin/
```

### 6. Clone this config

```sh
git clone <your-repo-url> ~/.config/nvim
```

### 7. Launch Neovim

```sh
nvim
```

lazy.nvim installs all plugins on first launch. Mason then installs LSP servers. clangd is handled separately via apt (step 4).

---

## After first launch

- `:Lazy` — check plugin install status
- `:Mason` — check LSP server install status
- `:LspInfo` (or `<leader>ci`) — confirm LSP clients are attached in a buffer
- `:TSUpdate` — update treesitter parsers

---

## Key bindings (overview)

`<leader>` is `Space`.

| Key | Action |
|-----|--------|
| `<leader>sf` | Find files (fd) |
| `<leader>sg` | Live grep (ripgrep) |
| `<leader>sb` | Switch buffer |
| `<leader>sh` | Search help tags |
| `<leader>ua` | Toggle symbol sidebar (aerial) |
| `<leader>ha` | Harpoon: add file |
| `<leader>hh` | Harpoon: open menu |
| `<leader>1-4` | Harpoon: jump to slot |
| `grd` | Go to definition |
| `grr` | LSP references |
| `<leader>ca` | Code actions |
| `<leader>cn` | Rename symbol |
| `<leader>cf` | Format file |
| `<leader>ub` | Toggle git blame |
| `]d` / `[d` | Next / prev diagnostic |
| `<Tab>` / `<S-Tab>` | Next / prev buffer |
