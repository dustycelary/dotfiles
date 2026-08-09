# =============================================================================
# ~/.bashrc (portable + simplified)
# =============================================================================

[[ $- != *i* ]] && return

# ---- Platform detection ------------------------------------------------------
_os="$(uname -s)"
_arch="$(uname -m)"
is_macos=0
is_linux=0
is_pi=0
[[ "$_os" == "Darwin" ]] && is_macos=1
[[ "$_os" == "Linux" ]] && is_linux=1
if (( is_linux )) && [[ -r /proc/device-tree/model ]] && grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null; then
  is_pi=1
fi

has() { command -v "$1" >/dev/null 2>&1; }

# ---- Environment -------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PYTHONDONTWRITEBYTECODE=1

if has nvim; then
  export EDITOR="nvim"
elif has vim; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi
export VISUAL="$EDITOR"

# ---- History and shell behavior ---------------------------------------------
HISTSIZE=100000
HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend histverify cmdhist checkwinsize
shopt -s autocd cdspell dirspell 2>/dev/null || true
shopt -s extglob interactive_comments

bind 'set bell-style none' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null

_bash_history_sync() { history -a; history -n; }

# Colored man pages
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'

# ---- Optional tool init (safe if missing) -----------------------------------
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

if (( is_macos )) && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif (( is_linux )) && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
has pyenv && eval "$(pyenv init -)" 2>/dev/null

has zoxide && eval "$(zoxide init bash)"

# fd package name differs on Debian/Raspberry Pi (fdfind)
if ! has fd && has fdfind; then alias fd='fdfind'; fi
export FZF_COMPLETION_TRIGGER='**'

if has fzf; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    . /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null
    . /usr/share/doc/fzf/examples/completion.bash 2>/dev/null
  elif [[ -f "$HOME/.fzf.bash" ]]; then
    . "$HOME/.fzf.bash" 2>/dev/null
  fi
fi

bind 'set show-all-if-ambiguous off' 2>/dev/null
bind 'set completion-query-items 999999' 2>/dev/null

if has fd; then export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude venv --exclude .venv .'; fi
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'

# ---- Clipboard / opener portability -----------------------------------------
copy_to_clipboard() {
  if has pbcopy; then
    pbcopy
  elif has wl-copy; then
    wl-copy
  elif has xclip; then
    xclip -selection clipboard
  elif has xsel; then
    xsel --clipboard --input
  else
    echo "No clipboard tool found (pbcopy/wl-copy/xclip/xsel)." >&2
    return 1
  fi
}

my_open() {
  if has open; then
    open "$@"
  elif has xdg-open; then
    xdg-open "$@"
  else
    echo "No opener found (open/xdg-open)." >&2
    return 1
  fi
}

# ---- Aliases ----------------------------------------------------------------
alias rebash='source ~/.bashrc'
alias ebash='$EDITOR ~/.bashrc'
alias envim='$EDITOR ~/.config/nvim/init.lua'
alias etmux='$EDITOR ~/.tmux.conf'
alias rag='docker compose run --rm ingest'
alias sp_rag='docker exec -it postgres psql -U dev_user -d spotify_rag'

if has eza; then
  alias ls='eza -1'
  alias ll='eza -l'
  alias la='eza -la'
  alias lt='eza --tree --level=2'
elif has lsd; then
  alias ls='lsd -1'
  alias ll='lsd -l'
  alias la='lsd -a'
  alias lt='lsd --tree'
else
  alias ll='ls -alF'
  alias la='ls -A'
fi

# ---- Small helpers -----------------------------------------------------------
mkcd() { mkdir -p "$1" && cd "$1"; }
clip() { printf "%s" "$*" | copy_to_clipboard; }
copy-pwd() { pwd | copy_to_clipboard && echo "Copied: $(pwd)"; }

f() {
  has fzf || { echo "fzf is not installed."; return 1; }
  local res
  res="$(fzf)"
  [[ -n "$res" ]] && dirname "$res" | copy_to_clipboard
}

vf() {
  has fzf || { echo "fzf is not installed."; return 1; }
  local file
  file="$(fzf)"
  [[ -n "$file" ]] && "$EDITOR" "$file"
}

extract() {
  [[ -f "$1" ]] || { echo "'$1' is not a valid file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar) tar xvf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.zip) unzip "$1" ;;
    *.rar) unrar x "$1" ;;
    *.7z) 7z x "$1" ;;
    *.Z) uncompress "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ; return 1 ;;
  esac
}

if has zoxide && ! declare -f zi >/dev/null 2>&1; then
  zi() {
    local dir
    dir="$(zoxide query -i "$@")" && cd "$dir"
  }
fi

# ---- Prompt -----------------------------------------------------------------
shorten_path() {
  local p="${PWD/#$HOME/~}" is_abs=0
  [[ "$p" == /* ]] && is_abs=1

  local -a parts shown
  IFS='/' read -r -a parts <<< "$p"

  local seg
  for seg in "${parts[@]}"; do
    [[ -n "$seg" ]] && shown+=("$seg")
  done

  local n="${#shown[@]}" start=0 prefix=""
  (( n > 4 )) && { start=$((n-4)); prefix=".../"; }

  local out="" i piece
  for ((i=start; i<n; i++)); do
    piece="${shown[i]}"
    [[ "$piece" != "~" ]] && piece="${piece:0:4}"
    [[ -n "$out" ]] && out+="/"
    out+="$piece"
  done

  [[ -z "$out" ]] && { echo "/"; return; }
  (( is_abs )) && [[ "${shown[start]}" != "~" ]] && out="/$out"
  echo "${prefix}${out}"
}
PS1='\u@\h:$(shorten_path)\$ '

# ---- Python venv auto-activate ----------------------------------------------
auto_activate_venv() {
  local d
  for d in .venv venv; do
    if [[ -f "$PWD/$d/bin/activate" ]]; then
      [[ "$VIRTUAL_ENV" == "$PWD/$d" ]] || . "$PWD/$d/bin/activate"
      return
    fi
  done
  if [[ -n "$VIRTUAL_ENV" ]] && [[ "$PWD" != "${VIRTUAL_ENV%/*}"* ]]; then
    declare -f deactivate >/dev/null 2>&1 && deactivate 2>/dev/null
  fi
}

_auto_activate_venv_hook() {
  [[ "$PWD" == "$_LAST_HOOK_PWD" ]] && return
  _LAST_HOOK_PWD="$PWD"
  auto_activate_venv
}

PROMPT_COMMAND="_bash_history_sync; _auto_activate_venv_hook${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ---- Keybinds ----------------------------------------------------------------
__alt_c_fzf_cd() {
  local dir
  if declare -f __fzfcmd >/dev/null 2>&1 && declare -f __fzf_defaults >/dev/null 2>&1; then
    dir=$(
      FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
      FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)
    ) || return
  else
    return
  fi
  [[ -n "$dir" ]] && builtin cd -- "$dir"
}

bind -x '"\C-y\C-p":copy-pwd' 2>/dev/null || true
if declare -f __fzf_select__ >/dev/null 2>&1; then bind -m emacs-standard '"\C-i": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\C-\e(\C-a\C-y\C-h\e \C-y\ey\C-x\C-x\C-f\C-y\ey\C-_"' 2>/dev/null || true; fi
bind -r '\ec' 2>/dev/null || true
bind -x '"\ec":__alt_c_fzf_cd' 2>/dev/null || true

# ---- macOS-only helpers -----------------------------------------------------
if (( is_macos )); then
  alias eghostty='$EDITOR ~/.config/ghostty/config'
  alias ehammer='$EDITOR ~/.hammerspoon/init.lua'
fi

if (( is_macos )) && [[ -n "$GHOSTTY_RESOURCES_DIR" ]] && [[ -z "$TMUX" ]] && \
   [[ -f "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration" ]]; then
  . "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration"
fi

dir-icons() {
  if ! (( is_macos )) || [[ ! -x /opt/homebrew/bin/fileicon ]]; then
    echo "dir-icons requires macOS + fileicon (/opt/homebrew/bin/fileicon)." >&2
    return 1
  fi
  [[ -n "$1" ]] || { echo "Usage: dir-icons /path/to/icon.png"; return 1; }
  find . -maxdepth 1 -type d -not -name '.' -not -name '.*' -print0 |
    while IFS= read -r -d '' dir; do
      /opt/homebrew/bin/fileicon set "$dir" "$1"
    done
}

# ---- Machine-specific overrides ----------------------------------------------
[[ -f "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"
