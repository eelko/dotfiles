#!/usr/bin/env bash

# Update submodules
git submodule foreach git pull origin master
git pull --rebase

# Update Python client to Neovim
which pip2 >/dev/null && pip2 install --upgrade pynvim
which pip3 >/dev/null && pip3 install --upgrade pynvim

# Update Neovim plugins
$EDITOR +PlugUpgrade +PlugUpdate +CocUpdateSync +qall

# Update Tmux plugins
~/.tmux/plugins/tpm/bin/update_plugins all
