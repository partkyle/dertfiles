function fish_right_prompt --description 'Write out the right prompt'
  if test -z "$PROMPT_RIGHT"
    return
  end
  if test -z "$PROMPT_DEMO"
    set_color yellow
    printf '@'
    hostname
    set_color normal
    printf ' '
    set_color blue
    date "+[%Y-%m-%d %H:%M:%S]"
  end
end
