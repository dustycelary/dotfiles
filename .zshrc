# checking linked file


# =============================================================================
#  ~/.zshrc
#  Load order is deliberate — zsh reads top to bottom, so things that other
#  parts depend on come first. Section map:
#    1. p10k instant prompt      2. PATH & environment
#    3. version managers         4. oh-my-zsh + plugins
#    5. history & shell options  6. tool integrations
#    7. aliases                  8. functions
#    9. keybindings              10. prompt config
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Powerlevel10k instant prompt — MUST stay at the very top.
#    Anything that prints to the console or needs input (passwords, [y/n])
#    must go ABOVE this block; everything else goes below.
# -----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# 2. PATH & environment
#    Homebrew first, so everything below inherits its bin paths.
# -----------------------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# pipx / user-local binaries
export PATH="$HOME/.local/bin:$PATH"

# Editors & misc env
export EDITOR='nvim'
export VISUAL='nvim'

# export LANG=en_US.UTF-8                   # uncomment if your locale is unset

export PYTHONDONTWRITEBYTECODE=1

# -----------------------------------------------------------------------------
# 3. Version managers  (all sit after Homebrew so PATH is already set up)
# -----------------------------------------------------------------------------
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -----------------------------------------------------------------------------
# 4. oh-my-zsh
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh-syntax-highlighting MUST be the LAST entry; zsh-autosuggestions just before.
# External plugins (one-time `git clone`, see the cheatsheet):
#   zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab, zsh-completions
plugins=(
  git                 # tons of git aliases (gst, gco, gp, glog, ...)
  history             # `h` / history helpers
  fzf                 # Ctrl-T / Ctrl-R / Alt-C fuzzy bindings
  virtualenv          # shows active venv
  jump                # `mark`, `jump`, `marks` bookmarked dirs
  you-should-use      # nags you to use an alias you forgot
  macos               # ofd, pfd, cdf, ql, ...
  colored-man-pages   # colorized man pages
  extract             # `extract file.tar.gz` — any archive, one command
  dirhistory          # Alt + arrows to walk dir history
  copypath            # `copypath` copies $PWD (or a file path) to clipboard
  copyfile            # `copyfile foo.txt` copies file contents to clipboard
  fzf-tab             # EXTERNAL: fzf-powered tab completion
  zsh-completions     # EXTERNAL: extra completion definitions
  zsh-autosuggestions # EXTERNAL: greyed-out suggestion from history
  zsh-syntax-highlighting # EXTERNAL: KEEP LAST
)

source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# 5. History & shell options  (set AFTER omz so these win)
# -----------------------------------------------------------------------------
HISTSIZE=100000              # commands kept in memory
SAVEHIST=100000              # commands written to disk
setopt SHARE_HISTORY         # live-share history across all open shells
setopt HIST_IGNORE_ALL_DUPS  # remove older duplicate when a command repeats
setopt HIST_REDUCE_BLANKS    # trim superfluous whitespace before saving
setopt HIST_VERIFY           # show !! / !$ expansion before running it

setopt AUTO_CD               # type a dir path to cd into it
setopt AUTO_PUSHD            # cd pushes onto the dir stack...
setopt PUSHD_IGNORE_DUPS     # ...without duplicates
setopt PUSHD_SILENT          # ...quietly
setopt INTERACTIVE_COMMENTS  # allow `# comments` when typing commands
setopt EXTENDED_GLOB         # ^, #, ~ glob operators
unsetopt BEEP                # no terminal bell

# Case-insensitive tab completion (tries exact match first, then case-insensitive, allows fuzzy/sub-word matching)
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# -----------------------------------------------------------------------------
# 6. Tool integrations
# -----------------------------------------------------------------------------
# zoxide — smarter cd (must come after oh-my-zsh). `cd` is the jump command;
# bare `cd foo` still works, `cd partial` jumps to best frecency match.
eval "$(zoxide init zsh)"

# fzf — fd-powered file search, skipping noise
export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --color=always {} 2>/dev/null || ls {}'"

# Ghostty shell integration — only load when directly inside Ghostty (not tmux).
# GHOSTTY_RESOURCES_DIR is inherited by tmux child processes, so we must also
# check -z $TMUX. Without tmux allow-passthrough, Ghostty's OSC sequences would
# not be forwarded and can produce display garbage in new panes.
[[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

# -----------------------------------------------------------------------------
# 7. Aliases
# -----------------------------------------------------------------------------
# Config-file editing shortcuts
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias eghostty='nvim ~/.config/ghostty/config'
alias ehammer='nvim ~/.hammerspoon/init.lua'
alias etmux='nvim ~/.tmux.conf'
alias rezsh='source ~/.zshrc'          # reload this file after editing

# Push local clipboard to a remote machine over SSH
alias pbsync='pbpaste | ssh fungus@100.112.31.8 "xclip -selection clipboard"'

# Nerd Font glyph picker -> copies glyph to clipboard
alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'

# Obsidian "beep-boop" vault: jump in and open nvim
alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'

# --- Optional modern CLI replacements (only activate if the tool is present) --
#     Install with: brew install eza bat fd ripgrep
command -v eza  >/dev/null && alias ls='eza --group-directories-first --icons' \
                           && alias ll='eza -la --group-directories-first --icons --git' \
                           && alias lt='eza --tree --level=2 --icons'
command -v bat  >/dev/null && alias cat='bat --paging=never'

# -----------------------------------------------------------------------------
# 8. Functions
# -----------------------------------------------------------------------------
# mkdir + cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# fuzzy-find a file, copy its parent directory to the clipboard
f() {
  local result
  result=$(fd | fzf)
  [[ -n "$result" ]] && dirname "$result" | pbcopy
}

# fuzzy-find a file and open it in nvim
vf() { nvim "$(fd --type f | fzf)"; }

# soft delete: move to a rubbish bin instead of rm (recoverable)
bin() {
  mkdir -p ~/Desktop/rubbish
  mv "$@" ~/Desktop/rubbish/
  echo "Moved to rubbish: $@"
}

# --- Smart Shell Enhancements (Case-Insensitive Typos Correction & Finder) ---

# Smart cd wrapper that automatically corrects spelling typos for local/relative paths
# Integrates with zoxide if available.
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
  fi

  # Otherwise, pass through to let zoxide query database or print directory not found
  if typeset -f __zoxide_z >/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

# Interactive search using ripgrep-all (rga) and fzf
# Works on PDF, DOCX, OCR, and text files.
rga-fzf() {
  if [[ -n "$WIDGET" ]]; then
    zle -I
  fi

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
    
    local ext="${file:e:l}"
    if [[ "$ext" == "pdf" || "$ext" == "docx" || "$ext" == "png" || "$ext" == "jpg" || "$ext" == "jpeg" ]]; then
      open "$file"
    else
      ${EDITOR:-nvim} "$file"
    fi
  fi

  if [[ -n "$WIDGET" ]]; then
    zle redisplay
  fi
}

# -----------------------------------------------------------------------------
# 9. Keybindings & ZLE widgets
# -----------------------------------------------------------------------------
bindkey -r '\el'   # free up Alt-l

# Ctrl-V Ctrl-E : open the current command line in $EDITOR for heavy editing
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^v^e' edit-command-line

# Ctrl-Y Ctrl-P : copy $PWD to clipboard, with a confirmation in the prompt area
copy-pwd() {
  pwd | pbcopy
  zle -M "Copied: $(pwd)"
}
zle -N copy-pwd
bindkey '^y^p' copy-pwd

# Ctrl-G : Interactive in-file search using rga and fzf (works on PDF/DOCX/OCR/text)
zle -N rga-fzf
bindkey '^g' rga-fzf

# Prefix history search: type `git` then up-arrow to cycle only commands
# starting with `git`. Uncomment to enable (can fight autosuggestions).
# bindkey '^[[A' history-beginning-search-backward
# bindkey '^[[B' history-beginning-search-forward

# -----------------------------------------------------------------------------
# 10. Powerlevel10k user config
# -----------------------------------------------------------------------------
# To re-run the wizard: p10k configure   (edits ~/.p10k.zsh)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# =============================================================================
#  PARKED / DISABLED  — kept verbatim so you don't lose the work.
# =============================================================================

# --- Auto-activate/deactivate Python venvs on cd -----------------------------
# auto_venv() {
#   if [[ -z "$VIRTUAL_ENV" ]]; then
#     if [[ -d .venv ]]; then
#       source .venv/bin/activate
#     elif [[ -d venv ]]; then
#       source venv/bin/activate
#     fi
#   else
#     local venv_parent="${VIRTUAL_ENV:h}"
#     if [[ "$PWD" != "$venv_parent"* ]]; then
#       if typeset -f deactivate > /dev/null; then
#         deactivate
#       fi
#     fi
#   fi
# }
# autoload -U add-zsh-hook
# add-zsh-hook chpwd auto_venv
# auto_venv

# --- Keep the prompt N rows above the bottom of the pane ----------------------
# _keep_bottom_rows_query() {
#   local stty_save pos
#   stty_save=$(stty -g </dev/tty 2>/dev/null) || return 1
#   stty raw -echo min 0 time 10 </dev/tty 2>/dev/null
#   printf '\e[6n' >/dev/tty
#   IFS= read -r -d 'R' pos </dev/tty 2>/dev/null
#   stty "$stty_save" </dev/tty 2>/dev/null
#   pos=${pos#*$'\e['}
#   REPLY=${pos%;*}
#   [[ "$REPLY" == <-> ]]
# }
# _keep_bottom_rows_apply() {
#   local rows=$1 row=$2
#   local target=$(( LINES - rows ))
#   (( row > target )) || return
#   local scroll=$(( row - target ))
#   printf '\e[%d;1H' "$LINES"
#   repeat $scroll; do print; done
#   printf '\e[%dA' "$rows"
# }
# _ghostty_precmd_keep_bottom_rows() {
#   [[ -z "$TMUX" ]] || return
#   [[ "$TERM_PROGRAM" == "ghostty" || "$TERM" == *ghostty* ]] || return
#   [[ -o interactive ]] || return
#   if [[ -z "$_GHOSTTY_MARGIN_READY" ]]; then
#     _GHOSTTY_MARGIN_READY=1
#     return
#   fi
#   local rows=${GHOSTTY_BOTTOM_MARGIN_ROWS:-10}
#   (( rows >= 0 )) || return
#   _keep_bottom_rows_query || return
#   _keep_bottom_rows_apply "$rows" "$REPLY"
# }
# _tmux_precmd_keep_bottom_rows() {
#   [[ -n "$TMUX" ]] || return
#   [[ -o interactive ]] || return
#   if [[ -z "$_TMUX_MARGIN_READY" ]]; then
#     _TMUX_MARGIN_READY=1
#     return
#   fi
#   local rows=${TMUX_BOTTOM_MARGIN_ROWS:-10}
#   (( rows >= 0 )) || return
#   _keep_bottom_rows_query || return
#   _keep_bottom_rows_apply "$rows" "$REPLY"
# }
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd _ghostty_precmd_keep_bottom_rows
# add-zsh-hook precmd _tmux_precmd_keep_bottom_rows
