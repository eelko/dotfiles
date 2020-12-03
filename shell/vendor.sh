#!/usr/bin/env bash

# base16 color theme
if [[ "$TERM_BACKGROUND" = 'light' ]]; then
  source_if_exists "$HOME/.config/base16-shell/scripts/base16-gruvbox-light-hard.sh"
elif [[ -z "$TERM_BACKGROUND" || "$TERM_BACKGROUND" = 'dark' ]]; then
  source_if_exists "$HOME/.config/base16-shell/scripts/base16-gruvbox-dark-soft.sh"
fi

# better color setup for ls
dircolors=$(dircolors >/dev/null 2>&1 && echo 'dircolors' || echo 'gdircolors')
eval $($dircolors -b $HOME/.LS_COLORS/LS_COLORS)

# colorize zsh completion menus
[[ "${SHELL##*/}" == 'zsh' ]] && zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# fnm
eval "`fnm env`"
export LATEST_NODE_PATH="$HOME/.fnm/aliases/latest/bin/node"

# rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# sdkman
sdkman_init() {
  init_script="$HOME/.sdkman/bin/sdkman-init.sh"
  [[ -s "$init_script" ]] && source "$init_script" || echo "$init_script is not a script."
}

# Full Python 3 support
export PATH='/usr/local/opt/python/libexec/bin':$PATH

# Emacs + vterm integration (jump between prompts with C-c C-n and C-c C-p)
vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(hostname):$(pwd)";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
