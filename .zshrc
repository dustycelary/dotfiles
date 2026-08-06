# =============================================================================
#  ~/.zshrc Configuration
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
# 2. Oh My Zsh & Options
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true

# Cleaned up plugin list
plugins=(
  git
  history
  fzf
  virtualenv
  you-should-use
  colored-man-pages
  extract
  fzf-tab
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Conditional Zsh Plugins (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  plugins+=(macos)
fi

source "$ZSH/oh-my-zsh.sh"

# History Configuration
HISTSIZE=100000
SAVEHIST=100000

# Shell Options
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS EXTENDED_GLOB
unsetopt BEEP

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
_comp_options+=(globdots)


# -----------------------------------------------------------------------------
# 3. Tool Integrations & FZF
# -----------------------------------------------------------------------------
eval "$(zoxide init zsh)"

# Helper array for Cloud Storage (OneDrive & iCloud)
_cloud_search_paths=()
[[ -d "$HOME/Library/CloudStorage" ]] && _cloud_search_paths+=("$HOME/Library/CloudStorage")
[[ -d "$HOME/Library/Mobile Documents" ]] && _cloud_search_paths+=("$HOME/Library/Mobile Documents")

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git --exclude venv --exclude Library . ${_cloud_search_paths[*]}"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline --scheme=path --tiebreak=chunk,length,end,index --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview"'

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
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  # Ghostty Integration
  [[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

  alias eghostty='nvim ~/.config/ghostty/config'
  alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'
fi


# -----------------------------------------------------------------------------
# 5. Aliases & Short Helper Functions
# -----------------------------------------------------------------------------
alias rezsh='source ~/.zshrc'
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
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

copy-pwd-widget() {
  copy-pwd
  zle reset-prompt
}
zle -N copy-pwd-widget
bindkey '^y^p' copy-pwd-widget


# -----------------------------------------------------------------------------
# 6. Interactive Directory Navigation (`cd` override)
# -----------------------------------------------------------------------------
cd() {
  if [[ -d "$1" || -z "$1" || "$1" == "-" ]]; then
    if typeset -f __zoxide_z >/dev/null 2>&1; then
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
    if typeset -f __zoxide_z >/dev/null 2>&1; then
      __zoxide_z "${matches[1]}"
    else
      builtin cd "${matches[1]}"
    fi
    return
  elif [[ ${#matches} -gt 1 ]]; then
    local selected
    selected=$(
      printf "%s\n" "${matches[@]}" | \
        fzf --prompt="Select directory: " --height=40% --layout=reverse --scheme=path --tiebreak=chunk,length,end,index
    )
    if [[ -n "$selected" ]]; then
      echo "Correcting cd to: $selected"
      if typeset -f __zoxide_z >/dev/null 2>&1; then
        __zoxide_z "$selected"
      else
        builtin cd "$selected"
      fi
    fi
    return
  fi

  if typeset -f __zoxide_z >/dev/null 2>&1; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

# Zoxide zi fallback helper
if ! typeset -f zi >/dev/null 2>&1; then
  zi() {
    local dir
    dir=$(zoxide query -i "$@") && cd "$dir"
  }
fi


# -----------------------------------------------------------------------------
# 7. FZF Search Helpers & Widgets
# -----------------------------------------------------------------------------

# Local & Cloud Content Search (Ctrl+G)
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

  local cloud_targets=()
  [[ -d "$HOME/Library/CloudStorage" ]] && cloud_targets+=("$HOME/Library/CloudStorage")
  [[ -d "$HOME/Library/Mobile Documents" ]] && cloud_targets+=("$HOME/Library/Mobile Documents")

  local RG_PREFIX="rga --files-with-matches --smart-case ${glob_args}"
  local file
  file=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '' . ${_cloud_search_paths[*]}" \
    fzf --ansi \
        --disabled \
        --layout=reverse \
        --height=80% \
        --preview-window="right:60%:wrap:hidden" \
        --prompt="Search Content (Local & Cloud) > " \
        --bind "change:reload:$RG_PREFIX {q} . ${_cloud_search_paths[*]} || true,ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
        --preview "[[ -n {} ]] && rga --pretty --context 3 {q} {}"
  )
  if [[ -n "$file" ]]; then
    file=$(echo "$file" | tr -d '\r\n')
    if [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]]; then
      LBUFFER+=" "
    fi
    LBUFFER+="${(q)file}"
  fi
}

rga-fzf-local-widget() {
  rga-fzf
  zle reset-prompt
}
zle -N rga-fzf-local-widget
bindkey '^g' rga-fzf-local-widget


# Global File Search (Alt+S) - Searches Home, OneDrive & iCloud
fzf-global-file-widget() {
  local selected_file
  local cloud_dirs=()
  [[ -d "$HOME/Library/CloudStorage" ]] && cloud_dirs+=("$HOME/Library/CloudStorage")
  [[ -d "$HOME/Library/Mobile Documents" ]] && cloud_dirs+=("$HOME/Library/Mobile Documents")

  local global_excludes=(
    Library .Trash .git venv .venv node_modules __pycache__ site-packages typeshed
    CMakeFiles out build dist target .cache .local .cargo .rustup
    .npm .nvm .pyenv .gemini .docker .ollama qmk_firmware
    Pictures Movies Music "*.band" "*.app" "*.framework"
  )
  local fd_excludes=()
  local ex
  for ex in "${global_excludes[@]}"; do
    fd_excludes+=(--exclude "$ex")
  done

  local preview_cmd='bat --style=numbers --color=always --line-range :100 {} 2>/dev/null || head -n 100 {}'

  selected_file=$(
    fd --max-depth 8 --one-file-system --type f "${fd_excludes[@]}" . "$HOME" "${cloud_dirs[@]}" | \
      fzf --height 60% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Global File> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$preview_cmd"
  )

  if [[ -n "$selected_file" ]]; then
    local resolved="${selected_file:A}"
    local insert_val
    if [[ "$resolved" == "$HOME"/* ]]; then
      insert_val="~/${(q)${resolved#$HOME/}}"
    else
      insert_val="${(q)resolved}"
    fi
    if [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]]; then
      LBUFFER+=" "
    fi
    LBUFFER+="$insert_val"
  fi
  zle reset-prompt
}
zle -N fzf-global-file-widget
bindkey '\es' fzf-global-file-widget


# Local File Search (Alt+F) - Searches Current Dir & Cloud Storage
fzf-local-file-widget() {
  local selected_file
  local search_depth=()

  local cloud_dirs=()
  local candidate
  for candidate in "$HOME/Library/CloudStorage" "$HOME/Library/Mobile Documents"; do
    [[ -d "$candidate" ]] || continue
    if [[ "$candidate" == "$PWD"/* || "$candidate" == "$PWD" ]]; then
      cloud_dirs+=("$candidate")
    fi
  done

  local local_excludes=(
    Library .git venv .venv __pycache__ node_modules site-packages typeshed
    CMakeFiles .build dist target .next .cache .local System .Trash "*.band" "*.app" "*.framework"
  )
  local fd_excludes=()
  local ex
  for ex in "${local_excludes[@]}"; do
    fd_excludes+=(--exclude "$ex")
  done

  local cloud_excludes=()
  for ex in "${local_excludes[@]}"; do
    [[ "$ex" == "Library" ]] && continue
    cloud_excludes+=(--exclude "$ex")
  done

  local preview_cmd='bat --style=numbers --color=always --line-range :100 {} 2>/dev/null || head -n 100 {}'

  selected_file=$(
    {
      fd --type f --hidden --no-ignore "${search_depth[@]}" --one-file-system "${fd_excludes[@]}" . "$PWD"
      if (( ${#cloud_dirs[@]} )); then
        fd --type f --hidden --no-ignore --one-file-system "${cloud_excludes[@]}" . "${cloud_dirs[@]}"
      fi
    } | sort -u | \
      fzf --height 60% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Local File> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$preview_cmd"
  )
  if [[ -n "$selected_file" ]]; then
    local resolved="${selected_file:A}"
    local insert_val
    if [[ "$resolved" == "$HOME"/* ]]; then
      insert_val="~/${(q)${resolved#$HOME/}}"
    else
      insert_val="${(q)resolved}"
    fi
    if [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]]; then
      LBUFFER+=" "
    fi
    LBUFFER+="$insert_val"
  fi
  zle reset-prompt
}
zle -N fzf-local-file-widget
bindkey '\ef' fzf-local-file-widget


# Local Directory Finder (Alt+D) - Searches Current Dir & Cloud Storage
fzf-local-dir-widget() {
  local selected_dir
  local search_depth=()

  local cloud_dirs=()
  local candidate
  for candidate in "$HOME/Library/CloudStorage" "$HOME/Library/Mobile Documents"; do
    [[ -d "$candidate" ]] || continue
    if [[ "$candidate" == "$PWD"/* || "$candidate" == "$PWD" ]]; then
      cloud_dirs+=("$candidate")
    fi
  done

  local local_dir_excludes=(
    Library .Trash .git venv node_modules site-packages typeshed CMakeFiles .build
    dist target .next .cache .local System "*.band" "*.app" "*.framework" .cagent .claude
  )
  local fd_excludes=()
  local ex
  for ex in "${local_dir_excludes[@]}"; do
    fd_excludes+=(--exclude "$ex")
  done

  local cloud_excludes=()
  for ex in "${local_dir_excludes[@]}"; do
    [[ "$ex" == "Library" ]] && continue
    cloud_excludes+=(--exclude "$ex")
  done

  local preview_cmd='lsd --tree --depth 1 --color=always {} 2>/dev/null || eza --tree --level=1 --color=always {} 2>/dev/null || ls -la {}'

  selected_dir=$(
    {
      fd --type d --hidden "${search_depth[@]}" --one-file-system "${fd_excludes[@]}" . "$PWD"
      if (( ${#cloud_dirs[@]} )); then
        fd --type d --hidden --one-file-system "${cloud_excludes[@]}" . "${cloud_dirs[@]}"
      fi
    } | sort -u | \
      fzf --height 50% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Local Dir> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$preview_cmd"
  )
  if [[ -n "$selected_dir" ]]; then
    local resolved="${selected_dir:A}"
    local insert_val
    if [[ "$resolved" == "$HOME"/* ]]; then
      insert_val="~/${(q)${resolved#$HOME/}}"
    else
      insert_val="${(q)resolved}"
    fi
    if [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]]; then
      LBUFFER+=" "
    fi
    LBUFFER+="$insert_val"
  fi
  zle reset-prompt
}
zle -N fzf-local-dir-widget
bindkey '\ed' fzf-local-dir-widget


# Global Directory Finder (Alt+G) - Searches Home, OneDrive & iCloud
fzf-global-dir-widget() {
  local selected_dir
  local cloud_dirs=()
  [[ -d "$HOME/Library/CloudStorage" ]] && cloud_dirs+=("$HOME/Library/CloudStorage")
  [[ -d "$HOME/Library/Mobile Documents" ]] && cloud_dirs+=("$HOME/Library/Mobile Documents")

  local global_excludes=(
    Library .Trash .git venv .venv node_modules __pycache__ site-packages typeshed
    CMakeFiles out build dist target .cache .local .cargo .rustup
    .npm .nvm .pyenv .gemini .docker .ollama qmk_firmware
    Pictures Movies Music "*.epub" "*.band" "*.app" "*.framework"
  )
  local fd_excludes=()
  local ex
  for ex in "${global_excludes[@]}"; do
    fd_excludes+=(--exclude "$ex")
  done

  local preview_cmd='lsd --tree --depth 1 --color=always {} 2>/dev/null || eza --tree --level=1 --color=always {} 2>/dev/null || ls -la {}'

  selected_dir=$(
    fd --max-depth 8 --one-file-system --type d "${fd_excludes[@]}" . "$HOME" "${cloud_dirs[@]}" | \
      fzf --height 50% \
          --layout=reverse \
          --scheme=path \
          --tiebreak=chunk,length,end,index \
          --prompt="Global Dir> " \
          --preview-window="right:35%:hidden" \
          --bind "ctrl-p:toggle-preview,ctrl-/:toggle-preview" \
          --preview "$preview_cmd"
  )

  if [[ -n "$selected_dir" ]]; then
    local resolved="${selected_dir:A}"
    local insert_val
    if [[ "$resolved" == "$HOME"/* ]]; then
      insert_val="~/${(q)${resolved#$HOME/}}"
    else
      insert_val="${(q)resolved}"
    fi
    if [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]]; then
      LBUFFER+=" "
    fi
    LBUFFER+="$insert_val"
  fi
  zle reset-prompt
}
zle -N fzf-global-dir-widget
bindkey '\eg' fzf-global-dir-widget


# -----------------------------------------------------------------------------
# 8. Custom Prompt & Path Shortening
# -----------------------------------------------------------------------------

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

setopt PROMPT_SUBST
PROMPT='%n@fungus-mac:$(shorten_path)$ '


# -----------------------------------------------------------------------------
# 9. Python Virtual Environment Auto-Activation
# -----------------------------------------------------------------------------
auto_activate_venv() {
  local venv_dirs=(".venv" "venv")

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
