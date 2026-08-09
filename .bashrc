# =============================================================================
#  ~/.bashrc Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Environment & Paths
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
export VISUAL='nvim'
export PYTHONDONTWRITEBYTECODE=1

# Version Manager: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# -----------------------------------------------------------------------------
# 2. Options, History & Colored Man Pages
# -----------------------------------------------------------------------------
HISTSIZE=100000
HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
shopt -s histverify

_bash_history_sync() {
  history -a
  history -n
}

# Shell Options
shopt -s autocd 2>/dev/null || true
shopt -s autopushd 2>/dev/null || true
shopt -s interactive_comments
shopt -s extglob
shopt -s dirspell 2>/dev/null || true
shopt -s cdspell 2>/dev/null || true

bind 'set bell-style none' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null

# Colored Man Pages (simple plugin replacement)
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'


# -----------------------------------------------------------------------------
# 3. Tool Integrations & FZF
# -----------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Helper array for Cloud Storage (OneDrive & iCloud)
_cloud_search_paths=()
[[ -d "$HOME/Library/CloudStorage" ]] && _cloud_search_paths+=("$HOME/Library/CloudStorage")
[[ -d "$HOME/Library/Mobile Documents" ]] && _cloud_search_paths+=("$HOME/Library/Mobile Documents")

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git --exclude venv --exclude Library . ${_cloud_search_paths[*]}"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline --scheme=path --tiebreak=chunk,length,end,index --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview"'

# Source FZF completions and keybindings
if command -v fzf >/dev/null 2>&1; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [[ -d "/opt/homebrew/opt/fzf" ]]; then
    source "/opt/homebrew/opt/fzf/shell/key-bindings.bash" 2>/dev/null
    source "/opt/homebrew/opt/fzf/shell/completion.bash" 2>/dev/null
  elif [[ -f "/usr/share/doc/fzf/examples/key-bindings.bash" ]]; then
    source "/usr/share/doc/fzf/examples/key-bindings.bash" 2>/dev/null
    source "/usr/share/doc/fzf/examples/completion.bash" 2>/dev/null
  elif [[ -f "$HOME/.fzf.bash" ]]; then
    source "$HOME/.fzf.bash" 2>/dev/null
  fi
fi

# lsd aliases for GNU ls flag compatibility with icons
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd -1'
  alias ll='lsd -l'
  alias la='lsd -a'
  alias lt='lsd --tree'
fi


# -----------------------------------------------------------------------------
# 4. macOS Specific Configurations
# -----------------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Homebrew
  [[ -x "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

  # Pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)" 2>/dev/null || true

  # Ghostty Integration
  if [[ -n "$GHOSTTY_RESOURCES_DIR" && -z "$TMUX" ]]; then
    if [[ -f "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration" ]]; then
      source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration"
    fi
  fi

  alias eghostty='nvim ~/.config/ghostty/config'
  alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'
  alias ehammer='nvim ~/.hammerspoon/init.lua'
  alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'
fi


# -----------------------------------------------------------------------------
# 5. Aliases & Short Helper Functions
# -----------------------------------------------------------------------------
alias rezsh='source ~/.bashrc'
alias ezsh='nvim ~/.bashrc'
alias rebash='source ~/.bashrc'
alias ebash='nvim ~/.bashrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias etmux='nvim ~/.tmux.conf'
alias rag="docker compose run --rm ingest"
alias sp_rag="docker exec -it postgres psql -U dev_user -d spotify_rag"

# Portable open helper
my_open() {
  if command -v open >/dev/null 2>&1; then
    open "$@"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$@"
  else
    echo "Error: No open command found." >&2
  fi
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

f() {
  local res
  res=$(FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND" fzf)
  [[ -n "$res" ]] && dirname "$res" | pbcopy
}

vf() {
  local file
  file=$(FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND" fzf)
  [[ -n "$file" ]] && nvim "$file"
}

bin() {
  mkdir -p ~/Desktop/rubbish
  mv "$@" ~/Desktop/rubbish/
  echo "Moved to rubbish: $*"
}

clip() {
  printf "%s" "$*" | pbcopy
}

copy-pwd() {
  pwd | pbcopy
  echo "Copied: $(pwd)"
}

# Archive extraction helper (simple OMZ extract plugin replacement)
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xvf "$1"     ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


# -----------------------------------------------------------------------------
# 6. Interactive Directory Navigation (`cd` override)
# -----------------------------------------------------------------------------
cd() {
  if [[ -d "$1" || -z "$1" || "$1" == "-" ]]; then
    if declare -f __zoxide_z >/dev/null 2>&1; then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
    return
  fi

  local target="$1"
  local matches=()

  local nocaseglob_unset=0 nullglob_unset=0
  shopt -q nocaseglob || { shopt -s nocaseglob; nocaseglob_unset=1; }
  shopt -q nullglob || { shopt -s nullglob; nullglob_unset=1; }

  local glob_matches=( "$target"*/ )
  if [[ ${#glob_matches[@]} -eq 0 ]]; then
    glob_matches=( *"$target"*/ )
  fi

  [[ $nocaseglob_unset -eq 1 ]] && shopt -u nocaseglob
  [[ $nullglob_unset -eq 1 ]] && shopt -u nullglob

  for m in "${glob_matches[@]}"; do
    m="${m%/}"
    [[ -d "$m" ]] && matches+=("$m")
  done

  if [[ ${#matches[@]} -eq 1 ]]; then
    echo "Correcting cd to: ${matches[0]}"
    if declare -f __zoxide_z >/dev/null 2>&1; then
      __zoxide_z "${matches[0]}"
    else
      builtin cd "${matches[0]}"
    fi
    return
  elif [[ ${#matches[@]} -gt 1 ]]; then
    local selected
    selected=$(
      printf "%s\n" "${matches[@]}" | \
        fzf --prompt="Select directory: " --height=40% --layout=reverse --scheme=path --tiebreak=chunk,length,end,index
    )
    if [[ -n "$selected" ]]; then
      echo "Correcting cd to: $selected"
      if declare -f __zoxide_z >/dev/null 2>&1; then
        __zoxide_z "$selected"
      else
        builtin cd "$selected"
      fi
      return
    fi
  fi

  if declare -f __zoxide_z >/dev/null 2>&1; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

# Zoxide zi fallback helper
if ! declare -f zi >/dev/null 2>&1; then
  zi() {
    local dir
    dir=$(zoxide query -i "$@") && cd "$dir"
  }
fi


# -----------------------------------------------------------------------------
# 7. FZF Search Helpers & Widgets
# -----------------------------------------------------------------------------

# ---- Shared helpers (used by all widgets below) ----

# Populates $_fzf_reply with all existing cloud storage dirs, unconditionally.
_fzf_cloud_dirs_all() {
  _fzf_reply=()
  [[ -d "$HOME/Library/CloudStorage" ]] && _fzf_reply+=("$HOME/Library/CloudStorage")
  [[ -d "$HOME/Library/Mobile Documents" ]] && _fzf_reply+=("$HOME/Library/Mobile Documents")
}

# Populates $_fzf_reply with cloud storage dirs, only if they fall within
# $PWD's scope (i.e. $PWD is $HOME, ~/Library, or an ancestor of the cloud dir).
_fzf_cloud_dirs_in_scope() {
  _fzf_reply=()
  local candidate
  for candidate in "$HOME/Library/CloudStorage" "$HOME/Library/Mobile Documents"; do
    [[ -d "$candidate" ]] || continue
    if [[ "$candidate" == "$PWD"/* || "$candidate" == "$PWD" ]]; then
      _fzf_reply+=("$candidate")
    fi
  done
}

# Builds --exclude args from a pattern list into $_fzf_reply.
_fzf_build_excludes() {
  _fzf_reply=()
  local ex
  for ex in "$@"; do
    _fzf_reply+=(--exclude "$ex")
  done
}

# Resolves a path and appends it to READLINE_LINE, using ~ shorthand under $HOME.
_fzf_insert_path() {
  local resolved="$1"
  if [[ "$resolved" == "$HOME"/* ]]; then
    resolved="~/${resolved#$HOME/}"
  fi
  if [[ -n "$READLINE_LINE" && "$READLINE_LINE" != *[[:space:]] ]]; then
    READLINE_LINE="${READLINE_LINE} "
  fi
  READLINE_LINE="${READLINE_LINE}${resolved}"
  READLINE_POINT=${#READLINE_LINE}
}

_fzf_preview_file_cmd='bat --style=numbers --color=always --line-range :100 {} 2>/dev/null || head -n 100 {}'
_fzf_preview_dir_cmd='lsd --tree --depth 1 --color=always {} 2>/dev/null || eza --tree --level=1 --color=always {} 2>/dev/null || ls -la {}'


# ---- Local & Cloud Content Search (Ctrl+G) ----
rga-fzf() {
  local globs=(
    '!*.{png,jpg,jpeg,gif,webp,zip,tar,gz,mp4,mov}'
    '!**/screenshots/**'
    '!**Screenshots**'
    '!.git/**'
    '!venv/**'
    '!.venv/**'
    '!node_modules/**'
    '!__pycache__/**'
  )
  local glob_args=""
  local g
  for g in "${globs[@]}"; do
    glob_args+="--glob '$g' "
  done

  _fzf_cloud_dirs_all
  local cloud_targets=("${_fzf_reply[@]}")

  local RG_PREFIX="rga --files-with-matches --smart-case ${glob_args}"
  local file
  file=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '' . ${cloud_targets[*]}" \
    fzf --ansi \
        --disabled \
        --layout=reverse \
        --height=80% \
        --preview-window="right:60%:wrap:hidden" \
        --prompt="Search Content (Local & Cloud) > " \
        --bind "change:reload:$RG_PREFIX {q} . ${cloud_targets[*]} || true,ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
        --preview "[[ -n {} ]] && rga --pretty --context 3 {q} {}"
  )
  if [[ -n "$file" ]]; then
    file=$(echo "$file" | tr -d '\r\n')
    _fzf_insert_path "$file"
  fi
}

bind -x '"\C-g": rga-fzf' 2>/dev/null || true


# ---- Global File Search (Alt+S) ----
fzf-global-file-widget() {
  local selected_file

  _fzf_cloud_dirs_all
  local cloud_dirs=("${_fzf_reply[@]}")

  local global_excludes=(
    Library .Trash .git venv .venv node_modules __pycache__ site-packages typeshed
    CMakeFiles out build dist target .cache .local .cargo .rustup
    .npm .nvm .pyenv .gemini .docker .ollama qmk_firmware
    Pictures Movies Music "*.band" "*.app" "*.framework"
  )
  _fzf_build_excludes "${global_excludes[@]}"
  local fd_excludes=("${_fzf_reply[@]}")

  selected_file=$(
    fd --max-depth 8 --one-file-system --type f "${fd_excludes[@]}" . "$HOME" "${cloud_dirs[@]}" | \
      fzf --height 60% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Global File> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$_fzf_preview_file_cmd"
  )

  [[ -n "$selected_file" ]] && _fzf_insert_path "$selected_file"
}

bind -x '"\es": fzf-global-file-widget' 2>/dev/null || true


# ---- Local File Search (Alt+F & Ctrl+T) ----
fzf-local-file-widget() {
  local selected_file

  _fzf_cloud_dirs_in_scope
  local cloud_dirs=("${_fzf_reply[@]}")

  local local_excludes=(
    Library .git venv .venv __pycache__ node_modules site-packages typeshed
    CMakeFiles .build dist target .next .cache .local System .Trash "*.band" "*.app" "*.framework"
  )
  _fzf_build_excludes "${local_excludes[@]}"
  local fd_excludes=("${_fzf_reply[@]}")

  selected_file=$(
    fd --type f --hidden --no-ignore --one-file-system "${fd_excludes[@]}" . "$PWD" "${cloud_dirs[@]}" | \
      fzf --height 60% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Local File> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$_fzf_preview_file_cmd"
  )
  [[ -n "$selected_file" ]] && _fzf_insert_path "$selected_file"
}

bind -x '"\ef": fzf-local-file-widget' 2>/dev/null || true
bind -x '"\C-t": fzf-local-file-widget' 2>/dev/null || true


# ---- Local Directory Finder (Alt+D) ----
fzf-local-dir-widget() {
  local selected_dir

  _fzf_cloud_dirs_in_scope
  local cloud_dirs=("${_fzf_reply[@]}")

  local local_dir_excludes=(
    Library .Trash .git venv node_modules site-packages typeshed CMakeFiles .build
    dist target .next .cache .local System "*.band" "*.app" "*.framework" .cagent .claude
  )
  _fzf_build_excludes "${local_dir_excludes[@]}"
  local fd_excludes=("${_fzf_reply[@]}")

  selected_dir=$(
    fd --type d --hidden --one-file-system "${fd_excludes[@]}" . "$PWD" "${cloud_dirs[@]}" | \
      fzf --height 50% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Local Dir> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$_fzf_preview_dir_cmd"
  )
  [[ -n "$selected_dir" ]] && _fzf_insert_path "$selected_dir"
}

bind -x '"\ed": fzf-local-dir-widget' 2>/dev/null || true


# ---- Global Directory Finder (Alt+G) ----
fzf-global-dir-widget() {
  local selected_dir

  _fzf_cloud_dirs_all
  local cloud_dirs=("${_fzf_reply[@]}")

  local global_excludes=(
    Library .Trash .git venv .venv node_modules __pycache__ site-packages typeshed
    CMakeFiles out build dist target .cache .local .cargo .rustup
    .npm .nvm .pyenv .gemini .docker .ollama qmk_firmware
    Pictures Movies Music "*.epub" "*.band" "*.app" "*.framework"
  )
  _fzf_build_excludes "${global_excludes[@]}"
  local fd_excludes=("${_fzf_reply[@]}")

  selected_dir=$(
    fd --max-depth 8 --one-file-system --type d "${fd_excludes[@]}" . "$HOME" "${cloud_dirs[@]}" | \
      fzf --height 50% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Global Dir> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$_fzf_preview_dir_cmd"
  )

  [[ -n "$selected_dir" ]] && _fzf_insert_path "$selected_dir"
}

bind -x '"\eg": fzf-global-dir-widget' 2>/dev/null || true
bind -x '"\C-y\C-p": copy-pwd' 2>/dev/null || true


# -----------------------------------------------------------------------------
# 8. Custom Prompt & Path Shortening
# -----------------------------------------------------------------------------

# Function to shorten each directory level to 4 characters, showing at most 3 parents up
shorten_path() {
  local p="${PWD/#$HOME/~}"
  local is_absolute=0
  if [[ "$p" == /* ]]; then
    is_absolute=1
  fi

  local parts=()
  IFS='/' read -r -a parts <<< "$p"

  local clean_parts=()
  local part
  for part in "${parts[@]}"; do
    if [[ -n "$part" ]]; then
      clean_parts+=("$part")
    fi
  done

  local num_parts=${#clean_parts[@]}
  local to_show=()
  local truncated=0

  # Only show 3 parents up + current directory = at most 4 components
  if (( num_parts > 4 )); then
    to_show=("${clean_parts[@]: -4}")
    truncated=1
  else
    to_show=("${clean_parts[@]}")
  fi

  # Shrink each level to 4 characters
  local shrunk_parts=()
  for part in "${to_show[@]}"; do
    if [[ "$part" == "~" ]]; then
      shrunk_parts+=("~")
    else
      shrunk_parts+=("${part:0:4}")
    fi
  done

  local joined=""
  local first=1
  for part in "${shrunk_parts[@]}"; do
    if (( first )); then
      joined="$part"
      first=0
    else
      joined="$joined/$part"
    fi
  done

  local res=""
  if (( truncated )); then
    res=".../$joined"
  else
    if (( is_absolute )) && [[ "${to_show[0]}" != "~" ]]; then
      res="/$joined"
    else
      res="$joined"
    fi
  fi
  echo "$res"
}

# PS1='\u@fungus-mac:$(shorten_path)\$ '
PS1='\u@\h:$(shorten_path)\$ '


# -----------------------------------------------------------------------------
# 9. Python Virtual Environment Auto-Activation
# -----------------------------------------------------------------------------
auto_activate_venv() {
  local venv_dirs=(".venv" "venv")

  # Check if we are currently in a directory that matches the active venv
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local active_venv_dir="${VIRTUAL_ENV%/*}"
    if [[ "$PWD" == "$active_venv_dir" || "$PWD" == "$active_venv_dir"/* ]]; then
      if declare -f deactivate >/dev/null 2>&1; then
        return
      fi
    else
      # We left the active venv directory. Deactivate/cleanup.
      if declare -f deactivate >/dev/null 2>&1; then
        deactivate 2>/dev/null
      else
        PATH="${PATH//${VIRTUAL_ENV}\/bin:/}"
        PATH="${PATH//:${VIRTUAL_ENV}\/bin/}"
        unset VIRTUAL_ENV
      fi
      echo -e "\033[38;5;208m⚡ Deactivated virtual environment\033[0m"
    fi
  fi

  # Search for a venv in the current directory
  local d
  for d in "${venv_dirs[@]}"; do
    if [[ -f "$PWD/$d/bin/activate" ]]; then
      source "$PWD/$d/bin/activate"
      echo -e "\033[38;5;82m🐍 Activated Python virtual environment: \033[38;5;51m$d\033[0m \033[38;5;244m($PWD)\033[0m"
      return
    fi
  done
}

# Run on shell startup
auto_activate_venv

# Run whenever we change directory (via PROMPT_COMMAND hook)
_auto_activate_venv_hook() {
  if [[ "$PWD" != "$_LAST_HOOK_PWD" ]]; then
    _LAST_HOOK_PWD="$PWD"
    auto_activate_venv
  fi
}

PROMPT_COMMAND="_bash_history_sync; _auto_activate_venv_hook${PROMPT_COMMAND:+; $PROMPT_COMMAND}"


# -----------------------------------------------------------------------------
# 10. Folder Icon Utility
# -----------------------------------------------------------------------------
unalias dir-icons 2>/dev/null

dir-icons() {
  if [[ -z "$1" ]]; then
    echo "❌ Error: Please provide the path to an icon file."
    echo "Usage: dir-icons /path/to/icon.png"
    return 1
  fi

  local icon_path="$1"

  # Loop through all immediate, non-hidden directories at the current level
  find . -maxdepth 1 -type d -not -name "." -not -name ".*" -print0 | \
    while IFS= read -r -d "" dir; do
      echo "Stamping: $dir"
      /opt/homebrew/bin/fileicon set "$dir" "$icon_path"
    done

  echo "✅ Done! All current-level directory icons updated."
}
