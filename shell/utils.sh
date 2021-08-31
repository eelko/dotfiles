#!/usr/bin/env bash

# Pane name format: "<current dir name>:<currend command>"
update_tmux_pane_name() {
  [ -n "$TMUX" ] || return

  local -r current_path=$(basename "$(tmux display-message -p '#{pane_current_path}')")

  if [[ $current_path =~ - ]]; then
    # only last two words of kebab-cased names
    current_dir_name=$(echo "$current_path" | awk -F- '{if (length($0) > 15) {print $(NF-1)"-"$NF} else {print $0}}')
  else
    # truncate at 16 characters
    current_dir_name=${current_path:0:15}
  fi

  if [[ -n "$1" ]]; then
    # called by preexec zsh hook; $1 has entire command with arguments
    current_cmd="$(echo "$1" | awk '{print $1}')" # get only executable name
  else
    # called either by precmd zsh hook or pane-focus-in tmux hook
    current_cmd=$(tmux display-message -p '#{pane_current_command}')
  fi

  if [[ ! $current_cmd =~ (tmux|zsh) ]]; then
    tmux rename-window "$current_dir_name:$current_cmd"
  else
    tmux rename-window "$current_dir_name"
  fi
}

# Tmux hook - runs when pane gains focus
[ -n "$TMUX" ] && tmux set-hook pane-focus-in 'run-shell "exec $SHELL -ic update_tmux_pane_name"'

# Zsh hook - runs before executing a command
preexec() {
  update_tmux_pane_name "$1"
}

# Zsh hook - runs before displaying the prompt
precmd() {
  update_tmux_pane_name
}

# Enter directory and list contents
function cd() {
  if [[ -n "$1" ]]; then
    builtin cd "$1" && eval "l"
  else
    builtin cd && eval "l"
  fi
  [ -n "$TMUX" ] && tmux setenv TMUX_"$(tmux display -p "#I")"_PWD "$PWD"
}

# Lazy loading helper
# Usage:
#   lazy_load "RVM" "$HOME/.rvm/scripts/rvm" "rvm pod bundle gem"
function lazy_load() {
  local -r load_script_id="$1"
  local -r load_script_path="$2"
  declare -ra trigger_list=($(echo $3))
  local -r callback="$4"

  local -r load_fn="load_${load_script_id}"
  local -r load_and_run_fn="load_and_run_${load_script_id}"

  for t in "${trigger_list[@]}"; do
    if ! bin_exists "$t"; then
      export "$(echo "$t" | awk '{print toupper($0)}')_DIR"="$(dirname $load_script_path)"
      alias "$t"="$load_and_run_fn \"$t\""
    fi
  done

eval "$(cat <<EOF
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
  [[ -s $script ]] && source $script
}

# Helper to check wether a bin exists
function bin_exists() {
  command which "$1" > /dev/null 2>&1
  return $?
}

# Join each line of output by given separator
joinby() {
  paste -sd "$1" -
}

# Search/replace
replace() {
  [[ "$#" -ne 2 ]] && echo -e "Usage:\n$ replace <pattern> <replacement>" && return
  local -r pattern="$1"
  local -r replacement="$2"
  local -r matching_files=($(rg $pattern -l 2>/dev/null))

  [[ -n "$matching_files" ]] || ( echo "No occurrences of \"$pattern\" found" && return )

  for file in "${matching_files[@]}"; do
    $EDITOR -c "%s/\v$pattern/$replacement/gc" -c 'wq' "$file"
  done
}

# Vim-powered man pages
viman () { text=$(/usr/bin/man "$@") && echo "$text" | vim -R +":set ft=man" - ; }
