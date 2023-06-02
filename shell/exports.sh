#!/usr/bin/env bash

export EDITOR='nvim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESS='-R'
export PATH="$HOME/.bin:$PATH"
# export PATH="./node_modules/.bin:$PATH"
# export PATH="$HOME/.dotfiles/node_modules/.bin:$PATH"
export MANPAGER="nvim -c 'Man!' -o -"
export CC='/usr/bin/gcc'

if [[ $(uname) = 'Darwin' ]]; then
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

