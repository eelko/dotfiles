# get arrows indicating if branch is ahead/behind remote (adapted from https://github.com/sindresorhus/pure)
function prompt_git_arrows() {
  # reset git arrows
  prompt_pure_git_arrows=

  # check if there is an upstream configured for this branch
  command git rev-parse --abbrev-ref @'{u}' &>/dev/null || return

  local arrow_status
  # check git left and right arrow_status
  arrow_status="$(command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)"
  # exit if the command failed
  (( !$? )) || return

  # left and right are tab-separated, split on tab and store as array
  arrow_status=(${arrow_status//\t/ })
  local arrows left=${arrow_status[0]} right=${arrow_status[1]}

  (( ${right:-0} > 0 )) && arrows+="${PURE_GIT_DOWN_ARROW:-⇣}"
  (( ${left:-0} > 0 )) && arrows+="${PURE_GIT_UP_ARROW:-⇡}"

  [[ -n $arrows ]] && prompt_pure_git_arrows=" ${arrows}"
  echo "$prompt_pure_git_arrows"
}

# get current branch in git repo
function parse_git_branch() {
  local branch_name=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

  [[ ! -z "$branch_name" ]] && echo -e "$branch_name$(prompt_git_dirty) \e[36m$(prompt_git_arrows)" || echo ""
}

# fastest possible way to check if repo is dirty (from https://github.com/sindresorhus/pure)
# PURE_GIT_UNTRACKED_DIRTY will skip untracked files in dirtiness check (only useful on extremely huge repos)
prompt_git_dirty() {
  local untracked_dirty="${PURE_GIT_UNTRACKED_DIRTY:-1}"

  if [[ "$untracked_dirty" == "0" ]]; then
    command git diff --no-ext-diff --quiet --exit-code
  else
    test -z "$(command git status --porcelain --ignore-submodules -unormal)"
  fi

  (( $? )) && echo "*"
}

function prompt_current_dir() {
  echo "\[\e[34m\]\w\[\e[m\]"
}

function prompt_git_branch() {
  echo "\e[38;5;243m\`parse_git_branch\`\e[0m"
}

function prompt_current_time() {
  echo "\e[38;5;247m\t\e[0m"
}

function prompt_arrow() {
  echo "\[\e[35m\]❯\[\e[m\]"
}

export PS1="\n$(prompt_current_dir) $(prompt_git_branch)\n$(prompt_arrow) "
