#!/bin/bash

set -o nounset
set -o errexit

REQUIREMENTS=("fasd" "fzf" "gdircolors" "rg" "tmux" "tree")
for bin in "${REQUIREMENTS[@]}"
do
  [[ -n $(command -v "$bin") ]] || (echo "Error: $bin is not installed" && exit 1)
done

DOTFILES_REPO="https://github.com/obxhdx/dotfiles"
DOTFILES_HOME="$HOME/.dotfiles"

# clone repo
[ -d "$DOTFILES_HOME" ] && echo "Directory $DOTFILES_HOME already exists" || git clone --recursive "$DOTFILES_REPO" "$DOTFILES_HOME"

# symlink dotfiles
find $DOTFILES_HOME/config/* -maxdepth 0 -exec bash -c 'ln -snv {} ~/.$(basename {})' \;

# install tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins
