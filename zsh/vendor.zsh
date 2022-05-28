# bootstrap znap
ZNAP_HOME="$HOME/.zsh-snap"

[[ -f $ZNAP_HOME/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git "$ZNAP_HOME"

# custom repos locatoin
zstyle ':znap:*' repos-dir "$ZNAP_HOME/repos"

# start znap
source "$ZNAP_HOME/znap.zsh"

# prompt
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# plugins
znap source ohmyzsh/ohmyzsh plugins/zoxide
znap source zsh-users/zsh-syntax-highlighting

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[alias]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=208,bold'
ZSH_HIGHLIGHT_STYLES[isearch]='fg=51,underline,bold'
zle_highlight=(isearch:$ZSH_HIGHLIGHT_STYLES[isearch])

# emacs + vterm integration (jump between prompts with C-c C-n and C-c C-p)
vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(hostname):$PWD";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
