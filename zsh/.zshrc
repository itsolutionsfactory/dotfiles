# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="mocha"
CATPPUCCIN_SHOW_TIME=true

# Which plugins would you like to load?
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z zsh-history-substring-search dirhistory fzf)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Display system information
if command -v hyfetch >/dev/null 2>&1; then
    # Display HyFetch with logo and system info side by side
    hyfetch
else
    echo "Please install hyfetch to see the system information display"
fi

# Path configuration
path=("$HOME/.local/bin" "$HOME/go/bin" $path)

# Editor configuration
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="$(command -v nvim)"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="$(command -v vim)"
fi

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if command -v brew >/dev/null 2>&1 && [ -d "$(brew --prefix fzf 2>/dev/null)/shell" ]; then
    FZF_HOMEBREW_SHELL="$(brew --prefix fzf)/shell"
    [ -f "$FZF_HOMEBREW_SHELL/completion.zsh" ] && source "$FZF_HOMEBREW_SHELL/completion.zsh"
    [ -f "$FZF_HOMEBREW_SHELL/key-bindings.zsh" ] && source "$FZF_HOMEBREW_SHELL/key-bindings.zsh"
    unset FZF_HOMEBREW_SHELL
fi
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Source kubectl configuration if it exists
[ -f ~/.config/kubectl/config.zsh ] && source ~/.config/kubectl/config.zsh

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
if command -v free >/dev/null 2>&1; then
    alias free='free -h'
elif command -v vm_stat >/dev/null 2>&1; then
    alias free='vm_stat'
fi
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
[ -d "$HOME/.fzf/bin" ] && path=("$HOME/.fzf/bin" $path)

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
elif command -v brew >/dev/null 2>&1 && [ -s "$(brew --prefix nvm 2>/dev/null)/nvm.sh" ]; then
    NVM_HOMEBREW_PREFIX="$(brew --prefix nvm)"
    . "$NVM_HOMEBREW_PREFIX/nvm.sh"
    [ -s "$NVM_HOMEBREW_PREFIX/etc/bash_completion.d/nvm" ] && . "$NVM_HOMEBREW_PREFIX/etc/bash_completion.d/nvm"
    unset NVM_HOMEBREW_PREFIX
fi

# Kitty and SSH
# https://wiki.archlinux.org/title/Kitty#Terminal_issues_with_SSH
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# go
for go_path in /usr/local/go/bin /opt/homebrew/opt/go/bin; do
    [ -d "$go_path" ] && path=("$go_path" $path)
done
