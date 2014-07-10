# Detect whether the current directory is a git repository.
is_git_repository() {
  git branch > /dev/null 2>&1
}

set_git_prompt() {
  if is_git_repository; then
    GIT_BRANCH=$(git_info_for_prompt)
  else
    unset GIT_BRANCH
  fi
}

prompt() {
  PS1="\n[\h:\w]\$ "
}

PROMPT_COMMAND=prompt
