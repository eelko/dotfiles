# environment variables
export EDITOR='nvim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESS='-R'
export TERM='xterm-256color'
export PATH="/usr/local/bin:$HOME/.bin:$PATH"

if [[ "$(uname)" = 'Darwin' ]]; then
  export TOMCAT_HOME="/usr/local/opt/tomcat/libexec"
fi

# aliases
alias grep='grep --color'
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
