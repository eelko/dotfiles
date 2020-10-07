#!/usr/bin/env bash

prompt="\n$(prompt_current_dir)"
prompt+=" \e[38;5;243m\`prompt_git_branch\`\e[0m"
prompt+="\e[38;5;243m\`prompt_git_dirty\`\e[0m"
prompt+=" \e[36m\`prompt_git_arrows\`\e[0m"
prompt+="\n$(prompt_arrow) "
prompt+="$(printf '\e[4 q')"

export PS1="$prompt"
