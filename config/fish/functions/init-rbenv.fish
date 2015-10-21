function init-rbenv
  set -x PATH $HOME/.rbenv/shims $PATH
  set -x RBENV_SHELL fish
  # . '/usr/local/Cellar/rbenv/0.4.0/libexec/../completions/rbenv.fish'
  rbenv rehash 2>/dev/null
  function rbenv
    set command $argv[1]
    set -e argv[1]

    switch "$command"
    case rehash shell
      eval (rbenv "sh-$command" $argv)
    case '*'
      command rbenv "$command" $argv
    end
  end
end
