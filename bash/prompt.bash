# colors
black='\e[0;30m'
dark_gray='\e[1;30m'
blue='\e[0;34m'
light_blue='\e[1;34m'
green='\e[0;32m'
light_green='\e[1;32m'
cyan='\e[0;36m'
light_cyan='\e[1;36m'
red='\e[0;31m'
light_red='\e[1;31m'
purple='\e[0;35m'
light_purple='\e[1;35m'
brown='\e[0;33m'
yellow='\e[1;33m'
light_gray='\e[0;37m'
white='\e[1;37m'
reset='\e[00m'

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

export PS1="\n\d \t $green\u@\h$reset $yellow\!$reset:$brown\#$reset\n$purple\w$reset $light_green"'${BRANCH}'"$reset$blue\$$reset "

PROMPT_COMMAND=prompt_precmd_partkyle
