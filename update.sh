#!/usr/bin/env bash

set -o nounset
set -o errexit

# Git submodules
git submodule foreach git pull origin master
git pull --rebase

# Python client to Neovim
which pip2 > /dev/null && pip2 install --upgrade pynvim
which pip3 > /dev/null && pip3 install --upgrade pynvim

# Homebrew dependencies
(brew update && brew bundle) || true

# NPM dependencies
npm update

# Tmux plugins
~/.tmux/plugins/tpm/bin/update_plugins all

# Neovim plugins
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Vale styles
wget -qc https://github.com/errata-ai/Microsoft/releases/latest/download/Microsoft.zip -O - | tar -zxv -C /opt/vale-styles/
