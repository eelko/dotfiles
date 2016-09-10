# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fe() {
  local vimopts
  local query
  local result

  if [[ "$@" =~ (-[A-Za-z]) ]]; then
    vimopts=${BASH_REMATCH[1]}
    query=$(echo "${@%*$vimopts*}" | tr -d ' ')
  else
    query=$(echo "$@" | tr -d ' ')
  fi

  result=($(fzf-tmux --query="$query" --multi --select-1 --exit-0))

  [ -n "$result" ] && ${EDITOR:-vim} $result $vimopts
}

# fv - open recent files using fasd
function fv() {
  local file
  file="$(fasd -Rfl "$1" | fzf-tmux -1 -0 --no-sort +m)" && $EDITOR "${file}" || return 1
}

# ff - copy file path to clipboard
function ff() {
  local query
  local file

  if [[ "$@" =~ (-[A-Za-z]) ]]; then
    vimopts=${BASH_REMATCH[1]}
    query=$(echo "${@%*$vimopts*}" | tr -d ' ')
  else
    query=$(echo "$@" | tr -d ' ')
  fi

  file=$(fzf-tmux --query="$query" --select-1 --exit-0)

  if [[ -n "$file" ]]; then
    echo "\"$file\" copied to clipboard."
    echo $file | tr -d "\n" | pbcopy
  fi
}

# fd - cd to selected directory
function fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fz - cd recent directories using fasd
function fz() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf-tmux -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

# fh - repeat history
function fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf-tmux +s --tac | sed 's/ *[0-9]* *//')
}

# fl - view file with less
function fl() {
  local file
  if [[ -e "$1" ]]; then
    less "$1"
  else
    file=$(fzf-tmux --query="$1" --select-1 --exit-0)
    [ -n "$file" ] && less "$file"
  fi
}

function is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

# fs - git commit browser
function fs() {
  is_in_git_repo || return
  git log --graph --date=short --format="%C(green)%cd %C(yellow)%h%C(red)%d %C(reset)%s %C(cyan)(%an)" |
  fzf --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always ' |
  grep -o "[a-f0-9]\{7,\}"
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
function fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
}

# switch tmux pane
function ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -a -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}
