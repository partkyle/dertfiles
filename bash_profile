if [ command -v 2>/dev/null ]; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

export PS1='\h:\W \u\$ '

# . ~/.bash_themes/base.theme.bash
# . ~/.bash_themes/simple/simple.theme.bash
