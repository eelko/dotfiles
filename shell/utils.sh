#!/usr/bin/env bash

# Enter directory and list contents
function cd() {
  if [[ -n "$1" ]]; then
    builtin cd "$1" && eval "l"
  else
    builtin cd && eval "l"
  fi
}

# Lazy loading helper
# Usage:
#   lazy_load "RVM" "$HOME/.rvm/scripts/rvm" "rvm pod bundle gem"
function lazy_load() {
  local -r load_script_id="$1"
  local -r load_script_path="$2"
  declare -ra trigger_list=("$(echo "$3")")
  local -r callback="$4"

  local -r load_fn="load_$load_script_id"
  local -r load_and_run_fn="load_and_run_$load_script_id"

  for t in "${trigger_list[@]}"; do
    if ! bin_exists "$t"; then
      export "$(echo "$t" | awk '{print toupper($0)}')_DIR"="$(dirname "$load_script_path")"
      alias "$t"="$load_and_run_fn \"$t\""
    fi
  done

  eval "$(
    cat <<EOF
  function ${load_fn}() {
    local -r bin_name="\$1"
    if ! bin_exists "\$bin_name"; then
      echo -n 'Loading $load_script_id... '
      for a in ${trigger_list[@]}; do
        alias "\$a" 2>/dev/null >/dev/null && unalias "\$a"
      done
      if [[ -s "$load_script_path" ]]; then
        source "$load_script_path"
      else
        echo "\nError: Path \"$load_script_path\" is not a script."
      fi
      unset -f $load_fn $load_and_run_fn
    fi
  }

  function ${load_and_run_fn}() {
    local -r bin_name=\$1
    $load_fn \$bin_name
    echo 'done!'
    if typeset -f "$callback" > /dev/null; then eval $callback; fi
    \$bin_name "\${@:2}"
  }
EOF
  )"
}

# Convert all .flac files (within directpry) to mp3
function flac2mp3() {
  for f in **/*.flac; do
    ffmpeg -i "$f" -ab 320k -map_metadata 0 -id3v2_version 3 "${f[@]/%flac/mp3}"
  done
}

# Convert all .m4a files (within directpry) to mp3
function m4a2mp3() {
  for f in **/*.m4a; do
    ffmpeg -i "$f" -codec:v copy -codec:a libmp3lame -q:a 2 "${f%.m4a}.mp3"
  done
}

# Split .mp3 by given start/end time
function mp3split() {
  input=$1
  start=$2
  end=$3
  output="${input%.mp3}_${start//:/}_${end//:/}.mp3"
  ffmpeg -i "$input" -vn -acodec copy -ss "$start" -t "$end" "$output"
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

# Source file if it exists
function source_if_exists() {
  local script="$1"
  [[ -s $script ]] && source "$script"
}

# Helper to check wether a bin exists
function bin_exists() {
  command which "$1" >/dev/null 2>&1
  return $?
}

# Join each line of output by given separator
joinby() {
  paste -sd "$1" -
}

# Mass download files from website (apache, h5ai, etc)
# https://stackoverflow.com/a/26269730
# wget -r -np -nH --cut-dirs=3 -R index.html http://hostname/aaa/bbb/ccc/ddd
download_files() {
  wget -r -np -nH --cut-dirs=3 -R index.html "$@"
}
