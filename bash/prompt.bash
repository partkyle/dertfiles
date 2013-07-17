# colors
black="\[\033[0;30m\]"
dark_gray="\[\033[1;30m\]"
blue="\[\033[0;34m\]"
light_blue="\[\033[1;34m\]"
green="\[\033[0;32m\]"
light_green="\[\033[1;32m\]"
cyan="\[\033[0;36m\]"
light_cyan="\[\033[1;36m\]"
red="\[\033[0;31m\]"
light_red="\[\033[1;31m\]"
purple="\[\033[0;35m\]"
light_purple="\[\033[1;35m\]"
brown="\[\033[0;33m\]"
yellow="\[\033[1;33m\]"
light_gray="\[\033[0;37m\]"
white="\[\033[1;37m\]"
reset="\[\033[00m\]"

# Detect whether the current directory is a git repository.
function is_git_repository() {
  git branch > /dev/null 2>&1
}

function set_git_prompt() {
  branch=$(git_info_for_prompt)
  if [ -n "$branch" ]; then
    BRANCH="[$branch] "
  fi
  unset branch
}

function prompt_precmd_partkyle() {
  if is_git_repository; then
    set_git_prompt
  else
    unset BRANCH
  fi
}

export PS1="$reset\n\d \t $green\u@\h$reset $yellow\!$reset:$brown\#$reset\n$purple\w$reset $light_green"'${BRANCH}'"$reset$blue"'\$'"$reset "

PROMPT_COMMAND=prompt_precmd_partkyle
