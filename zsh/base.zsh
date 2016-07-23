# appearance
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
RPROMPT="%{$fg[white]%}%*%{$reset_color%}"

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

# completion
zstyle ':completion:*' group-name ''         # group suggestions by type
zstyle ':completion:*' format '%B- %d%b'     # prefix groups with "-"
zstyle ':completion:*' menu select           # enable interactive menu

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # case-insensitive, partial-word and then substring completion

zstyle ':completion::complete:*' use-cache 1 # enable completion cache
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR

# key bindings
bindkey -e

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line                             # edit command line in $EDITOR

bindkey '^n' history-search-forward                          # match back-history with typed chars
bindkey '^p' history-search-backward                         # match forward-history with typed chars
bindkey '^r' history-incremental-pattern-search-backward     # allow wildcards in bck-i-search

unsetopt flowcontrol                                         # allows rebinding of ^s
bindkey '^s' history-incremental-pattern-search-backward

zmodload zsh/complist                                        # manually load completion module
bindkey -M menuselect '^[[z' reverse-menu-complete           # enable shift-tab in completion menu

# aliases
alias h='history | grep -i'
alias vi='vim'

ls=$(gls >/dev/null 2>&1 && echo 'gls' || echo 'ls')
alias ls="$ls -lh --color=always --group-directories-first"
alias l='ls'

if [[ $(uname) = 'Darwin' ]]; then
  alias tree='tree -C'
fi

if [[ $(uname) = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# variables
export EDITOR='vim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL='/bin/zsh'
export TERM='xterm-256color'
export WORDCHARS="" # characters to be considered part of a word. empty forces kill-word to stop at -, /, etc.

export PATH="$HOME/.bin:$PATH"

if [[ "$(uname)" = 'Darwin' ]]; then
  export TOMCAT_HOME=$(brew --prefix tomcat)/libexec
  export PATH="/usr/local/bin:$PATH"
fi
