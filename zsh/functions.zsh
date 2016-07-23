function status_msg() {
  printf "\033[1;34m:\033[0m\033[1;37m %s\033[0m\n" "$1"
}

function error_msg() {
  printf "\033[1;31m\xe2\x9c\x98 %s\033[0m\n" "$1"
}

function ok_msg() {
  printf "\033[1;32m\xe2\x9c\x93 %s\033[0m\n" "$1"
}

function warn_msg() {
  printf "\033[1;33m%s\033[0m\n" "$1"
}

function fd() {
  local dir
  dir=$(find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf-tmux +m) &&
  cd "$dir"
}

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

function ff() {
  local file=$(find ${1:-*} -path '*/\.*' -prune -o -type f -print 2> /dev/null | fzf-tmux) &&
  echo "\"$file\" copied to clipboard."
  echo $file | tr -d "\n" | pbcopy
}

function fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

function flac2mp3() {
  for f in **/*.flac
    do ffmpeg -i "$f" -ab 320k -map_metadata 0 -id3v2_version 3 "${f[@]/%flac/mp3}"
  done
}

function m4a2mp3() {
  for f in **/*.m4a
    do ffmpeg -i "$f" -codec:v copy -codec:a libmp3lame -q:a 2 "${f%.m4a}.mp3"
  done
}

function mp3split() {
  input=$1
  start=$2
  end=$3
  output="${input%.mp3}_${start//:/}_${end//:/}.mp3"
  ffmpeg -i $input -vn -acodec copy -ss $start -t $end $output
}

function setjava() {
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.$1)
  echo "JAVA_HOME=$JAVA_HOME"
  java -version
}

# function cd() {
#   if [[ -z $* ]]; then
#     builtin cd && l
#   else
#     builtin cd "$*" && l
#   fi
# }

function playjs() {
  local playground="play.$$.js"
  tmux rename-window $playground
  tmux send-keys "vim /tmp/$playground" 'C-m'
  tmux split-window -h 'node'
  tmux last-pane
}

function source_if_exists() {
  local script="$1"
  [[ -s $script ]] && source $script
}
