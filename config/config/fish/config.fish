if status is-interactive
  # Commands to run in interactive sessions can go here
end

# env
set --export EDITOR 'hx'
set --export LESS '-+F' # disable the 'quit-if-one-screen' behavior for all git commands
set --export MANPAGER 'nvim -c "Man!" -o -'
set --export SHELL '/usr/local/bin/fish'
set --export TERM 'wezterm' # enable undercurl support on Neovim under Wezterm

# path
fish_add_path ./node_modules/.bin
fish_add_path /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin # launch VS Code from cli
fish_add_path /usr/local/sbin # Homebrew path
fish_add_path ~/.bin
fish_add_path ~/.dotfiles/node_modules/.bin

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
alias e "$EDITOR"

alias ls 'lsd'
alias l  'ls -l --group-dirs=first --date relative'
alias la 'l -a'
alias lt 'l --tree --depth 1'

alias p switch_project

# binds
bind \cn    history-prefix-search-forward
bind \cp    history-prefix-search-backward
bind \cx\ce edit_command_buffer
bind \cg    fzf_append_live_grep_to_prompt
bind \co    fzf_append_mru_to_prompt

# colors
source "$HOME/.LS_COLORS/lscolors.csh" # better ls colors

# fzf
set --export FZF_DEFAULT_OPTS '--multi'
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --bind 'alt-a:select-all,alt-d:kill-word,alt-t:toggle-all,ctrl-j:accept,ctrl-k:kill-line,ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history'"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --height=50%"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --history=$HOME/.fzf_history"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --layout=reverse"
set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --tiebreak=end"

# PatrickF1/fzf.fish
fzf_configure_bindings --directory=\ct --git_status=\cs
set fzf_fd_opts --hidden --exclude=.git
set fzf_history_opts --preview-window=up:3:wrap

# list directory contents after cd
function list_after_cd_on_variable_pwd --on-variable PWD
  l
end

# prompt
function set_cursor_to_underscore --on-event fish_postexec
  printf "\e[4 q"
end

starship init fish | source

# enable WezTerm shell integration
source ~/.config/fish/shell-integration.fish

# load local configs
set LOCAL_CONFIG "$HOME/.local.config.fish"
if test -e "$LOCAL_CONFIG"
  source $LOCAL_CONFIG
end

# vim: set commentstring=#%s :
