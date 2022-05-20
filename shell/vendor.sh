#!/usr/bin/env bash

# better color setup for ls
dircolors=$(dircolors >/dev/null 2>&1 && echo 'dircolors' || echo 'gdircolors')
eval "$("$dircolors" -b "$HOME"/.LS_COLORS/LS_COLORS)"

# colorize zsh completion menus
[[ "${SHELL##*/}" == 'zsh' ]] && zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# fnm
eval "$(fnm env)"
export LATEST_NODE_PATH="$HOME/.fnm/aliases/latest/bin/node"

# rvm
rvm_init() {
  source_if_exists "$HOME/.rvm/scripts/rvm"
}

# sdkman
sdkman_init() {
  source_if_exists "$HOME/.sdkman/bin/sdkman-init.sh"
}

# Full Python 3 support
export PATH='/usr/local/opt/python/libexec/bin':$PATH

# Emacs + vterm integration (jump between prompts with C-c C-n and C-c C-p)
vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(hostname):$PWD";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

# zoxide
eval "$(zoxide init "$(basename "$SHELL")")"
