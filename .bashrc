# =============================================================================
#  ~/.bashrc
# =============================================================================

# =============================================================================
# 1. SHARED (macOS & Raspberry Pi) - Environment & History
# =============================================================================
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
export VISUAL='nvim'
export PYTHONDONTWRITEBYTECODE=1

HISTSIZE=100000
HISTFILESIZE=100000
shopt -s histappend

_bash_history_sync() {
  history -a
  history -n
}

if [[ "$PROMPT_COMMAND" != *"_bash_history_sync"* ]]; then
  PROMPT_COMMAND="_bash_history_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

export HISTCONTROL=ignoreboth:erasedups
shopt -s histverify
shopt -s autocd 2>/dev/null || true
shopt -s autopushd 2>/dev/null || true
shopt -s interactive_comments
shopt -s extglob

bind 'set bell-style none' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null

# =============================================================================
# 2. SHARED (macOS & Raspberry Pi) - Tool Integrations
# =============================================================================
# zoxide - smart directory jumping
eval "$(zoxide init --cmd cd bash)"

# fzf - fuzzy finder
export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --color=always {} 2>/dev/null || ls {}'"

# Version Manager: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# =============================================================================
# 3. SHARED (macOS & Raspberry Pi) - Aliases & Functions
# =============================================================================
alias envim='nvim ~/.config/nvim/init.lua'
alias etmux='nvim ~/.tmux.conf'
alias rebash='source ~/.bashrc'

# Modern CLI replacements
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
      osc=$(printf "\033Ptmux;\033\033]52;c;%s\a\033\\\\" "$b64")
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
f() {
  local result
  result=$(fd | fzf)
  [[ -n "$result" ]] && dirname "$result" | pbcopy
}
vf() { nvim "$(fd --type f | fzf)"; }
bin() {
  mkdir -p ~/Desktop/rubbish
  mv "$@" ~/Desktop/rubbish/
  echo "Moved to rubbish: $@"
}

# Smart cd wrapper that automatically corrects spelling typos for local/relative paths
cd() {
  # If the directory exists, is empty, or is "-", run normal cd (through zoxide if present)
  if [[ -d "$1" || -z "$1" || "$1" == "-" ]]; then
    if declare -f __zoxide_z >/dev/null; then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
    return
  fi

  # In Bash, we don't have Zsh's approximate globbing (#ia1), but we can enable
  # case-insensitive globbing (nocaseglob) and spelling correction (cdspell).
  # We can also do a quick check to see if there is a case-insensitive match.
  local target="$1"
  
  # Enable nocaseglob and nullglob temporarily to search for case-insensitive matches
  local nocaseglob_unset=0
  local nullglob_unset=0
  shopt -q nocaseglob || { shopt -s nocaseglob; nocaseglob_unset=1; }
  shopt -q nullglob || { shopt -s nullglob; nullglob_unset=1; }
  
  local matches=()
  # Use glob to find case-insensitive matching directories
  local glob_pattern="${target}/"
  local glob_matches=( $glob_pattern )
  
  # If no direct match, try matching directories starting with target
  if [[ ${#glob_matches[@]} -eq 0 || ! -d "${glob_matches[0]}" ]]; then
    glob_pattern="${target}"*/
    glob_matches=( $glob_pattern )
  fi
  
  # Restore options
  [[ $nocaseglob_unset -eq 1 ]] && shopt -u nocaseglob
  [[ $nullglob_unset -eq 1 ]] && shopt -u nullglob
  
  # If we found exactly one matching directory, go straight into it!
  if [[ ${#glob_matches[@]} -eq 1 && -d "${glob_matches[0]}" ]]; then
    local corrected="${glob_matches[0]%/}"
    echo "Correcting cd to: $corrected"
    if declare -f __zoxide_z >/dev/null; then
      __zoxide_z "$corrected"
    else
      builtin cd "$corrected"
    fi
    return
  fi

  # Otherwise, pass through to let zoxide query database or print directory not found
  if declare -f __zoxide_z >/dev/null; then
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

# Keybindings
bind -r '\el' 2>/dev/null || true
bind '"\C-v\C-e": edit-and-execute-command' 2>/dev/null || true
copy-pwd() {
  pwd | pbcopy
  echo "Copied: $(pwd)"
}
bind -x '"\C-y\C-p": copy-pwd' 2>/dev/null || true
bind -x '"\C-g": rga-fzf' 2>/dev/null || true


# =============================================================================
# 4. macOS ONLY
# =============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ebash='nvim ~/.bashrc'
  alias eghostty='nvim ~/.config/ghostty/config'
  alias ehammer='nvim ~/.hammerspoon/init.lua'
  alias pbsync='pbpaste | ssh fungus@100.112.31.8 "xclip -selection clipboard"'
  alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'
  alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'
fi


# =============================================================================
# 5. RASPBERRY PI / LINUX ONLY
# =============================================================================
if [[ "$OSTYPE" != "darwin"* ]]; then
  alias ebash='nvim ~/.bashrc'
fi
