#!/usr/bin/env bash

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/eelko/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/eelko/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/eelko/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/eelko/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
