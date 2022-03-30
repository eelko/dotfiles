#!/usr/bin/env bash

vterm_printf() {
  # Sources:
  # - http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324
  # - https://github.com/akermu/emacs-libvterm#shell-side-configuration
  if [ "$TMUX" != "" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
    # Tell tmux to pass the escape sequences through
    printf "\ePtmux;\e\e]%s\007\e\\" "$1"
  elif [ "${TERM%%-*}" = "screen" ]; then
    # GNU screen (screen, screen-256color, screen-256color-bce)
    printf "\eP\e]%s\007\e\\" "$1"
  else
    printf "\e]%s\e\\" "$1"
  fi
}

vterm_cmd() {
  local vterm_elisp
  vterm_elisp=""
  while [ $# -gt 0 ]; do
    vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
    shift
  done
  vterm_printf "51;E$vterm_elisp"
}

e() {
  local -r file="$(realpath "$@" 2> /dev/null)"
  if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    vterm_cmd open-file "$file"
  else
    eval emacs "$file"
  fi
}
