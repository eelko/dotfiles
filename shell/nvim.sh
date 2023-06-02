#!/usr/bin/env bash

# vim context switcher by Elijah Manor
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nc="NVIM_APPNAME=nvim-chad nvim"

function nvims() {
  items=("default" "kickstart" "LazyVim" "nvim-chad" )
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

bindkey -s ^n "nvims\n"

# Switching mechanism for neovim setups (Astronvim vs personal setup) by Eelko
function switchnvim() {
    mv ~/.config/nvim ~/.config/nvim_old
    mv ~/.config/nvim.switch ~/.config/nvim
    mv ~/.config/nvim_old ~/.config/nvim.switch

    mv ~/.local/share/nvim ~/.local/share/nvim_old
    mv ~/.local/share/nvim.switch ~/.local/share/nvim
    mv ~/.local/share/nvim_old ~/.local/share/nvim.switch
}
