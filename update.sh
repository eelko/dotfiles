#!/usr/bin/env bash

set -o nounset
set -o errexit

# Git submodules
git submodule foreach git pull origin master
git pull --rebase

# Python client to Neovim
which pip2 >/dev/null && pip2 install --upgrade pynvim
which pip3 >/dev/null && pip3 install --upgrade pynvim

# Homebrew dependencies
(brew update && brew bundle) || true

# Tmux plugins
~/.tmux/plugins/tpm/bin/update_plugins all

# Neovim plugins
nvim -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
