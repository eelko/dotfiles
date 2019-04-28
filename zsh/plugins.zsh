export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'denysdovhan/spaceship-prompt', from:github, use:spaceship.zsh, as:theme
zplug 'zsh-users/zsh-syntax-highlighting', defer:2
zplug 'plugins/fasd', from:oh-my-zsh, defer:3

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

# syntax highlighting
ZSH_HIGHLIGHT_STYLES[alias]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[isearch]='fg=51,underline,bold'
zle_highlight=(isearch:$ZSH_HIGHLIGHT_STYLES[isearch])

# prompt
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  fast_git      # Git section (git_branch + git_status)
  node          # Node.js section
  ruby          # Ruby section
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

local -r magenta='#FF5F87'
local -r green='#A8DE70'
local -r yellow='#FFD95C'
local -r orange='#FE9861'
local -r purple='#AB9BF5'
local -r cyan='#74DCE9'
local -r node_green='#66CC33'
local -r ruby_red='#CB064D'

SPACESHIP_CHAR_SUFFIX=' '
SPACESHIP_DIR_COLOR="$purple"
SPACESHIP_NODE_COLOR="$node_green"
SPACESHIP_NODE_SYMBOL=' '
SPACESHIP_RUBY_COLOR="$ruby_red"
SPACESHIP_RUBY_PREFIX=''
SPACESHIP_RUBY_SYMBOL=' '

# git branch name
SPACESHIP_FAST_GIT_BRANCH_SHOW="${SPACESHIP_FAST_GIT_BRANCH_SHOW=true}"
SPACESHIP_FAST_GIT_BRANCH_PREFIX="${SPACESHIP_FAST_GIT_BRANCH_PREFIX=" "}"
SPACESHIP_FAST_GIT_BRANCH_SUFFIX="${SPACESHIP_FAST_GIT_BRANCH_SUFFIX=""}"
SPACESHIP_FAST_GIT_BRANCH_COLOR="${SPACESHIP_FAST_GIT_BRANCH_COLOR="$magenta"}"

spaceship_fast_git_branch() {
  [[ $SPACESHIP_FAST_GIT_BRANCH_SHOW == false ]] && return

  spaceship::is_git || return

  local -r git_branch="$(prompt_git_branch)"

  [[ -z $git_branch ]] && return

  spaceship::section \
    "$SPACESHIP_FAST_GIT_BRANCH_COLOR" \
    "${SPACESHIP_FAST_GIT_BRANCH_PREFIX}${git_branch}${SPACESHIP_FAST_GIT_BRANCH_SUFFIX}"
}

# git branch status
SPACESHIP_FAST_GIT_STATUS_SHOW="${SPACESHIP_FAST_GIT_STATUS_SHOW=true}"
SPACESHIP_FAST_GIT_STATUS_COLOR="${SPACESHIP_FAST_GIT_STATUS_COLOR="$orange"}"

spaceship_fast_git_status() {
  [[ $SPACESHIP_FAST_GIT_STATUS_SHOW == false ]] && return

  spaceship::is_git || return

  local -r git_status="$(prompt_git_dirty)$(prompt_git_arrows)"

  [[ -z $git_status ]] && return

  spaceship::section \
    "$SPACESHIP_FAST_GIT_STATUS_COLOR" \
    "$git_status"
}

# faster alternative to default git plugin
SPACESHIP_FAST_GIT_SHOW="${SPACESHIP_FAST_GIT_SHOW=true}"
SPACESHIP_FAST_GIT_PREFIX="${SPACESHIP_FAST_GIT_PREFIX="on "}"
SPACESHIP_FAST_GIT_SUFFIX="${SPACESHIP_FAST_GIT_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

spaceship_fast_git() {
  [[ $SPACESHIP_FAST_GIT_SHOW == false ]] && return

  spaceship::is_git || return

  local -r branch_name="$(spaceship_fast_git_branch)"
  [[ -z $branch_name ]] && return
  local -r branch_status="$(spaceship_fast_git_status)"

  local git_info="$branch_name"
  [[ -n $branch_status ]] && git_info+=" $branch_status"

  spaceship::section \
    'white' \
    "$SPACESHIP_GIT_PREFIX" \
    "${git_info}" \
    "$SPACESHIP_GIT_SUFFIX"
}
