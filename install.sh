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
if [[ -d "$DOTFILES_HOME" ]]; then
  echo "Directory $DOTFILES_HOME already exists"
else
  git clone --recursive "$DOTFILES_REPO" "$DOTFILES_HOME"
fi

# symlink dotfiles
find "$DOTFILES_HOME/config/*" -maxdepth 0 -exec bash -c 'ln -snv $1 ~/.$(basename $1)' _ {} \;

# install tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins
