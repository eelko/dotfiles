#!/usr/bin/env bash

set -o nounset
set -o errexit

DOTFILES_HOME="$HOME/.dotfiles"

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# System dependencies
# shellcheck disable=SC2046
brew install $(paste -sd ' ' - < ./DEPENDENCIES.brew)
# shellcheck disable=SC2046
brew cask install $(paste -sd ' ' - < ./DEPENDENCIES.cask)

# Init git submodules
git submodule update --init --recursive
git submodule foreach git pull origin master

# Tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins

# Symlink config files
# shellcheck disable=SC2086
find $DOTFILES_HOME/config/* -maxdepth 0 -exec bash -c 'ln -snv $1 ~/.$(basename $1)' _ {} \;