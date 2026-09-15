# ~/.zshrc - Interactive Zsh configuration

# Use Neovim whenever a command needs a text editor.
export EDITOR='nvim'
export VISUAL='nvim'

# Reduce delay when pressing Escape or keybindings (10ms)
export KEYTIMEOUT=1

# Keep Python from creating __pycache__ directories and .pyc files.
export PYTHONDONTWRITEBYTECODE=1


# -----------------------------------------------------------------------------
# Oh My Zsh and plugins
# -----------------------------------------------------------------------------

# Tell Oh My Zsh where it is installed.
export ZSH="$HOME/.oh-my-zsh"

# Keep Zsh's native prompt instead of loading an Oh My Zsh theme.
ZSH_THEME=""

# Skip security checks on completion directories to save disk I/O on lower-power hosts
ZSH_DISABLE_COMPFIX="true"

# Cache completion dump per host
ZSH_COMPDUMP="$HOME/.zcompdump-${HOST}-${ZSH_VERSION}"


# Use fd for FZF file searches, including hidden files but excluding bulky data.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude venv'

# Open FZF in a compact panel with results ordered from top to bottom.
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border'

# Load Git helpers, fuzzy finding, and interactive completion enhancements.
plugins=(
  git
  fzf
  zsh-completions
  zsh-autosuggestions
  aliases
)

# Skip heavy syntax-highlighting & tab completion widgets on low-power ARM devices (e.g. Raspberry Pi)
if [[ "$(uname -m)" != "arm"* && "$(uname -m)" != "aarch64"* ]]; then
  plugins+=(fzf-tab zsh-syntax-highlighting)
fi

# Initialize Oh My Zsh and the plugins listed above.
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Show the user, host, and current directory.
PROMPT='%n@%m %1~ %# '

# Ghostty only injects its integration into shells it launches directly.
# Source it in tmux-created shells so they also emit semantic prompt markers.
if [[ -n "${TMUX:-}" && -n "${GHOSTTY_RESOURCES_DIR:-}" && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi


# -----------------------------------------------------------------------------
# History, navigation, and completion
# -----------------------------------------------------------------------------

# Keep up to 100,000 commands in memory and in the history file.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# Share new commands between open terminals and keep duplicate entries out of
# saved history and interactive history searches.
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS

# If history ever exceeds its configured size, discard duplicates before
# discarding unique older commands.
setopt HIST_EXPIRE_DUPS_FIRST

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

  # Bind Alt-Z to insert a recently visited directory selected with FZF.
  recent-directory-widget() {
    local directory
    zle -I

    directory=$(command zoxide query --interactive --) || {
      zle reset-prompt
      return
    }

    if [[ -n "$directory" ]]; then
      [[ -n "$LBUFFER" && "$LBUFFER" != *[[:space:]] ]] && LBUFFER+=' '
      LBUFFER+="${(q)directory}"
    fi
    zle reset-prompt
  }
  zle -N recent-directory-widget
  bindkey '^[z' recent-directory-widget
fi

# Initialize pyenv lazily when installed so it doesn't slow down shell startup.
if command -v pyenv >/dev/null 2>&1; then
  pyenv() {
    unset -f pyenv python pip
    eval "$(command pyenv init - zsh)"
    pyenv "$@"
  }
  python() { pyenv; python "$@"; }
  pip()    { pyenv; pip "$@"; }
fi


# -----------------------------------------------------------------------------
# Small helper functions
# -----------------------------------------------------------------------------

# Fallback pbcopy implementation for Linux / Raspberry Pi OS
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

# Copy text, piped input, or file contents to the clipboard.
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


# Interactive fuzzy search for active aliases
fa() {
  alias | fzf --prompt="Aliases > " \
              --header="Enter: execute | Esc: exit" \
              --preview="echo {}" \
              --preview-window=down:3:wrap \
        | cut -d'=' -f1 \
        | read -r choice && [[ -n "$choice" ]] && print -z "$choice"
}


# -----------------------------------------------------------------------------
# Hooks
# -----------------------------------------------------------------------------

# Report commands that take at least three seconds to finish.
autoload -Uz add-zsh-hook
zmodload zsh/datetime

# Do not persist one-word commands that add little value to shell history.
filter_trivial_history() {
  emulate -L zsh
  local -a words

  words=(${(z)1})
  (( ${#words} != 1 )) || [[ "${words[1]}" != (clear|pwd|ls|ll|exit) ]]
}

typeset -gF command_started_at=0

record_command_start() {
  command_started_at=$EPOCHREALTIME
  return 0
}

report_slow_command() {
  local -F 1 duration

  if (( command_started_at > 0 )); then
    duration=$(( EPOCHREALTIME - command_started_at ))
    (( duration >= 3.0 )) && print -P "%F{yellow}Command took ${duration}s%f"
  fi

  command_started_at=0
  return 0
}

# Emit OSC 133 prompt markers so tmux (and terminals) can navigate prompts
# (used as a fallback when Ghostty's native shell integration is not active, e.g. over SSH).
if [[ ! -r "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/zsh/ghostty-integration" ]]; then
  _setup_osc133_prompt() {
    if [[ "$PROMPT" != *"\e]133;A"* ]]; then
      PROMPT=$'%{\e]133;A\a%}'"${PROMPT}"$'%{\e]133;B\a%}'
    fi
  }

  _osc133_preexec() {
    print -n "\e]133;C\a"
  }

  _osc133_precmd() {
    local last_status=$?
    print -n "\e]133;D;${last_status}\a"
  }

  add-zsh-hook precmd _setup_osc133_prompt
  add-zsh-hook precmd _osc133_precmd
  add-zsh-hook preexec _osc133_preexec
fi

add-zsh-hook preexec record_command_start
add-zsh-hook precmd report_slow_command
add-zsh-hook zshaddhistory filter_trivial_history




# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Reload or edit shell and application configuration files.
alias rezsh='exec zsh'
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias eghostty='nvim ~/.config/ghostty/config'
alias etmux='nvim ~/.tmux.conf'


# Run frequently used project commands.
alias rag='docker compose run --rm ingest'
alias sp_rag='docker exec -it postgres psql -U dev_user -d spotify_rag'

# Open frequently used notes and search scripts.
alias qn_s='nvim ~/Documents/Notes/QuickNote/scratch.md'
alias fsearch='/Users/fungus/Developer/scripts/alfred-fzf-content-search.zsh'

# for homelab help 
# Media directory base path
export MEDIA_PATH="/mnt/t7/data/media"

alias get-codecs="find \"\$MEDIA_PATH\" -type f \( -iname '*.mkv' -o -iname '*.mp4' \) -exec ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 '{}' \; -print | paste - - | awk -F'\t' '{printf \"%-10s %s\n\", \$1, \$2}'"

alias get-hevc="find \"\$MEDIA_PATH\" -type f \( -iname '*.mkv' -o -iname '*.mp4' \) -exec ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 '{}' \; -print | paste - - | awk -F'\t' '\$1 ~ /^(hevc|h265|x265)$/ {print \$2}'"

alias media-summary="find \"\$MEDIA_PATH\" -type f \( -iname '*.mkv' -o -iname '*.mp4' \) -exec ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 '{}' \; | sort | uniq -c"

# Replace ls with lsd when installed and provide common listing shortcuts.
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd -1'
fi
alias lt='ls -ltrh'
