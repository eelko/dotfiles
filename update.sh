#!/usr/bin/env bash

set -o nounset
set -o errexit

function usage {
  echo "Usage: $0 [--git] [--python] [--homebrew] [--npm] [--neovim] [--fish] [--vale] [--catppuccin] [--all]"
  echo
  echo "Options:"
  echo "  --git         Update Git submodules"
  echo "  --python      Update Python client to Neovim"
  echo "  --homebrew    Update Homebrew dependencies"
  echo "  --npm         Update NPM dependencies"
  echo "  --neovim      Update Neovim plugins"
  echo "  --fish        Update Fish plugins"
  echo "  --vale        Update Vale styles"
  echo "  --catppuccin  Update Catppuccin for Helix"
  echo "  --all         Run all updates"
  exit 1
}

if [ $# -eq 0 ]; then
  usage
fi

function git_submodules {
  echo "Updating Git submodules..."
  git submodule sync
  git submodule update --init --recursive --remote
}

function python_neovim {
  echo "Updating Python client to Neovim..."
  which pip2 >/dev/null && pip2 install --upgrade pynvim
  which pip3 >/dev/null && pip3 install --upgrade pynvim
}

function homebrew {
  echo "Updating Homebrew dependencies..."
  (brew update && brew bundle) || true
}

function npm_update {
  echo "Updating NPM dependencies..."
  npm update
}

function neovim_plugins {
  echo "Updating Neovim plugins..."
  nvim --headless '+Lazy sync' +qa
}

function fish_plugins {
  echo "Updating Fish plugins..."
  fish -c 'fisher update'
}

function vale_styles {
  echo "Updating Vale styles..."
  wget -qc https://github.com/errata-ai/Microsoft/releases/latest/download/Microsoft.zip -O - | tar -zxv -C /opt/vale-styles/
}

function catppuccin_for_helix {
  echo "Updating Catppuccin for Helix..."
  cp -r config/config/helix/catppuccin/themes/default/* config/config/helix/themes/
}

while :; do
  if [ "${1-}" = "" ]; then
    break
  fi

  case $1 in
  --git) git_submodules ;;
  --python) python_neovim ;;
  --homebrew) homebrew ;;
  --npm) npm_update ;;
  --neovim) neovim_plugins ;;
  --fish) fish_plugins ;;
  --vale) vale_styles ;;
  --catppuccin) catppuccin_for_helix ;;
  --all)
    git_submodules
    python_neovim
    homebrew
    npm_update
    neovim_plugins
    fish_plugins
    vale_styles
    catppuccin_for_helix
    ;;
  *) break ;;
  esac
  shift
done
