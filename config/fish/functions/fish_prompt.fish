function fish_prompt
  set last_status $status

  set_color $fish_color_cwd
  printf '%s' (prompt_pwd)
  set_color normal

  printf '%s ' (__fish_git_prompt)

  if test $last_status -eq 0
    set_color green
  else
    set_color red
  end

  printf '> '

  set_color normal
end
