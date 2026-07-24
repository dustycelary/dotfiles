# =============================================================================
#  ~/.bashrc
# =============================================================================

# --- [BOTH] ---
# 1. Environment & History
export PATH="$HOME/.local/bin:$PATH"

# Homebrew setup for macOS and Linux
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

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

# --- [BOTH] ---
# 2. Tool Integrations
eval "$(zoxide init --cmd cd bash)"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND='fd --type f --hidden --no-ignore --follow --exclude .git --exclude venv --exclude .venv --exclude __pycache__ --exclude node_modules'
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --color=always {} 2>/dev/null || ls {}'"

# Source FZF completions and keybindings
if [[ -d "/opt/homebrew/opt/fzf" ]]; then
  source "/opt/homebrew/opt/fzf/shell/key-bindings.bash" 2>/dev/null
  source "/opt/homebrew/opt/fzf/shell/completion.bash" 2>/dev/null
elif [[ -f "/usr/share/doc/fzf/examples/key-bindings.bash" ]]; then
  source "/usr/share/doc/fzf/examples/key-bindings.bash" 2>/dev/null
  source "/usr/share/doc/fzf/examples/completion.bash" 2>/dev/null
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash" 2>/dev/null
fi

# Version Manager: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- [BOTH] ---
# 3. Aliases & Functions
alias envim='nvim ~/.config/nvim/init.lua'
alias etmux='nvim ~/.tmux.conf'
alias rebash='source ~/.bashrc'
alias ebash='nvim ~/.bashrc'

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

# Smart cd wrapper
cd() {
  if [[ -d "$1" || -z "$1" || "$1" == "-" ]]; then
    if declare -f __zoxide_z >/dev/null; then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
    return
  fi

  local target="$1"
  local nocaseglob_unset=0
  local nullglob_unset=0
  shopt -q nocaseglob || { shopt -s nocaseglob; nocaseglob_unset=1; }
  shopt -q nullglob || { shopt -s nullglob; nullglob_unset=1; }
  
  local matches=()
  local glob_pattern="${target}/"
  local glob_matches=( $glob_pattern )
  
  if [[ ${#glob_matches[@]} -eq 0 || ! -d "${glob_matches[0]}" ]]; then
    glob_pattern="${target}"*/
    glob_matches=( $glob_pattern )
  fi
  
  [[ $nocaseglob_unset -eq 1 ]] && shopt -u nocaseglob
  [[ $nullglob_unset -eq 1 ]] && shopt -u nullglob
  
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

  if declare -f __zoxide_z >/dev/null; then
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
        --prompt="Search Content (Local) > " \
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

# Local Content Search (Ctrl+G)
bind -x '"\C-g": rga-fzf' 2>/dev/null || true

# Global File Search (Alt+S)
fzf-global-file-widget() {
  local selected_file
  selected_file=$(fd --type f --follow --exclude .git --exclude venv --exclude .venv --exclude node_modules --exclude __pycache__ --exclude Library --exclude .cache . "$HOME" | \
      fzf --height 60% --layout=reverse \
          --prompt="Global File> " \
          --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
  if [[ -n "$selected_file" ]]; then
      if [[ -n "$READLINE_LINE" && "$READLINE_LINE" != *[[:space:]] ]]; then
          READLINE_LINE="${READLINE_LINE} "
      fi
      READLINE_LINE="${READLINE_LINE}${selected_file}"
      READLINE_POINT=${#READLINE_LINE}
  fi
}
bind -x '"\es": fzf-global-file-widget' 2>/dev/null || true

# Local File Search (Ctrl+T)
fzf-local-file-widget() {
  local selected_file
  selected_file=$(fd --type f --hidden --no-ignore --follow --exclude .git --exclude venv --exclude .venv --exclude __pycache__ --exclude node_modules . | \
      fzf --height 60% --layout=reverse \
          --prompt="Local File> " \
          --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
  if [[ -n "$selected_file" ]]; then
      if [[ -n "$READLINE_LINE" && "$READLINE_LINE" != *[[:space:]] ]]; then
          READLINE_LINE="${READLINE_LINE} "
      fi
      READLINE_LINE="${READLINE_LINE}${selected_file}"
      READLINE_POINT=${#READLINE_LINE}
  fi
}
bind -x '"\C-t": fzf-local-file-widget' 2>/dev/null || true

# Local Directory Finder (Alt+C) - Paste to prompt
fzf-local-dir-widget() {
  local selected_dir
  selected_dir=$(fd --type d --hidden --follow --exclude .git --exclude venv --exclude node_modules . | \
      fzf --height 50% --layout=reverse \
          --prompt="Local Dir> " \
          --preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls {}')
  if [[ -n "$selected_dir" ]]; then
      if [[ -n "$READLINE_LINE" && "$READLINE_LINE" != *[[:space:]] ]]; then
          READLINE_LINE="${READLINE_LINE} "
      fi
      READLINE_LINE="${READLINE_LINE}${selected_dir}"
      READLINE_POINT=${#READLINE_LINE}
  fi
}
bind -x '"\ec": fzf-local-dir-widget' 2>/dev/null || true

# Global Directory Finder (Alt+G) - Paste to prompt
fzf-global-dir-widget() {
  local selected_dir
  selected_dir=$(fd --type d --follow --exclude .git --exclude venv --exclude .venv --exclude node_modules --exclude __pycache__ --exclude Library --exclude .cache . "$HOME" | \
      fzf --height 50% --layout=reverse \
          --prompt="Global Dir> " \
          --preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls {}')
  if [[ -n "$selected_dir" ]]; then
      if [[ -n "$READLINE_LINE" && "$READLINE_LINE" != *[[:space:]] ]]; then
          READLINE_LINE="${READLINE_LINE} "
      fi
      READLINE_LINE="${READLINE_LINE}${selected_dir}"
      READLINE_POINT=${#READLINE_LINE}
  fi
}
bind -x '"\eg": fzf-global-dir-widget' 2>/dev/null || true

# Zoxide zi fallback helper
if ! declare -f zi >/dev/null; then
  zi() {
    local dir
    dir=$(zoxide query -i "$@") && cd "$dir"
  }
fi

# Fuzzy Tab Completion for Paths
_fzf_path_completion_handler() {
  # If completing the command itself (no arguments typed yet), don't do path completion
  if [[ $COMP_CWORD -eq 0 ]]; then
    return
  fi

  local cur="${COMP_WORDS[COMP_CWORD]}"
  compopt -o default 2>/dev/null

  local search_dir="."
  local query="$cur"
  if [[ "$cur" == *"/"* ]]; then
    search_dir="${cur%/*}"
    [[ -z "$search_dir" ]] && search_dir="/"
    query="${cur##*/}"
  fi

  # Expand tilde ~
  local search_dir_expanded="${search_dir/#\~/$HOME}"

  if [[ -d "$search_dir_expanded" ]]; then
    local selection
    selection=$(fd --hidden --max-depth 3 --follow --exclude .git --exclude venv --exclude node_modules . "$search_dir_expanded" 2>/dev/null | \
      fzf --height 40% --layout=reverse --query="$query" --select-1 --exit-0)
    if [[ -n "$selection" ]]; then
      # If search_dir had a tilde, convert selection prefix back to tilde
      if [[ "$search_dir" == "~"* ]]; then
        selection="${selection/#$HOME/\~}"
      fi
      COMPREPLY=( "$selection" )
      compopt +o default 2>/dev/null
    fi
  fi
}
complete -F _fzf_path_completion_handler cd nvim cat ls cp mv rm

# --- [MAC ONLY] ---
# 4. macOS ONLY
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias eghostty='nvim ~/.config/ghostty/config'
  alias ehammer='nvim ~/.hammerspoon/init.lua'
  alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'
  alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'
fi
