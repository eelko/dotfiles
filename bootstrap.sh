#!/usr/bin/env bash

set -o nounset
set -o errexit

DOTFILES_HOME="$HOME/.dotfiles"

if [[ $PWD != "$DOTFILES_HOME" ]]; then
  echo "Please move this folder to $DOTFILES_HOME and re-run this script."
  exit 1
fi

# Homebrew
if [[ -z "$(command -v brew)" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Homebrew dependencies
brew bundle

# NPM dependencies
npm install

# Init git submodules
git submodule update --init --recursive
git submodule foreach git pull origin master

# Symlink config files
# shellcheck disable=SC2086
find "$DOTFILES_HOME"/config/* -maxdepth 0 -exec bash -c 'ln -snv $1 ~/.$(basename $1)' _ {} \;

# Install FZF key bindings and fuzzy completion (except for Fish Shell)
yes | "$(brew --prefix)"/opt/fzf/install --no-fish --no-update-rc

# Python3 bindings for Vim
python3 -m pip install --user --upgrade pynvim

# Tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins

# Neovim plugins
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Vale styles
wget -qc https://github.com/errata-ai/Microsoft/releases/latest/download/Microsoft.zip -O - | tar -zxv -C /opt/vale-styles/
