function _prompt_char_color
  if test $argv[1] -eq 0
    set_color green
  else
    set_color red
  end

  printf $argv[2]
end

function fish_prompt
  set last_status $status

  if test -z "$PROMPT_DEMO"
    if test -z "$PROMPT_RIGHT"
      printf "\n"
      printf '%s%s %s@%s\n' (set_color blue) (date "+[%Y-%m-%d %H:%M:%S]") (set_color yellow) (hostname)
    end

    set_color $fish_color_cwd
    printf '%s' (prompt_pwd)

    set_color normal
    printf '%s ' (__fish_git_prompt)

    _prompt_char_color $last_status '> '
  else
    _prompt_char_color $last_status '$ '
  end

  set_color normal
end
