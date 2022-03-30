#!/usr/bin/env bash

# Get arrows indicating if branch is ahead/behind remote (adapted from https://github.com/sindresorhus/pure)
prompt_git_arrows() {
  # reset git arrows
  prompt_pure_git_arrows=

  # check if there is an upstream configured for this branch
  command git rev-parse --abbrev-ref @'{u}' &> /dev/null || return

  # check if there are commits ahead/behind
  ahead_or_behind="$(command git rev-list --left-right --count HEAD...@'{u}' 2> /dev/null)" # returns something like "1 0"
  ((!$?))   || return # exit if the command failed
  ahead=$(echo "$ahead_or_behind" | awk '{ print $1 }')
  behind=$(echo "$ahead_or_behind" | awk '{ print $2 }')

  # set status arrows
  [[ ${ahead:-0} -gt 0 ]] && prompt_pure_git_arrows+="${PURE_GIT_UP_ARROW:-⇡}"
  [[ ${behind:-0} -gt 0 ]] && prompt_pure_git_arrows+="${PURE_GIT_DOWN_ARROW:-⇣}"

  echo "$prompt_pure_git_arrows"
}

# Fastest possible way to check if repo is dirty (from https://github.com/sindresorhus/pure)
# PURE_GIT_UNTRACKED_DIRTY will skip untracked files in dirtiness check (only useful on extremely huge repos)
prompt_git_dirty() {
  local untracked_dirty="${PURE_GIT_UNTRACKED_DIRTY:-1}"

  if [[ "$untracked_dirty" == "0" ]]; then
    command git diff --no-ext-diff --quiet --exit-code 2> /dev/null
  else
    test "$(command git status --porcelain --ignore-submodules -unormal 2> /dev/null)" = ""
  fi

  (($?))   && echo "*"
}

prompt_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

prompt_current_dir() {
  echo "\[\e[34m\]\w\[\e[m\]"
}

prompt_arrow() {
  echo "\[\e[35m\]❯\[\e[m\]"
}
