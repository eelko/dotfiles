function switch_project -d "Switch to a project directory"
  set projects_dir (commandline -o)

  if not test -n "$projects_dir"
    set projects_dir ~/Code
  end

  set project (fd --hidden --type directory --exclude .github .git "$projects_dir" | awk -F/ '{print $(NF-3) "/" $(NF-2)}' | fzf --no-multi --prompt "Switch to project: ")

  if test -n "$project"
    cd "$(fd --type directory --full-path "$project\$" "$projects_dir" --exec echo {})"
  end
end

