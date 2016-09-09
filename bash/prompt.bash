function prompt_pure_check_git_arrows() {
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
  echo $prompt_pure_git_arrows
}

# get current branch in git repo
function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    ARROWS=`prompt_pure_check_git_arrows`
    echo -e "${BRANCH}${STAT} \e[36m${ARROWS}"
  else
    echo ""
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [[ "${dirty}" == "0" || "${untracked}" == "0" || "${newfile}" == "0" || "${renamed}" == "0" || "${deleted}" == "0" ]]; then
    bits="*${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo "${bits}"
  else
    echo ""
  fi
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
