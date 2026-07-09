# =============================================================================
#  ~/.zshrc
# =============================================================================

# =============================================================================
# 1. SHARED (macOS & Raspberry Pi) - Instant Prompt & Env
# =============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
export VISUAL='nvim'
export PYTHONDONTWRITEBYTECODE=1

# Version Manager: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# =============================================================================
# 2. SHARED (macOS & Raspberry Pi) - Oh My Zsh & Options
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="powerlevel10k/powerlevel10k"

# Cleaned up plugin list (removed jump, copypath, copyfile)
plugins=(
  git history fzf virtualenv you-should-use
  colored-man-pages extract
  fzf-tab zsh-completions zsh-autosuggestions zsh-syntax-highlighting
)

# Conditional Zsh Plugins
if [[ "$OSTYPE" == "darwin"* ]]; then
  plugins+=(macos)
fi

source $ZSH/oh-my-zsh.sh

# History & Options
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS EXTENDED_GLOB
unsetopt BEEP
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# =============================================================================
# 3. SHARED (macOS & Raspberry Pi) - Tool Integrations & FZF
# =============================================================================
# zoxide - maps cd to zoxide (note: we still define cd wrapper below)
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"

export FZF_ALT_C_COMMAND='{ zoxide query --list 2>/dev/null; fd --type d --follow --exclude .git --exclude venv --exclude node_modules } | awk "!seen[\$0]++"'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}'"

# =============================================================================
# 4. SHARED (macOS & Raspberry Pi) - Aliases & Functions
# =============================================================================
alias rezsh='source ~/.zshrc'
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
      # Wrap in tmux DCS passthrough sequence
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
    # If a native pbpaste exists and we are NOT under SSH, use it
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
  # If the directory exists, is empty, or is "-", run normal cd (through zoxide if present)
  if [[ -d "$1" || -z "$1" || "$1" == "-" ]]; then
    if typeset -f __zoxide_z >/dev/null; then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
    return
  fi

  # If it doesn't exist, search for a similar directory using Zsh's approximate globbing.
  # (#ia1) allows case-insensitivity + 1 typo, (#ia2) allows case-insensitivity + 2 typos.
  # (/) ensures we only match directories.
  setopt localoptions extendedglob
  local target="$1"
  local matches
  
  # Try with 1 typo first (case-insensitive)
  matches=( (#ia1)"$target"(N/) )

  # If no match, try with 2 typos (case-insensitive)
  if [[ ${#matches} -eq 0 ]]; then
    matches=( (#ia2)"$target"(N/) )
  fi

  # If we found exactly one matching directory, go straight into it!
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

  # Otherwise, pass through to let zoxide query database or print directory not found
  if typeset -f __zoxide_z >/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

rga-fzf() {
  local RG_PREFIX="rga --files-with-matches --smart-case"
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

# =============================================================================
# 5. macOS ONLY
# =============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  alias ezsh='nvim ~/.zshrc'
  alias eghostty='nvim ~/.config/ghostty/config'
  alias pbsync='pbpaste | ssh fungus@100.112.31.8 "xclip -selection clipboard"'
  alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'
  alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'

  vgr() {
    local id=$(vimgolf list | python3 -c "import sys, random; ids = [line.split('(')[-1].split(')')[0] for line in sys.stdin if '(' in line]; print(random.choice(ids))")
    if [ -z "$id" ]; then
      echo "Error: Could not retrieve a challenge ID."
      return 1
    fi
    local url="https://www.vimgolf.com/challenges/$id"
    echo "$url" | pbcopy
    echo "--------------------------------------------------------"
    echo "🎯 Challenge URL (Copied to Clipboard!):"
    echo "   $url"
    echo "--------------------------------------------------------"
    echo "Press [Enter] to launch Neovim and start the challenge..."
    read -r
    vimgolf put "$id"
  }
fi

# =============================================================================
# 6. RASPBERRY PI / LINUX ONLY
# =============================================================================
if [[ "$OSTYPE" != "darwin"* ]]; then
  alias ezsh='nvim ~/.zshrc'
fi

# =============================================================================
# 7. Zsh Keybindings & Widget Registration
# =============================================================================
# Ctrl+Y Ctrl+P for copy-pwd
copy-pwd-widget() {
  copy-pwd
  zle reset-prompt
}
zle -N copy-pwd-widget
bindkey '^y^p' copy-pwd-widget

# Ctrl+G for interactive rga content search
rga-fzf-widget() {
  rga-fzf
  zle reset-prompt
}
zle -N rga-fzf-widget
bindkey '^g' rga-fzf-widget

# Ctrl+Alt+G for local directory cd widget
zle -N fzf-local-cd-widget
bindkey '^[^g' fzf-local-cd-widget

# Ghostty Integration
[[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

# P10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
