#!/usr/bin/env bash

init_script="$HOME/.fzf.${SHELL##*/}"

if [[ -s "$init_script" ]]; then
  source "$init_script"
else
  echo "Unable to source \"$init_script\" at $0. Please make sure FZF is installed." && return
fi

export FZF_DEFAULT_COMMAND='(git ls-tree -r --name-only HEAD || rg --files --no-ignore --hidden --follow) 2> /dev/null'
export FZF_DEFAULT_OPTS="--multi --tiebreak=end --bind  'alt-a:select-all,alt-d:kill-word,alt-t:toggle-all,ctrl-j:accept,ctrl-k:kill-line,ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history' --color=${TERM_BACKGROUND:-dark} --history=$HOME/.fzf_history"

export FZF_ALT_C_COMMAND='(git ls-tree -d -r --name-only HEAD || fd --type d) 2> /dev/null'
export FZF_ALT_C_OPTS='--preview "tree -C {} | head -200"'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always {} | head -200"'

# fs - git commit browser
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fs() {
  is_in_git_repo || return
  git log --graph --date=short --format="%C(green)%cd %C(yellow)%h%C(red)%d %C(reset)%s %C(cyan)(%an)" |
  fzf --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always ' |
  grep -o "[a-f0-9]\{7,\}"
}

# fstash - git stash browser
fstash() {
  is_in_git_repo || return
  git stash list --pretty="%C(yellow)%gd %>(14)%Cgreen%cr %C(blue)%gs" |
  fzf --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "^stash@{.}" <<< {} | xargs git stash show -p --color=always ' |
  echo $(grep -o "^stash@{.}") | xargs git stash pop
}
