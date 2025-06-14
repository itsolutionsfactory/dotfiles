# Path configuration
export PATH=$PATH:$HOME/.local/bin

# Editor configuration
export EDITOR="/usr/bin/vim"

# Plugin configuration
source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh/plugins/zsh-z/zsh-z.plugin.zsh
source $HOME/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source $HOME/.zsh/plugins/zsh-dirhistory/dirhistory.plugin.zsh

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Oh My Posh initialization with Catppuccin theme
eval "$(oh-my-posh init zsh --config $HOME/.poshthemes/catppuccin.omp.json)"

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

# Completion configuration
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{#a6e3a1}%B%d%b%f'

# Key bindings
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CDABLE_VARS
setopt EXTENDED_GLOB

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Directory history aliases
alias d='dirhistory_zle_dirhistory_back'
alias f='dirhistory_zle_dirhistory_future'

# FZF aliases
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias fzfp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}" --preview-window=right:60%'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="$PATH:$HOME/.fzf/bin"
export PATH="$PATH:$HOME/.fzf/bin"
export PATH="$PATH:$HOME/.fzf/bin"
