function fzf_append_mru_to_prompt
  set selected_file (fzf-mru)

  if test -n "$selected_file"
    commandline -a " $selected_file"
    commandline -f repaint
  end
end
