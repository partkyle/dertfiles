function demo
  if test -z "$PROMPT_DEMO"
    set -g PROMPT_DEMO 1
  else
    set -ge PROMPT_DEMO
  end
end
