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
