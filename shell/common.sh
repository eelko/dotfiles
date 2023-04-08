#!/usr/bin/env bash

# environment variables
export EDITOR='nvim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESS='-R'
export PATH="$HOME/.bin:$PATH"
export PATH="./node_modules/.bin:$PATH"
export PATH="$HOME/.dotfiles/node_modules/.bin:$PATH"
export MANPAGER="nvim -c 'Man!' -o -"

if [[ $(uname) = 'Darwin' ]]; then
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# aliases
if [[ -n "$(command -v lsd)" ]]; then
  alias l='lsd -l --group-dirs=first --date relative'
else
  ls=$(gls > /dev/null 2>&1 && echo 'gls' || echo 'ls')
  alias l="$ls -l -h --color=auto --group-directories-first"
fi

if [[ $(uname) = 'Darwin' ]]; then
  alias tree='tree -C'
fi

if [[ $(uname) = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

alias grep='grep --color'
alias la='l -a --color=always | less'
alias ll='l --color=always | less'
alias vim='nvim'
