export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'zsh-users/zsh-syntax-highlighting', defer:2
zplug 'zplug/zplug', hook-build: 'zplug --self-manage'

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

# syntax highlighting
ZSH_HIGHLIGHT_STYLES[alias]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[isearch]='fg=51,underline,bold'
zle_highlight=(isearch:$ZSH_HIGHLIGHT_STYLES[isearch])

# Emacs + vterm integration (jump between prompts with C-c C-n and C-c C-p)
vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(hostname):$PWD";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
