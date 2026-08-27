# ~/.zshrc - Interactive Zsh configuration

# Use Neovim whenever a command needs a text editor.
export EDITOR='nvim'
export VISUAL='nvim'

# Keep Python from creating __pycache__ directories and .pyc files.
export PYTHONDONTWRITEBYTECODE=1


# -----------------------------------------------------------------------------
# Oh My Zsh and plugins
# -----------------------------------------------------------------------------

# Tell Oh My Zsh where it is installed.
export ZSH="$HOME/.oh-my-zsh"

# Do not load an Oh My Zsh theme because Pure prompt is initialized below.
ZSH_THEME=""

# Use fd for FZF file searches, including hidden files but excluding bulky data.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude venv'

# Open FZF in a compact panel with results ordered from top to bottom.
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border'

# Load Git helpers, fuzzy finding, and interactive completion enhancements.
# Syntax highlighting stays last because it must wrap the other Zsh widgets.
plugins=(
  git
  fzf
  fzf-tab
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Initialize Oh My Zsh and the plugins listed above.
source "$ZSH/oh-my-zsh.sh"


# -----------------------------------------------------------------------------
# History, navigation, and completion
# -----------------------------------------------------------------------------

# Keep up to 100,000 commands in memory and in the history file.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# Share new commands between open terminals and remove older duplicates.
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS

# Reload history from disk before opening FZF history search (Ctrl+R).
fzf-history-widget-sync() {
  fc -R 2>/dev/null
  zle fzf-history-widget
}
zle -N fzf-history-widget-sync
bindkey '^r' fzf-history-widget-sync

# Normalize excess spaces and review history expansions before executing them.
setopt HIST_REDUCE_BLANKS HIST_VERIFY

# Allow directory names as commands and maintain a silent directory stack.
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# Allow prompt comments and Zsh's extended filename-matching syntax.
setopt INTERACTIVE_COMMENTS EXTENDED_GLOB

# Disable the terminal bell for failed completion and similar errors.
unsetopt BEEP

# Make tab completion case-insensitive.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Include hidden files and directories in tab completion.
_comp_options+=(globdots)


# -----------------------------------------------------------------------------
# Tool integrations
# -----------------------------------------------------------------------------

# Initialize zoxide when installed; use `z` to jump to frequently used folders.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Initialize pyenv when installed so its selected Python version is available.
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# Replace ls with lsd when installed and provide common listing shortcuts.
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd -1'
fi


# -----------------------------------------------------------------------------
# Prompt
# -----------------------------------------------------------------------------

# Initialize Pure prompt (https://github.com/sindresorhus/pure).
fpath+=("/opt/homebrew/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure


# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Reload or edit shell and application configuration files.
alias rezsh='source ~/.zshrc'
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias eghostty='nvim ~/.config/ghostty/config'

# Run frequently used project commands.
alias rag='docker compose run --rm ingest'
alias sp_rag='docker exec -it postgres psql -U dev_user -d spotify_rag'

# Open frequently used notes and search scripts.
alias qn_s='nvim ~/Documents/Notes/QuickNote/scratch.md'
alias fsearch='/Users/fungus/Developer/scripts/alfred-fzf-content-search.zsh'


# -----------------------------------------------------------------------------
# Small helper functions
# -----------------------------------------------------------------------------

# Create a directory, including missing parents, and enter it.
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Select a file with FZF and copy its containing directory to the clipboard.
f() {
  local result
  result=$(fzf) || return
  [[ -n "$result" ]] && dirname "$result" | pbcopy
}

# Move files to a recoverable rubbish directory on the Desktop.
bin() {
  mkdir -p "$HOME/Desktop/rubbish"
  mv "$@" "$HOME/Desktop/rubbish/"
  echo "Moved to rubbish: $*"
}

# Copy text, piped input, or file contents to the macOS clipboard.
clip() {
  if [[ $# -eq 1 && -f "$1" ]]; then
    pbcopy < "$1"
    echo "Copied contents of '$1' to clipboard."
  elif [[ ! -t 0 ]]; then
    pbcopy
  else
    printf '%s' "$*" | pbcopy
  fi
}

# Copy actual file(s) to the macOS clipboard (for pasting in Finder, Slack, etc.).
copyfile() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: copyfile <file1> [file2 ...]" >&2
    return 1
  fi
  local files=()
  for file in "$@"; do
    if [[ ! -e "$file" ]]; then
      echo "Error: file '$file' does not exist." >&2
      return 1
    fi
    local abs_path
    abs_path="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
    files+=("POSIX file \"$abs_path\"")
  done
  local list
  list=$(IFS=,; echo "${files[*]}")
  osascript -e "set the clipboard to {$list}"
  echo "Copied $# file(s) to clipboard."
}
alias cpf='copyfile'

# Copy the current directory to the macOS clipboard.
copy-pwd() {
  pwd | pbcopy
  echo "Copied: $(pwd)"
}
alias cpwd='copy-pwd'

# Bind Ctrl-Y Ctrl-P to copy the current directory without disturbing the prompt.
copy-pwd-widget() {
  copy-pwd
  zle reset-prompt
}
zle -N copy-pwd-widget
bindkey '^y^p' copy-pwd-widget

# Search file contents locally with FZF and rga, returning the selected path.
_content_search_select() {
  FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude venv --exclude .venv' \
    fzf --disabled \
        --prompt='Content> ' \
        --header='Type to search contents; Enter inserts the selected path' \
        --bind 'change:reload:rga --files-with-matches --hidden --smart-case --glob "!.git/**" --glob "!venv/**" --glob "!.venv/**" -- {q} . 2>/dev/null || true' \
        --preview 'rga --pretty --context 4 --colors "match:fg:black" --colors "match:bg:yellow" -- {q} {} 2>/dev/null'
}

# Bind Ctrl-G to content search and insert a shell-escaped result at the cursor.
content-search-widget() {
  local file
  file=$(_content_search_select) || {
    zle reset-prompt
    return
  }

  if [[ -n "$file" ]]; then
    [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]] && LBUFFER+=' '
    LBUFFER+="${(q)file}"
  fi
  zle reset-prompt
}
zle -N content-search-widget
bindkey '^g' content-search-widget
