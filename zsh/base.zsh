# appearance
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# history
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt extended_history         # save each command's beginning timestamp and the duration to the history file
setopt hist_expire_dups_first   # allow dups, but expire old ones when I hit HISTSIZE
setopt hist_ignore_dups         # ignore duplication command history list
setopt hist_ignore_space        # ignore entry when first character on the line is a space
setopt hist_verify              # don't execute immediately upon history expansion
setopt inc_append_history       # write to the history file immediately, not when the shell exits
setopt share_history            # share command history data

# key bindings
bindkey -e

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line                             # edit command line in $EDITOR

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search                   # match back-history with typed chars
bindkey "^p" up-line-or-beginning-search                     # match forward-history with typed chars

bindkey '^r' history-incremental-pattern-search-backward     # allow wildcards in bck-i-search

unsetopt flowcontrol                                         # allows rebinding of ^s
bindkey '^s' history-incremental-pattern-search-forward

zmodload zsh/complist                                        # manually load completion module
bindkey -M menuselect '^[[z' reverse-menu-complete           # enable shift-tab in completion menu

bindkey '^u' kill-region

# variables
export EDITOR='vim'
export GREP_OPTIONS='--color=auto'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESS='-R'
export TERM='xterm-256color'
export PATH="$HOME/.bin:$PATH"
export PATH="/usr/local/bin:$PATH"

if [[ "$(uname)" = 'Darwin' ]]; then
  export TOMCAT_HOME="/usr/local/opt/tomcat/libexec"
fi

# aliases
alias h='history | grep -i'
alias vi='vim'

ls=$(gls >/dev/null 2>&1 && echo 'gls' || echo 'ls')
alias l="$ls -l -h --color=auto --group-directories-first"
alias la='l -a --color=always | less'
alias ll="l --color=always | less"

if [[ $(uname) = 'Darwin' ]]; then
  alias tree='tree -C'
fi

if [[ $(uname) = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
