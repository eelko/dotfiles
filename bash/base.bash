# general options
stty -ixon # disable flow control
complete -d cd # cd tab completion only completes directories

# history
HISTFILESIZE=1000000 # allow a larger history file
HISTSIZE=1000000 # allow a larger history file
HISTCONTROL=ignoreboth:erasedups
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r" # preserve bash history in multiple terminal windows
shopt -s histappend # append history instead of rewriting it
shopt -s cmdhist # use one command per line
shopt -s globstar # enable double asterisk glob
