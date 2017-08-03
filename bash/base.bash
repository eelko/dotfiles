# general options
stty -ixon # disable flow control
complete -d cd # cd tab completion only completes directories

# history
HISTFILESIZE=1000000 # allow a larger history file
HISTSIZE=1000000 # allow a larger history file
HISTCONTROL=ignoreboth:erasedups
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r" # preserve bash history in multiple terminal windows
shopt -s histappend # append history instead of rewriting it
shopt -s cmdhist # use one command per line
shopt -s globstar # enable double asterisk glob

# variables
export EDITOR='vim'
export GREP_OPTIONS='--color=auto'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESS='-R'
export TERM='xterm-256color'
export PATH="$HOME/.bin:$PATH"

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
