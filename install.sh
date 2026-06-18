#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# FILES TO TRACK
# Paths are relative to ~/  — add or remove lines here to change what gets
# symlinked. Whole directories (like .config/nvim) are fine too.
# =============================================================================

FILES=(
  .zshrc
  .bashrc
  .zprofile
  .gitconfig
  .tmux.conf
  .p10k.zsh
  .inputrc
  .config/ghostty/config
  .config/nvim
  .hammerspoon/init.lua
  .hammerspoon/hammer-control
)

# =============================================================================
# SYMLINK
# =============================================================================

for f in "${FILES[@]}"; do
  src="$DOTFILES/$f"
  dst="$HOME/$f"
  [[ -e "$src" ]] || { echo "  skip $f (not in dotfiles)"; continue; }
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst" && echo "  linked ~/$f"
done

