source ~/.zplug/init.zsh

zplug "plugins/fasd", from:oh-my-zsh

zplug "mafredri/zsh-async"
zplug "sindresorhus/pure"

zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", nice:10

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[alias]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[isearch]='fg=51,underline,bold'
zle_highlight=(isearch:$ZSH_HIGHLIGHT_STYLES[isearch])
