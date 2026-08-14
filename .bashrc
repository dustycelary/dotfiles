# ~/.bashrc - Interactive Bash configuration for macOS & Linux

# Stop here when Bash is not running interactively.
[[ $- != *i* ]] && return


# -----------------------------------------------------------------------------
# Environment and Homebrew
# -----------------------------------------------------------------------------

# Make user-installed command-line tools available.
export PATH="$HOME/.local/bin:$PATH"

# Initialize Homebrew on Apple Silicon when it is installed.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Use Neovim whenever a command needs a text editor.
export EDITOR='nvim'
export VISUAL='nvim'

# Keep Python from creating __pycache__ directories and .pyc files.
export PYTHONDONTWRITEBYTECODE=1


# -----------------------------------------------------------------------------
# History and shell behavior
# -----------------------------------------------------------------------------

# Keep up to 100,000 commands in memory and in the history file.
HISTSIZE=100000
HISTFILESIZE=100000

# Ignore commands beginning with a space and remove older duplicates.
export HISTCONTROL=ignoreboth:erasedups

# Append history, verify expansions, preserve multiline commands, and track size.
shopt -s histappend histverify cmdhist checkwinsize

# Enable convenient directory correction, automatic cd, globs, and comments.
shopt -s autocd cdspell dirspell extglob interactive_comments 2>/dev/null

# Disable the terminal bell and make completion case-insensitive.
bind 'set bell-style none' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null

# Share newly entered commands with other open Bash sessions.
_bash_history_sync() {
  history -a
  history -n
}

# Run history synchronization before each prompt without discarding other hooks.
case ";${PROMPT_COMMAND:-};" in
  *';_bash_history_sync;'*) ;;
  *) PROMPT_COMMAND="_bash_history_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac


# -----------------------------------------------------------------------------
# FZF and tool integrations
# -----------------------------------------------------------------------------

# Determine fd binary name (fd on macOS/Arch, fdfind on Debian/Ubuntu/Raspberry Pi OS)
_FD_CMD='fd'
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  _FD_CMD='fdfind'
  alias fd='fdfind'
fi

# Use fd for plain FZF searches, including hidden files but excluding bulky data.
export FZF_DEFAULT_COMMAND="$_FD_CMD --type f --hidden --exclude .git --exclude venv --exclude .venv"

# Open FZF in a compact panel with results ordered from top to bottom.
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border'

# Load FZF completion and its standard Ctrl-T, Ctrl-R, and Alt-C bindings.
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# Initialize zoxide when installed; use `z` to jump to frequently used folders.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Initialize pyenv when installed so its selected Python version is available.
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
fi

# Replace ls with lsd when installed and provide common listing shortcuts.
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd -1'
  alias ll='lsd -l'
  alias la='lsd -a'
  alias lt='lsd --tree'
fi


# -----------------------------------------------------------------------------
# Prompt
# -----------------------------------------------------------------------------

# Show the user, host, and current directory using Bash's native prompt codes.
PS1='\u@\h:\W\$ '


# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Reload or edit shell and application configuration files.
alias rebash='source ~/.bashrc'
alias ebash='$EDITOR ~/.bashrc'
alias envim='$EDITOR ~/.config/nvim/init.lua'
alias eghostty='$EDITOR ~/.config/ghostty/config'

# Run frequently used project commands.
alias rag='docker compose run --rm ingest'
alias sp_rag='docker exec -it postgres psql -U dev_user -d spotify_rag'

# Open frequently used notes and search scripts.
alias qn_s='$EDITOR ~/Documents/Notes/QuickNote/scratch.md'
alias fsearch='/Users/fungus/Developer/scripts/alfred-fzf-content-search.zsh'


# -----------------------------------------------------------------------------
# Small helper functions
# -----------------------------------------------------------------------------

# Fallback pbcopy implementation for Linux / Raspberry Pi OS (using xclip, xsel, or wl-copy)
if ! command -v pbcopy >/dev/null 2>&1; then
  if command -v xclip >/dev/null 2>&1; then
    pbcopy() { xclip -selection clipboard "$@"; }
  elif command -v xsel >/dev/null 2>&1; then
    pbcopy() { xsel --clipboard --input "$@"; }
  elif command -v wl-copy >/dev/null 2>&1; then
    pbcopy() { wl-copy "$@"; }
  fi
fi

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

# Copy the supplied text to the macOS clipboard.
clip() {
  printf '%s' "$*" | pbcopy
}

# Copy the current directory to the macOS clipboard.
copy-pwd() {
  pwd | pbcopy
  echo "Copied: $(pwd)"
}
alias cpwd='copy-pwd'

# Bind Ctrl-Y Ctrl-P to copy the current directory.
bind -x '"\C-y\C-p":copy-pwd' 2>/dev/null

# Search file contents locally with FZF and rga, returning the selected path.
_content_search_select() {
  FZF_DEFAULT_COMMAND="$_FD_CMD --type f --hidden --exclude .git --exclude venv --exclude .venv" \
    fzf --disabled \
        --prompt='Content> ' \
        --header='Type to search contents; Enter inserts the selected path' \
        --bind 'change:reload:rga --files-with-matches --hidden --smart-case --glob "!.git/**" --glob "!venv/**" --glob "!.venv/**" -- {q} . 2>/dev/null || true' \
        --preview 'rga --pretty --context 4 --colors "match:fg:black" --colors "match:bg:yellow" -- {q} {} 2>/dev/null'
}

# Bind Ctrl-G to content search and insert a shell-escaped result at the cursor.
content-search-widget() {
  local file quoted left right
  file=$(_content_search_select) || return
  [[ -n "$file" ]] || return

  printf -v quoted '%q' "$file"
  left=${READLINE_LINE:0:READLINE_POINT}
  right=${READLINE_LINE:READLINE_POINT}
  [[ -n "$left" && "$left" != *[[:space:]] ]] && quoted=" $quoted"
  READLINE_LINE="${left}${quoted}${right}"
  READLINE_POINT=$(( ${#left} + ${#quoted} ))
}
bind -x '"\C-g":content-search-widget' 2>/dev/null
