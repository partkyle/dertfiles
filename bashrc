#!/bin/bash

export PATH="~/.bin:/usr/local/bin:~/.tmuxifier/bin:$PATH"
export EDITOR="vim"

export GREP_OPTION='--color=auto'

# Whoever wants to be a <C-S>
stty stop ""

if type brew > /dev/null 2>&1; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
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
HISTSIZE=1000
HISTFILESIZE=2000

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

# . ~/.bash_themes/base.theme.bash
# . ~/.bash_themes/simple/simple.theme.bash

if [ -d ~/.localrc.d ]; then
  for file in ~/.localrc.d/*; do
    source $file
  done
  unset file
fi
