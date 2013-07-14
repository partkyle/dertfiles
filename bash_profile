export PATH="/usr/local/bin:$PATH"
export EDITOR="vim"

if type brew > /dev/null 2>&1; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# history settings
shopt -s histappend

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

export PS1='\n\h:\W $(git_info_for_prompt)\$ '

# . ~/.bash_themes/base.theme.bash
# . ~/.bash_themes/simple/simple.theme.bash

if [ -d ~/.localrc.d ]; then
  for file in ~/.localrc.d/*; do
    source $file
  done
  unset file
fi
