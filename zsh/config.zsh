setopt prompt_subst                 # allows variable substitution in the prompt
setopt no_beep                      # i hate beeps
setopt interactive_comments         # escape commands so i can use them later (allow comments after commands)
setopt rm_star_wait                 # if `rm *` wait 10 seconds before performing it!
setopt list_types                   # show types in completion
setopt auto_cd                      # if a command is not in the hash table, and there exists an executable directory by that name, perform the cd command to that directory.
setopt cd_able_vars                 # if the argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory.
setopt no_auto_name_dirs            # see: http://www.neactar.com/shell/fix-for-wrong-prompt-dir-when-using-zsh-project-rvmrc-and-oh-my-zsh
setopt hist_ignore_dups             # ignore duplication command history list
setopt hist_verify                  # expand history onto the current line instead of executing it
setopt hist_expire_dups_first       # remove oldest duplicate commands from the history first
setopt hist_ignore_space            # don't save commands beginning with spaces to history
setopt extended_history             # save beginning time and elapsed time before commands in history
setopt append_history               # append to the end of the history file
setopt inc_append_history           # always be saving history (not just when the shell exits)
setopt magic_equal_subst            # all unquoted arguments of the form identifier=expression appearing after the command name have file expansion
setopt menu_complete                # autoselect the first completion entry
setopt auto_menu                    # show completion menu on succesive tab press
setopt auto_pushd                   # make cd push the old directory onto the directory stack
setopt complete_in_word
setopt always_to_end
setopt no_flowcontrol

WORDCHARS="*?_-.[]~&;!#$%^(){}<>"

# history
HISTFILE=$HOME/.zhistory
HISTSIZE=100000
SAVEHIST=100000

# show time a command took if over 4 sec
export REPORTTIME=4
export TIMEFMT="%*Es total, %U user, %S system, %P cpu"

cdpath=(
  ~
  ~/code
  ~/sendgrid
  $cdpath
)