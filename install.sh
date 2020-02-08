#!/bin/bash

set -o nounset
set -o errexit

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
