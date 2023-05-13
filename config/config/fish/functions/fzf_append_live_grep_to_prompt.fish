function fzf_append_live_grep_to_prompt
  set selected_file (live-grep)

  if test -n "$selected_file"
    commandline -a " $selected_file"
    commandline -f repaint
  end
end
