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
local -r unwanted_segments=(package)
local -r prompt_order=${SPACESHIP_PROMPT_ORDER[@]/$unwanted_segments}
export SPACESHIP_PROMPT_ORDER=($(echo $prompt_order))

local -r magenta='#FF5F87'
local -r green='#A8DE70'
local -r yellow='#FFD95C'
local -r orange='#FE9861'
local -r purple='#AB9BF5'
local -r cyan='#74DCE9'
export SPACESHIP_DIR_COLOR=$purple
export SPACESHIP_CHAR_SUFFIX=' '
export SPACESHIP_GIT_BRANCH_COLOR=$magenta
export SPACESHIP_GIT_STATUS_PREFIX=' '
export SPACESHIP_GIT_STATUS_SUFFIX=''
export SPACESHIP_GIT_STATUS_COLOR=$orange
export SPACESHIP_NODE_PREFIX='using '
export SPACESHIP_NODE_COLOR=$green
