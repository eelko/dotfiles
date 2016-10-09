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

function cd() {
  builtin cd "$@" && l
}

function playjs() {
  bin_exists 'node' || load_NVM
  playground="play.$$.js"
  tmux rename-window $playground
  vim -c 'Codi' "/tmp/$playground"
  tmux setw automatic-rename
}

function source_if_exists() {
  local script="$1"
  [[ -s $script ]] && source $script
}

function bin_exists() {
  which "$1" > /dev/null 2>&1
  return $?
}

function shorten() {
  [[ "$#" -eq 0 ]] && echo -e "Usage:\n shorten [--quiet] [URL]" && return
  for arg in $*; do
    [[ "$arg" =~ ^http ]] && long_url="$arg"
    [[ "$arg" =~ ^--[a-z]+ ]] && declare ${arg#--}=true
  done
  short_url=$(curl -Ss "http://api.bitly.com/v3/shorten?login=$BITLY_LOGIN&apiKey=$BITLY_API_KEY&longUrl=$long_url&format=txt") && echo "$short_url" | pbcopy
  [[ -z "$quiet" ]] && echo "\"$short_url\" copied to clipboard." || echo $short_url
}

source "$HOME/.dotfiles/zsh/fzf-functions.zsh"
