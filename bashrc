#!/bin/bash

export PATH="~/.bin:/usr/local/bin:~/.tmuxifier/bin:$PATH"
export EDITOR="vim"

export GREP_OPTIONS='--color=auto'

if [ -t 0 ]; then
  # nobody wants to be a <C-S>
  stty stop ""
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000

# update cdpath
export CDPATH=.:$HOME:/usr/local

export PROMPT_DIRTRIM=2

function git_info_for_prompt() {
  local g="$(git rev-parse --git-dir 2>/dev/null)"
  if [ -n "$g" ]; then
    local r
    local b
    if [ -d "$g/../.dotest" ]
    then
      if test -f "$g/../.dotest/rebasing"
      then
        r="|REBASE"
      elif test -f "$g/../.dotest/applying"
      then
        r="|AM"
      else
        r="|AM/REBASE"
      fi
      b="$(git symbolic-ref HEAD 2>/dev/null)"
    elif [ -f "$g/.dotest-merge/interactive" ]
    then
      r="|REBASE-i"
      b="$(cat "$g/.dotest-merge/head-name")"
    elif [ -d "$g/.dotest-merge" ]
    then
      r="|REBASE-m"
      b="$(cat "$g/.dotest-merge/head-name")"
    elif [ -f "$g/MERGE_HEAD" ]
    then
      r="|MERGING"
      b="$(git symbolic-ref HEAD 2>/dev/null)"
    else
      if [ -f "$g/BISECT_LOG" ]
      then
        r="|BISECTING"
      fi
      if ! b="$(git symbolic-ref HEAD 2>/dev/null)"
      then
        if ! b="tag: $(git describe --exact-match HEAD 2>/dev/null)"
        then
          b="$(cut -c1-7 "$g/HEAD")..."
        fi
      fi
    fi

    if [ -n "$1" ]; then
      printf "$1" "${b##refs/heads/}$r"
    else
      printf "%s" "${b##refs/heads/}$r"
    fi
  fi
}

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

prompt_error() {
  if [ $? == 0 ]; then
    PROMPT_COLOR=$blue
  else
    PROMPT_COLOR=$red
  fi
}


# Detect whether the current directory is a git repository.
is_git_repository() {
  git branch > /dev/null 2>&1
}

set_git_prompt() {
  if is_git_repository; then
    branch=$(git_info_for_prompt)
    if [ -n "$branch" ]; then
      BRANCH=" $light_green[$branch]$reset"
    fi
    unset branch
  else
    unset BRANCH
  fi
}

set_host_section() {
  if [ -n "$SSH_CONNECTION" ]; then
    host_color=$red
  else
    host_color=$green
  fi
}

prompt() {
  prompt_error
  set_git_prompt
  set_host_section

  if [[ -n "$VIRTUAL_ENV" ]]; then
    VENV_PROMPT=" $green{`basename $VIRTUAL_ENV`}$reset"
  else
    VENV_PROMPT=
  fi

  if [[ -n "$GOPATH" ]]; then
    GOPROMPT=" $green{`basename $GOPATH`}$reset"
  else
    GOPROMPT=
  fi


  PS1="$reset\n\d \t $host_color\u@\h$reset $yellow\!$reset:$brown\#$reset$VENV_PROMPT$GOPROMPT$BRANCH\n$purple\w$reset $PROMPT_COLOR\\\$$reset "
}

PROMPT_COMMAND=prompt

localrc="$HOME/.localrc"
if [ -e $HOME/.localrc ]; then
	source $localrc
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

gst() {
	git status
}

grm() {
	git status | grep deleted | awk '{print \$3}' | xargs git rm
}

update-local() {
	cat $HOME/.localrc.d/* > $localrc
	source $localrc
}

if $(gls &>/dev/null); then
	ls() {
		gls --color=auto "$@"
	}
else
	ls() {
		ls --color=auto "$@"
	}
fi

ll() {
	ls -lh
}

la() {
	ls -alh
}
