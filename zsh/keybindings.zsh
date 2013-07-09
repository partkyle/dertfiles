# emacs bindings
bindkey -e

# option + right/left
bindkey "\e\e[9C" forward-word
bindkey "\e\e[9D" backward-word

# make the delete key (or Fn + Delete on the Mac) work instead of outputting a ~
bindkey '^?' backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char
bindkey "\e[3~" delete-char

# start tetris on ctrl+t
autoload -U tetris
zle -N tetris
bindkey '^T' tetris

# handy for renaming files
bindkey "^[m" copy-prev-shell-word

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line
