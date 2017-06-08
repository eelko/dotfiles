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
  for arg in $*; do
    [[ "$arg" =~ ^--[a-z]+ ]] && declare ${arg#--}=true
  done

  export JAVA_HOME="$(/usr/libexec/java_home -v 1.$1)"
  export PATH="$JAVA_HOME/bin:$PATH"

  if [[ -z "$quiet" ]]; then
    echo "JAVA_HOME=$JAVA_HOME"
    java -version
  fi
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
  short_url=$(curl -Ss "http://api.bitly.com/v3/shorten?login=$BITLY_LOGIN&apiKey=$BITLY_API_KEY&longUrl=$long_url&format=txt" | jq '.data.url' | tr -d '"') && echo "$short_url" | pbcopy
  [[ -z "$quiet" ]] && echo "\"$short_url\" copied to clipboard." || echo $short_url
}

function read_nvmrc() {
  [[ -f "$PWD/.nvmrc" ]] && ( eval "nvm use" || true ) || false
}

function cd() {
  builtin cd "$@" && l
}

function growl() {
  terminal-notifier -activate com.googlecode.iterm2 -title 'iTerm' -subtitle 'Command finished running:' -message "$@"
}

function new_note() {
  title="$(echo $@ | gsed -e 's/\b\(.\)/\u\1/g')"
  marker="$(echo $title | sed -e 's/./=/g')"
  header="$title\r$marker\r\r"

  file_name="$(date +%Y-%m-%d)_$(echo $title | gsed -e 's/\(.*\)/\L\1/' -e 's/\s/-/g')"
  file_path="$NOTES_HOME/$file_name.md"

  tmux rename-window "$title" \
    && [ -f "$file_path" ] && vim "$file_path" || vim "$file_path" -c "normal i$(echo -e $header)" \
    && tmux setw automatic-rename
}

function list_notes() {
  builtin cd $NOTES_HOME
  chosen_note=$(find . -iname "*.md" -type f | sed -e "s/\.\///g" | fzf)
  [ ! -z "$chosen_note" ] && vim "$chosen_note"
  builtin cd - >/dev/null
}

function note() {
  if [[ -z "$1" ]]; then
    list_notes
  else
    new_note "$@"
  fi
}

function lazy_load() {
  load_script_id="$1"
  load_script_path="$2"
  load_triggers="$3"

  load_fn="load_${load_script_id}"
  load_and_run_fn="load_and_run_${load_script_id}"
  triggers_array=($load_triggers)

  for t in "${triggers_array[@]}"
  do
    alias "$t"="$load_and_run_fn \"$t\""
  done

eval "$(cat <<EOF
  function ${load_fn}() {
    bin_name=\$( [ ! -z \$1 ] && echo \$1 || echo "${triggers_array[0]}" )
    if ! bin_exists "\$bin_name"; then
      echo 'Loading $load_script_id...'
      for t in "${triggers_array[@]}"
        do unalias \$t
      done
      source_if_exists "$load_script_path"
      unset -f $load_fn $load_and_run_fn
    fi
  }

  function ${load_and_run_fn}() {
    bin_name=\$1
    $load_fn \$bin_name
    \$bin_name "\${@:2}"
  }
EOF
)"
}

# Codi
# Usage: codi [filetype] [filename]
codi() {
  local syntax="${1:-python}"
  shift
  vim -c \
    "set bt=nofile ls=0 noru nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    Codi $syntax" "$@"
}
