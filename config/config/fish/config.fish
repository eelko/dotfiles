if status is-interactive
  # Commands to run in interactive sessions can go here
end

# env
set --export EDITOR 'nvim'
set --export MANPAGER 'nvim -c "Man!" -o -'
set --export PATH "$HOME/.bin:$PATH"
set --export PATH "$HOME/.dotfiles/node_modules/.bin:$PATH"
set --export PATH "./node_modules/.bin:$PATH"

# abbreviations
abbr -a c 'cat'

abbr -a g   'git'
abbr -a ga  'git add'
abbr -a gcb 'git checkout -b'
abbr -a gci 'git commit -v'
abbr -a gco 'git checkout'
abbr -a gdc 'git diff --cached'
abbr -a gdf 'git diff'
abbr -a gl  'git lg'
abbr -a gmt 'git mergetool'
abbr -a gr  'git rebase'
abbr -a grv 'git remote -v'
abbr -a gst 'git status -sb'
abbr -a gwc 'git whatchanged -1'

# aliases
alias e  "$EDITOR"

alias ls 'lsd'
alias l  'ls -l --group-dirs=first --date relative'
alias la 'l -a'
alias lt 'l --tree --depth 1'

# binds
bind \cx\ce edit_command_buffer

# colors
source "$HOME/.LS_COLORS/lscolors.csh" # better ls colors

# fzf
set --export FZF_DEFAULT_OPTS '--multi'
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --bind 'alt-a:select-all,alt-d:kill-word,alt-t:toggle-all,ctrl-j:accept,ctrl-k:kill-line,ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history'"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --history=$HOME/.fzf_history"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --layout=reverse"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --tiebreak=end"

set fzf_history_opts '--preview-window=up:3:wrap'

fzf_configure_bindings --directory=\ct --git_log=\cg --git_status=\cs

function fzf --wraps=fzf --description="Use fzf-tmux if in tmux session"
  if set --query TMUX
    fzf-tmux $argv
  else
    command fzf $argv
  end
end

# utilities
function cd --wraps=cd --description="List directory contents after cd"
  builtin cd $argv && l
end

# prompt
starship init fish | source

# vim: set commentstring=#%s :