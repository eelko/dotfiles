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
