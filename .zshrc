# =============================================================================
#  ~/.zshrc
# =============================================================================

# --- [BOTH] ---
# 1. Environment & Paths
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
export VISUAL='nvim'
export PYTHONDONTWRITEBYTECODE=1

# Version Manager: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- [BOTH] ---
# 2. Oh My Zsh & Options
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true

# Cleaned up plugin list
plugins=(
  git history fzf virtualenv you-should-use
  colored-man-pages extract
  fzf-tab zsh-completions zsh-autosuggestions zsh-syntax-highlighting
)

# --- [MAC ONLY] ---
# Conditional Zsh Plugins
if [[ "$OSTYPE" == "darwin"* ]]; then
  plugins+=(macos)
fi

# --- [BOTH] ---
source $ZSH/oh-my-zsh.sh

# History & Options
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS EXTENDED_GLOB
unsetopt BEEP
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# --- [BOTH] ---
# 3. Tool Integrations & FZF
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"

export FZF_ALT_C_COMMAND='{ zoxide query --list 2>/dev/null; fd --type d --follow --exclude .git --exclude venv --exclude node_modules } | awk "!seen[\$0]++"'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}'"

# --- [BOTH] ---
# 4. Aliases & Functions
alias rezsh='source ~/.zshrc'
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'

command -v eza >/dev/null && alias ls='eza --group-directories-first --icons' \
                           && alias ll='eza -la --group-directories-first --icons --git' \
                           && alias lt='eza --tree --level=2 --icons'
command -v bat >/dev/null && alias cat='bat --paging=never'

# Portable pbcopy via OSC 52 (works over SSH)
if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] || ! command -v pbcopy >/dev/null; then
  pbcopy() {
    local data
    if [ $# -eq 0 ]; then
      data=$(cat)
    else
      data="$*"
    fi
    local b64
    b64=$(printf "%s" "$data" | base64 | tr -d '\r\n')
    
    local osc
    if [[ -n "$TMUX" ]]; then
      osc=$(printf "\033Ptmux;\033\033]52;c;%s\a\033\\" "$b64")
    else
      osc=$(printf "\033]52;c;%s\a" "$b64")
    fi

    if [ -c /dev/tty ] && [ -w /dev/tty ]; then
      printf "%s" "$osc" > /dev/tty
    else
      printf "%s" "$osc"
    fi
  }
fi

# Portable pbpaste via OSC 52 (works over SSH)
if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] || ! command -v pbpaste >/dev/null; then
  _osc52_pbpaste() {
    if ! command -v python3 >/dev/null; then
      return 1
    fi

    local tmux_mode=0
    [[ -n "$TMUX" ]] && tmux_mode=1

    python3 - "$tmux_mode" <<'PY'
import base64
import os
import re
import select
import sys
import termios
import time
import tty

tmux_mode = len(sys.argv) > 1 and sys.argv[1] == "1"
query = b"\x1bPtmux;\x1b\x1b]52;c;?\x07\x1b\\" if tmux_mode else b"\x1b]52;c;?\x07"

with open("/dev/tty", "r+b", buffering=0) as t:
    fd = t.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        os.write(fd, query)

        buf = bytearray()
        deadline = time.monotonic() + 1.5
        while time.monotonic() < deadline:
            timeout = max(0.0, deadline - time.monotonic())
            ready, _, _ = select.select([fd], [], [], timeout)
            if not ready:
                break
            chunk = os.read(fd, 4096)
            if not chunk:
                break
            buf.extend(chunk)
            if b"\x07" in buf or b"\x1b\\" in buf:
                break

        match = re.search(rb"\]52;[^;]*;([A-Za-z0-9+/=]+)", bytes(buf))
        if not match:
            raise SystemExit(1)

        sys.stdout.buffer.write(base64.b64decode(match.group(1), validate=False))
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
PY
  }

  pbpaste() {
    if [[ -z "$SSH_CONNECTION" && -z "$SSH_CLIENT" && -z "$SSH_TTY" ]] && command -v pbpaste >/dev/null; then
      command pbpaste "$@"
      return
    fi
    if ! _osc52_pbpaste; then
      echo "pbpaste: failed to read local clipboard via OSC 52" >&2
      return 1
    fi
  }
fi

# Portable open helper
my_open() {
  if command -v open >/dev/null; then
    open "$@"
  elif command -v xdg-open >/dev/null; then
    xdg-open "$@"
  else
    echo "Error: No open command found." >&2
  fi
}

mkcd() { mkdir -p "$1" && cd "$1"; }
f() { local res; res=$(fd | fzf); [[ -n "$res" ]] && dirname "$res" | pbcopy; }
vf() { nvim "$(fd --type f | fzf)"; }
bin() { mkdir -p ~/Desktop/rubbish; mv "$@" ~/Desktop/rubbish/; echo "Moved to rubbish: $@"; }

cd() {
  if [[ -d "$1" || -z "$1" || "$1" == "-" ]]; then
    if typeset -f __zoxide_z >/dev/null; then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
    return
  fi

  setopt localoptions extendedglob
  local target="$1"
  local matches
  
  matches=( (#ia1)"$target"(N/) )

  if [[ ${#matches} -eq 0 ]]; then
    matches=( (#ia2)"$target"(N/) )
  fi

  if [[ ${#matches} -eq 1 ]]; then
    echo "Correcting cd to: ${matches[1]}"
    if typeset -f __zoxide_z >/dev/null; then
      __zoxide_z "${matches[1]}"
    else
      builtin cd "${matches[1]}"
    fi
    return
  elif [[ ${#matches} -gt 1 ]]; then
    local selected
    selected=$(printf "%s\n" "${matches[@]}" | fzf --prompt="Select directory: " --height=40% --layout=reverse)
    if [[ -n "$selected" ]]; then
      echo "Correcting cd to: $selected"
      if typeset -f __zoxide_z >/dev/null; then
        __zoxide_z "$selected"
      else
        builtin cd "$selected"
      fi
    fi
    return
  fi

  if typeset -f __zoxide_z >/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

rga-fzf() {
  local RG_PREFIX="rga --files-with-matches --smart-case --glob '!*.{png,jpg,jpeg,gif,webp,zip,tar,gz,mp4,mov}' --glob '!**/screenshots/**' --glob '!**Screenshots**'"
  local file
  file=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX ''" \
    fzf --ansi \
        --disabled \
        --layout=reverse \
        --height=80% \
        --preview-window="right:60%:wrap" \
        --prompt="Search Content (PDF/DOCX/OCR/Text) > " \
        --bind "change:reload:$RG_PREFIX {q} || true" \
        --preview "[[ -n {} ]] && rga --pretty --context 3 {q} {}"
  )
  if [[ -n "$file" ]]; then
    file=$(echo "$file" | tr -d '\r\n')
    echo "Opening $file..."
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    if [[ "$ext" == "pdf" || "$ext" == "docx" || "$ext" == "png" || "$ext" == "jpg" || "$ext" == "jpeg" ]]; then
      my_open "$file"
    else
      ${EDITOR:-nvim} "$file"
    fi
  fi
}

fzf-local-cd-widget() {
  local selected_dir
  selected_dir=$(fd --type d --follow --exclude .git --exclude venv --exclude node_modules . | \
      fzf --height 50% --layout=reverse \
          --prompt="Local Dir> " \
          --preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}')
  if [[ -n "$selected_dir" ]]; then
      builtin cd "$selected_dir"
  fi
  zle reset-prompt
}

copy-pwd() {
  pwd | pbcopy
  echo "Copied: $(pwd)"
}

# --- [MAC ONLY] ---
# 5. macOS ONLY Configurations
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  alias eghostty='nvim ~/.config/ghostty/config'
  alias pbsync='pbpaste | ssh fungus@100.112.31.8 "xclip -selection clipboard"'
  alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'
  alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'
fi

# --- [BOTH] ---
# 6. Zsh Keybindings & Widget Registration
copy-pwd-widget() {
  copy-pwd
  zle reset-prompt
}
zle -N copy-pwd-widget
bindkey '^y^p' copy-pwd-widget

rga-fzf-widget() {
  rga-fzf
  zle reset-prompt
}
zle -N rga-fzf-widget
bindkey '^g' rga-fzf-widget

zle -N fzf-local-cd-widget
bindkey '^[^g' fzf-local-cd-widget

# --- [MAC ONLY] ---
# Ghostty Integration
[[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

# --- [BOTH] ---
# Custom prompt to match default bash prompt
PROMPT='%n@%m:%~$ '
