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
_comp_options+=(globdots)

# --- [BOTH] ---
# 3. Tool Integrations & FZF
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND='fd --type f --hidden --no-ignore --follow --exclude .git --exclude venv --exclude .venv --exclude __pycache__ --exclude node_modules'
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"

export FZF_ALT_C_COMMAND='{ zoxide query --list 2>/dev/null; fd --type d --hidden --follow --exclude .git --exclude venv --exclude node_modules } | awk "!seen[\$0]++"'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}'"

# --- [BOTH] ---
# 4. Aliases & Functions
alias rezsh='source ~/.zshrc'
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias spotify-db="docker exec -it postgres psql -U dev_user -d spotify_rag"

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

# Local Content Search (Ctrl+G)
rga-fzf-local-widget() {
  rga-fzf
  zle reset-prompt
}
zle -N rga-fzf-local-widget
bindkey '^g' rga-fzf-local-widget

# Global File Search (Alt+S)
fzf-global-file-widget() {
  local selected_file
  selected_file=$(fd --type f --follow --exclude .git --exclude venv --exclude .venv --exclude node_modules --exclude __pycache__ --exclude Library --exclude .cache . "$HOME" | \
      fzf --height 60% --layout=reverse \
          --prompt="Global File> " \
          --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
  if [[ -n "$selected_file" ]]; then
      if [[ -n "$BUFFER" && "$BUFFER" != *[[:space:]] ]]; then
          BUFFER+=" "
      fi
      BUFFER+="${(q)selected_file}"
      CURSOR=${#BUFFER}
  fi
  zle reset-prompt
}
zle -N fzf-global-file-widget
bindkey '\es' fzf-global-file-widget

# Local File Search (Ctrl+T)
fzf-local-file-widget() {
  local selected_file
  selected_file=$(fd --type f --hidden --no-ignore --follow --exclude .git --exclude venv --exclude .venv --exclude __pycache__ --exclude node_modules . | \
      fzf --height 60% --layout=reverse \
          --prompt="Local File> " \
          --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
  if [[ -n "$selected_file" ]]; then
      if [[ -n "$BUFFER" && "$BUFFER" != *[[:space:]] ]]; then
          BUFFER+=" "
      fi
      BUFFER+="${(q)selected_file}"
      CURSOR=${#BUFFER}
  fi
  zle reset-prompt
}
zle -N fzf-local-file-widget
bindkey '^T' fzf-local-file-widget

# Local Directory Finder (Alt+C) - Paste to prompt
fzf-local-dir-widget() {
  local selected_dir
  selected_dir=$(fd --type d --hidden --follow --exclude .git --exclude venv --exclude node_modules . | \
      fzf --height 50% --layout=reverse \
          --prompt="Local Dir> " \
          --preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}')
  if [[ -n "$selected_dir" ]]; then
      if [[ -n "$BUFFER" && "$BUFFER" != *[[:space:]] ]]; then
          BUFFER+=" "
      fi
      BUFFER+="${(q)selected_dir}"
      CURSOR=${#BUFFER}
  fi
  zle reset-prompt
}
zle -N fzf-local-dir-widget
bindkey '\ec' fzf-local-dir-widget

# Global Directory Finder (Alt+G) - Paste to prompt
fzf-global-dir-widget() {
  local selected_dir
  selected_dir=$(fd --type d --follow --exclude .git --exclude venv --exclude .venv --exclude node_modules --exclude __pycache__ --exclude Library --exclude .cache . "$HOME" | \
      fzf --height 50% --layout=reverse \
          --prompt="Global Dir> " \
          --preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}')
  if [[ -n "$selected_dir" ]]; then
      if [[ -n "$BUFFER" && "$BUFFER" != *[[:space:]] ]]; then
          BUFFER+=" "
      fi
      BUFFER+="${(q)selected_dir}"
      CURSOR=${#BUFFER}
  fi
  zle reset-prompt
}
zle -N fzf-global-dir-widget
bindkey '\eg' fzf-global-dir-widget

# Zoxide zi fallback helper
if ! typeset -f zi >/dev/null; then
  zi() {
    local dir
    dir=$(zoxide query -i "$@") && cd "$dir"
  }
fi

# --- [MAC ONLY] ---
# Ghostty Integration
[[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

# --- [BOTH] ---
# Function to shorten each directory level to 4 characters, showing at most 3 parents up
shorten_path() {
  local p="${PWD/#$HOME/~}"
  local -a parts
  parts=("${(s:/:)p}")
  
  local is_absolute=0
  if [[ "$p" == /* ]]; then
    is_absolute=1
  fi
  
  local -a clean_parts
  local part
  for part in "${parts[@]}"; do
    if [[ -n "$part" ]]; then
      clean_parts+=("$part")
    fi
  done
  
  local num_parts=${#clean_parts}
  local -a to_show
  local truncated=0
  
  # Only show 3 parents up + current directory = at most 4 components
  if (( num_parts > 4 )); then
    to_show=("${clean_parts[@]: -4}")
    truncated=1
  else
    to_show=("${clean_parts[@]}")
  fi
  
  # Shrink each level to 4 characters
  local -a shrunk_parts
  for part in "${to_show[@]}"; do
    if [[ "$part" == "~" ]]; then
      shrunk_parts+=("~")
    else
      shrunk_parts+=("${part[1,4]}")
    fi
  done
  
  local res=""
  if (( truncated )); then
    res=".../${(j:/:)shrunk_parts}"
  else
    if (( is_absolute )) && [[ "${to_show[1]}" != "~" ]]; then
      res="/${(j:/:)shrunk_parts}"
    else
      res="${(j:/:)shrunk_parts}"
    fi
  fi
  echo "$res"
}

# Enable prompt function/variable substitution
setopt PROMPT_SUBST

# Custom prompt to match default bash prompt with custom hostname and abbreviated path
PROMPT='%n@fungus-mac:$(shorten_path)$ '

# --- [BOTH] ---
# 8. Python Virtual Environment Auto-Activation
auto_activate_venv() {
  local venv_dirs=(".venv" "venv")
  local found_venv=""

  # Check if we are currently in a directory that matches the active venv
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local active_venv_dir="${VIRTUAL_ENV:h}"
    if [[ "$PWD" == "$active_venv_dir" || "$PWD" == "$active_venv_dir"/* ]]; then
      # If deactivate function is also defined, we are fully activated.
      if (( $+functions[deactivate] )); then
        return
      fi
      # If deactivate function is not defined (e.g., inherited environment),
      # we will proceed to re-source the activation script below.
    else
      # We left the active venv directory. Deactivate/cleanup.
      if (( $+functions[deactivate] )); then
        deactivate 2>/dev/null
      else
        # Manual cleanup for inherited env
        PATH="${PATH//${VIRTUAL_ENV}\/bin:/}"
        PATH="${PATH//:${VIRTUAL_ENV}\/bin/}"
        unset VIRTUAL_ENV
      fi
      print -P "%F{208}⚡ Deactivated virtual environment%f"
    fi
  fi

  # Search for a venv in the current directory
  local d
  for d in "${venv_dirs[@]}"; do
    if [[ -f "$PWD/$d/bin/activate" ]]; then
      source "$PWD/$d/bin/activate"
      print -P "%F{82}🐍 Activated Python virtual environment: %F{51}$d%f %F{244}(%~)%f"
      return
    fi
  done
}

# Run on shell startup
auto_activate_venv

# Run whenever we change directory
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_activate_venv
