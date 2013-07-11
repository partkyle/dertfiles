if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# . ~/.bash_themes/base.theme.bash
# . ~/.bash_themes/simple/simple.theme.bash
