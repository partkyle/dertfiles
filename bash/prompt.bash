# Detect whether the current directory is a git repository.
is_git_repository() {
  git branch > /dev/null 2>&1
}

set_git_branch() {
  if is_git_repository; then
    GIT=$(git_info_for_prompt)
  else
    unset GIT
  fi
}

DEFAULT_MY_ENV=(GIT)

set_my_env() {
  MY_ENV=($DEFAULT_MY_ENV $*)

  ls | grep -c '\.go' > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    MY_ENV+=('GOPATH')
  fi
}

set_ps1() {
  PS1="\[\e[33m\]\n"

  for e in "${MY_ENV[@]}"; do
    if [[ -n "${!e}" ]]; then
      PS1+="$e=${!e} "
    fi
  done

  prompt_color="\[\e[32m\]"
  if [[ $last_cmd -ne 0 ]]; then
    prompt_color="\[\e[0;31m\]"
  fi

  PS1+="\[\e[32m\]\n\W $prompt_color>\[\e[0m\] "
}

prompt() {
  last_cmd=$?

  set_my_env
  set_git_branch
  set_ps1
}

PROMPT_COMMAND=prompt
