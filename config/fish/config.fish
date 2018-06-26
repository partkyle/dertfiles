set -gx CDPATH . $HOME $HOME/sendgrid $HOME/sendgrid-ops $HOME/code
set -gx PATH $HOME/.bin $HOME/.local/bin $GOBIN $PATH

_fish_git_setup

alias fig docker-compose
