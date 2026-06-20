# =============================================================================
#  ~/.bashrc_test
#  Load order is deliberate — bash reads top to bottom, so things that other
#  parts depend on come first. Section map:
#    1. [DISABLED] p10k prompt   2. PATH & environment
#    3. version managers         4. [DISABLED] oh-my-zsh + plugins
#    5. history & shell options  6. tool integrations
#    7. aliases                  8. functions
#    9. keybindings              10. [DISABLED] prompt config
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Powerlevel10k instant prompt — DISABLED (Zsh-specific)
# -----------------------------------------------------------------------------
# Powerlevel10k is Zsh-specific and does not run in Bash.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh"
# fi

# -----------------------------------------------------------------------------

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
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -----------------------------------------------------------------------------
# 4. oh-my-zsh — DISABLED (Zsh-specific)
# -----------------------------------------------------------------------------
# Oh My Zsh is Zsh-specific and cannot be loaded in Bash.
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_DISABLE_COMPFIX=true
# ZSH_THEME="powerlevel10k/powerlevel10k"
# plugins=( ... )
# source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# 5. History & shell options  (set for Bash)
# -----------------------------------------------------------------------------
HISTSIZE=100000              # commands kept in memory
HISTFILESIZE=100000          # commands written to disk

# Share history between bash sessions: append on every command, re-read
shopt -s histappend

# Safe helper function to sync history
_bash_history_sync() {
  history -a
  history -n
}

# Clean up any legacy/broken inline history commands and double semicolons from previous sourcing attempts
if [[ -n "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="${PROMPT_COMMAND//history -a; history -n/}"
  PROMPT_COMMAND=$(echo "$PROMPT_COMMAND" | tr -s ';' | sed -e 's/;[[:space:]];/;/g' -e 's/^[[:space:];]*//' -e 's/[[:space:];]*$//')
fi

# Add history sync to PROMPT_COMMAND without causing syntax errors
if [[ -z "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="_bash_history_sync"
elif [[ "$PROMPT_COMMAND" != *"_bash_history_sync"* ]]; then
  # Remove trailing semicolons and whitespace from existing PROMPT_COMMAND
  PROMPT_COMMAND="${PROMPT_COMMAND%;}"
  PROMPT_COMMAND="${PROMPT_COMMAND%"${PROMPT_COMMAND##*[![:space:]]}"}"
  PROMPT_COMMAND="${PROMPT_COMMAND%;}"
  PROMPT_COMMAND="_bash_history_sync; $PROMPT_COMMAND"
fi

# Avoid duplicate entries and spaces in history
export HISTCONTROL=ignoreboth:erasedups

# Show history expansion (like !!) before running it
shopt -s histverify

# Autocd: type a dir path to cd into it
shopt -s autocd 2>/dev/null || true

# Autopushd: cd pushes onto the dir stack
shopt -s autopushd 2>/dev/null || true

# Allow `# comments` when typing commands in interactive shell
shopt -s interactive_comments

# Extended glob patterns
shopt -s extglob

# Disable terminal beep
bind 'set bell-style none' 2>/dev/null

# Case-insensitive tab completion in Bash (Readline)
bind 'set completion-ignore-case on' 2>/dev/null
# Show matches immediately
bind 'set show-all-if-ambiguous on' 2>/dev/null

# -----------------------------------------------------------------------------
# 6. Tool integrations
# -----------------------------------------------------------------------------
# zoxide — smarter cd (must come after oh-my-zsh). `cd` is the jump command;
# bare `cd foo` still works, `cd partial` jumps to best frecency match.
eval "$(zoxide init --cmd cd bash)"

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
# [[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
#   source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration"

# -----------------------------------------------------------------------------
# 7. Aliases
# -----------------------------------------------------------------------------
# Config-file editing shortcuts
alias ebash='nvim ~/.bashrc_test'
alias envim='nvim ~/.config/nvim/init.lua'
alias eghostty='nvim ~/.config/ghostty/config'
alias ehammer='nvim ~/.hammerspoon/init.lua'
alias etmux='nvim ~/.tmux.conf'
alias rebash='source ~/.bashrc_test'          # reload this file after editing

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
  # (Builtin cd will also use cdspell in Bash if shopt -s cdspell is set)
  if declare -f __zoxide_z >/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

# Interactive search using ripgrep-all (rga) and fzf
# Works on PDF, DOCX, OCR, and text files.
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
      open "$file"
    else
      ${EDITOR:-nvim} "$file"
    fi
  fi
}

# -----------------------------------------------------------------------------
# 9. Keybindings & Readline bindings
# -----------------------------------------------------------------------------
bind -r '\el' 2>/dev/null || true   # free up Alt-l in Readline

# Ctrl-V Ctrl-E : open the current command line in $EDITOR for heavy editing
bind '"\C-v\C-e": edit-and-execute-command' 2>/dev/null || true

# Ctrl-Y Ctrl-P : copy $PWD to clipboard
copy-pwd() {
  pwd | pbcopy
  echo "Copied: $(pwd)"
}
bind -x '"\C-y\C-p": copy-pwd' 2>/dev/null || true

# Ctrl-G : Interactive in-file search using rga and fzf (works on PDF/DOCX/OCR/text)
bind -x '"\C-g": rga-fzf' 2>/dev/null || true

# -----------------------------------------------------------------------------
# 10. Powerlevel10k user config — DISABLED (Zsh-specific)
# -----------------------------------------------------------------------------
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# =============================================================================
#  PARKED / DISABLED  — kept verbatim and adapted for Bash.
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
#     local venv_parent
#     venv_parent=$(dirname "$VIRTUAL_ENV")
#     if [[ "$PWD" != "$venv_parent"* ]]; then
#       if declare -f deactivate > /dev/null; then
#         deactivate
#       fi
#     fi
#   fi
# }
# # In Bash, we run this via PROMPT_COMMAND instead of chpwd hook:
# # PROMPT_COMMAND="auto_venv; $PROMPT_COMMAND"

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
#   [[ "$REPLY" =~ ^[0-9]+$ ]]
# }
# _keep_bottom_rows_apply() {
#   local rows=$1 row=$2
#   local target=$(( LINES - rows ))
#   (( row > target )) || return
#   local scroll=$(( row - target ))
#   printf '\e[%d;1H' "$LINES"
#   for ((i=0; i<scroll; i++)); do echo; done
#   printf '\e[%dA' "$rows"
# }
# _ghostty_precmd_keep_bottom_rows() {
#   [[ -z "$TMUX" ]] || return
#   [[ "$TERM_PROGRAM" == "ghostty" || "$TERM" == *ghostty* ]] || return
#   [[ $- == *i* ]] || return
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
#   [[ $- == *i* ]] || return
#   if [[ -z "$_TMUX_MARGIN_READY" ]]; then
#     _TMUX_MARGIN_READY=1
#     return
#   fi
#   local rows=${TMUX_BOTTOM_MARGIN_ROWS:-10}
#   (( rows >= 0 )) || return
#   _keep_bottom_rows_query || return
#   _keep_bottom_rows_apply "$rows" "$REPLY"
# }
# # In Bash, we hook these into PROMPT_COMMAND instead of using add-zsh-hook precmd:
# # PROMPT_COMMAND="_ghostty_precmd_keep_bottom_rows; _tmux_precmd_keep_bottom_rows; $PROMPT_COMMAND"
