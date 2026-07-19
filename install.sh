#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# FILES TO TRACK
# Paths are relative to ~/  — add or remove lines here to change what gets
# symlinked. Whole directories (like .config/nvim or .config/karabiner) are fine.
#
# How to track a new file/directory from ~/ in dotfiles:
#   1. Move the file/dir to your dotfiles directory (keeping the folder structure):
#      mkdir -p "$DOTFILES/path/to"
#      mv ~/path/to/file "$DOTFILES/path/to/"
#   2. Add the relative path (e.g., path/to/file) to the FILES array below.
#   3. Run this install.sh script:
#      ./install.sh
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
  .config/karabiner
)

# =============================================================================
# SYMLINK
# =============================================================================

for f in "${FILES[@]}"; do
  src="$DOTFILES/$f"
  dst="$HOME/$f"
  [[ -e "$src" ]] || { echo "  skip $f (not in dotfiles)"; continue; }
  mkdir -p "$(dirname "$dst")"
  ln -sfh "$src" "$dst" && echo "  linked ~/$f"
done

