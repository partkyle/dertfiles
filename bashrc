#!/bin/bash

export PATH="~/.bin:/usr/local/bin:~/.tmuxifier/bin:$PATH"
export EDITOR="vim"

export GREP_OPTIONS='--color=auto'

if [ -t 0 ]; then
  # nobody wants to be a <C-S>
  stty stop ""
fi

if type brew > /dev/null 2>&1; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
  if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
    . $(brew --prefix)/share/bash-completion/bash_completion
  fi
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
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

# include functions
if [ -d ~/.bash/functions ]; then
  for file in ~/.bash/functions/*; do
    . $file
  done
  unset file
fi

# add aliases
if [ -d ~/.bash/aliases ]; then
  for file in ~/.bash/aliases/*; do
    . $file
  done
  unset file
fi

source ~/.bash/prompt.bash

if [ -d ~/.localrc.d ]; then
  for file in $(find ~/.localrc.d -type f); do
    . $file
  done
  unset file
fi
