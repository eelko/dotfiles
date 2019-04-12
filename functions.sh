# Convert all .flac files (within directpry) to mp3
function flac2mp3() {
  for f in **/*.flac
    do ffmpeg -i "$f" -ab 320k -map_metadata 0 -id3v2_version 3 "${f[@]/%flac/mp3}"
  done
}

# Convert all .m4a files (within directpry) to mp3
function m4a2mp3() {
  for f in **/*.m4a
    do ffmpeg -i "$f" -codec:v copy -codec:a libmp3lame -q:a 2 "${f%.m4a}.mp3"
  done
}

# Split .mp3 by given start/end time
function mp3split() {
  input=$1
  start=$2
  end=$3
  output="${input%.mp3}_${start//:/}_${end//:/}.mp3"
  ffmpeg -i $input -vn -acodec copy -ss $start -t $end $output
}

# Extract text from pdf
function pdf2txt() {
  for input in "$@"; do
    gs -dBATCH -dNOPAUSE -sDEVICE=txtwrite -sOutputFile="${input//pdf/txt}" "$input"
  done
}

# Extract text from pdf
function pdf2img() {
  local -r input="$1"
  local -r output_format="${2:-jpg}"
  # -flatten option will combine all images into one
  convert -verbose -density 150 -trim "$1" -quality 100 -sharpen 0x1.0 "out.$output_format"
}

# Merge multiple pdf into one
function mergepdf() {
  gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=out.pdf "$1"
}

# Helper to dynamically set a chosen Java version
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

# Source file if it exists
function source_if_exists() {
  local script="$1"
  [[ -s $script ]] && source $script
}

# Helper to check wether a bin exists
function bin_exists() {
  which "$1" > /dev/null 2>&1
  return $?
}

# Create short URLs
# Usage: shorten [full url]
function shorten() {
  [[ "$#" -eq 0 ]] && echo -e "Usage:\n shorten [--quiet] [URL]" && return
  for arg in $*; do
    [[ "$arg" =~ ^http ]] && long_url="$arg"
    [[ "$arg" =~ ^--[a-z]+ ]] && declare ${arg#--}=true
  done
  short_url=$(curl -Ss "http://api.bitly.com/v3/shorten?login=$BITLY_LOGIN&apiKey=$BITLY_API_KEY&longUrl=$long_url&format=txt" | jq '.data.url' | tr -d '"') && echo "$short_url" | pbcopy
  [[ -z "$quiet" ]] && echo "\"$short_url\" copied to clipboard." || echo $short_url
}

# Read .nvmrc if it exists
function read_nvmrc() {
  [[ -f "$PWD/.nvmrc" ]] && ( eval "nvm use" || true ) || false
}

# Enter directory and list contents
function cd() {
  [ -n "$1" ] && builtin cd "$1" || builtin cd
  l
  [ -n "$TMUX" ] && tmux setenv TMUX_"$(tmux display -p "#I")"_PWD $PWD
}

# Wrapper for terminal notifications
function growl() {
  terminal-notifier -activate com.googlecode.iterm2 -title 'iTerm' -subtitle 'Command finished running:' -message "$@"
}

# Note taking helpers
# Usage:
# $ note
# $ note [note name]
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

# REPL powered by Codi
repl() {
  [[ "$#" -eq 0 ]] && echo -e "Usage:\n repl <filetype>" && return
  local -r filetype="$1"
  tmux rename-window "REPL [$filetype]"
  vim -c "setlocal buftype=nofile signcolumn=no | let g:indentLine_char=' ' | Codi $1"
  tmux setw automatic-rename
}

joinby() {
  paste -sd "$1" -
}
