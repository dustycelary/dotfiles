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
  colored-man-pages extract dirhistory copypath copyfile
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

export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git --exclude venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"
export FZF_ALT_C_COMMAND='{ zoxide query --list 2>/dev/null; fd --type d --follow --exclude .git --exclude venv --exclude node_modules } | awk "!seen[\$0]++"'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --long --time-style=relative --color=always {} 2>/dev/null || ls -la {}'"

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

command -v eza  >/dev/null && alias ls='eza --group-directories-first --icons' \
                           && alias ll='eza -la --group-directories-first --icons --git' \
                           && alias lt='eza --tree --level=2 --icons'
command -v bat  >/dev/null && alias cat='bat --paging=never'

# 8. Essential Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
f() { local res; res=$(fd | fzf); [[ -n "$res" ]] && dirname "$res" | pbcopy; }
vf() { nvim "$(fd --type f | fzf)"; }
bin() { mkdir -p ~/Desktop/rubbish; mv "$@" ~/Desktop/rubbish/; echo "Moved to rubbish: $@"; }

# 9. Powerlevel10k Config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
