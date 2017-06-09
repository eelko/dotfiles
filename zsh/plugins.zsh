export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "mafredri/zsh-async"
zplug "plugins/fasd", from:oh-my-zsh
zplug "sindresorhus/pure"
zplug "zsh-users/zsh-syntax-highlighting"

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

# zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[alias]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[isearch]='fg=51,underline,bold'
zle_highlight=(isearch:$ZSH_HIGHLIGHT_STYLES[isearch])
