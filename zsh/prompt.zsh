# partkyle's Prompt

export VIRTUAL_ENV_DISABLE_PROMPT=1

autoload colors; colors
autoload -Uz vcs_info

pk_hostname () {
  local host=$(hostname)

  echo $host
}

precmd () {
  vcs_info
  _virtualenv_prompt
  _gopath_prompt
}

_virtualenv_prompt () {
  if test -s "$VIRTUAL_ENV"; then
    PARTKYLE_VIRTUAL_ENV_PROMPT="[VIRTUAL_ENV=`basename $VIRTUAL_ENV`] "
  fi
}

_gopath_prompt () {
  # joins together strings using a given delimeter
  # usage: $ join "," a b c # a,b,c
  join() { local IFS="$1"; shift; echo "$*"; }

  if [[ -n "$GOPATH" ]]; then
    paths=$(join ":" `for p in $(echo $GOPATH | tr ":" " "); do basename $p; done`)
    PARTKYLE_GOPATH_PROMPT="[GOPATH=$paths] "
  fi
}

zstyle ':vcs_info:*' enable bzr git hg svn
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' formats "{%b%c%u} "
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b|%F{cyan}%r%f"

PROMPT=$'\n''$PARTKYLE_VIRTUAL_ENV_PROMPT$PARTKYLE_GOPATH_PROMPT${vcs_info_msg_0_}'$'\n''%~ %# '
RPROMPT='@$(pk_hostname) [%*]'

PROMPT2=' > '
RPROMPT2='[%_]'
