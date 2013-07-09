if $(gls &>/dev/null); then
  alias ls='gls --color=auto'
else
  alias ls='ls --color=auto'
fi


alias ll='ls -lh'
alias la='ls -alh'
