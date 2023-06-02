#!/usr/bin/env zsh

# aliases for ls
# if [[ -n "$(command -v lsd)" ]]; then
#   alias l='lsd -l --group-dirs=first --date relative'
# else
#   ls=$(gls > /dev/null 2>&1 && echo 'gls' || echo 'ls')
#   alias l="$ls -l -h --color=auto --group-directories-first"
# fi

if [[ $(uname) = 'Darwin' ]]; then
  alias tree='tree -C'
fi

if [[ $(uname) = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

alias grep='grep --color'
# alias la='l -a --color=always | less'
# alias ll='l --color=always | less'
alias vim='nvim'
alias vi='nvim'
alias gl='git log --oneline --graph --decorate --all'
alias lg='lazygit'
