# =============================================================================
#  ~/.zshrc
# =============================================================================

# 1. Powerlevel10k instant prompt (Must be at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. PATH & Environment
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
export VISUAL='nvim'
export PYTHONDONTWRITEBYTECODE=1

# 3. Version Managers
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 4. Oh My Zsh & Plugins
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git history fzf virtualenv jump you-should-use macos
  colored-man-pages extract copypath copyfile
  fzf-tab zsh-completions zsh-autosuggestions zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# 5. History & Shell Options
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS EXTENDED_GLOB
unsetopt BEEP
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# 6. Tool Integrations
eval "$(zoxide init zsh)"

# -----------------------------------------
# 1. Standard File Search (Ctrl+T)
# -----------------------------------------
export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"

# -----------------------------------------
# 2. Global Directory Search (Alt+C)
# Uses the built-in fzf-cd-widget
# -----------------------------------------
export FZF_ALT_C_COMMAND='{ zoxide query --list 2>/dev/null; fd --type d --follow --exclude .git --exclude venv --exclude node_modules } | awk "!seen[\$0]++"'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}'"

# -----------------------------------------
# 3. Local Directory Search (Ctrl+G)
# Uses a custom widget to avoid overlapping with Alt+C
# -----------------------------------------
fzf-local-cd-widget() {
    local selected_dir
    
    # Run the local fd search directly into fzf
    selected_dir=$(fd --type d --follow --exclude .git --exclude venv --exclude node_modules . | \
        fzf --height 50% --layout=reverse \
            --prompt="Local Dir> " \
            --preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}')
    
    # If a directory was selected, cd into it
    if [[ -n "$selected_dir" ]]; then
        builtin cd "$selected_dir"
    fi
    
    # Repaint the prompt cleanly
    zle reset-prompt
}

# Register the widget and bind it to Ctrl+G
zle -N fzf-local-cd-widget
bindkey '^g' fzf-local-cd-widget
[[ -n $GHOSTTY_RESOURCES_DIR && -z $TMUX ]] && \
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

# 7. Aliases
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias eghostty='nvim ~/.config/ghostty/config'
alias rezsh='source ~/.zshrc'
alias pbsync='pbpaste | ssh fungus@100.112.31.8 "xclip -selection clipboard"'
alias nf='cat ~/nerdfont.csv | fzf -d "," --with-nth=1,2,3 | awk -F"," "{printf \$3}" | pbcopy'
alias bb='cd "/Users/fungus/Library/Mobile Documents/iCloud~md~obsidian/Documents/beep-boop" && nvim .'
vgr() {
  local id=$(vimgolf list | python3 -c "import sys, random; ids = [line.split('(')[-1].split(')')[0] for line in sys.stdin if '(' in line]; print(random.choice(ids))")
  if [ -z "$id" ]; then
    echo "Error: Could not retrieve a challenge ID."
    return 1
  fi
  local url="https://www.vimgolf.com/challenges/$id"
  echo "$url" | pbcopy
  echo "--------------------------------------------------------"
  echo "🎯 Challenge URL (Copied to Clipboard!):"
  echo "   $url"
  echo "--------------------------------------------------------"
  echo "Press [Enter] to launch Neovim and start the challenge..."
  read -r
  vimgolf put "$id"
}



command -v eza  >/dev/null && alias ls='eza --group-directories-first --icons' \
                           && alias ll='eza -la --group-directories-first --icons --git' \
                           && alias lt='eza --tree --level=2 --icons'
command -v bat  >/dev/null && alias cat='bat --paging=never'

# 8. Essential Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
f() { local res; res=$(fd | fzf); [[ -n "$res" ]] && dirname "$res" | pbcopy; }
vf() { nvim "$(fd --type f | fzf)"; }
bin() { mkdir -p ~/Desktop/rubbish; mv "$@" ~/Desktop/rubbish/; echo "Moved to rubbish: $@"; }
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

  # Otherwise, pass through to let zoxide query database or print directory not found
  if typeset -f __zoxide_z >/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

# 9. Powerlevel10k Config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
