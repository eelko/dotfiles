#!/usr/bin/env bash

set -o nounset
set -o errexit

DOTFILES_HOME="$HOME/.dotfiles"

if [[ $(pwd) != "$DOTFILES_HOME" ]]; then
  echo "Please move this folder to ${DOTFILES_HOME} and re-run this script."
  exit 1
fi

# Homebrew
if [[ -z "$(command -v brew)" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Homebrew dependencies
brew bundle

# Init git submodules
git submodule update --init --recursive
git submodule foreach git pull origin master

# Symlink config files
# shellcheck disable=SC2086
find $DOTFILES_HOME/config/* -maxdepth 0 -exec bash -c 'ln -snv $1 ~/.$(basename $1)' _ {} \;

# FZF keybindings
yes | /usr/local/opt/fzf/install --no-update-rc

# Python3 bindings for Vim
python3 -m pip install --user --upgrade pynvim

# Tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins
