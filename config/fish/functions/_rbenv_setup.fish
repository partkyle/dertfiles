function _rbenv_setup
	setenv PATH '/Users/partkyle/.rbenv/shims' $PATH
  setenv RBENV_SHELL fish
  . '/usr/local/Cellar/rbenv/HEAD/libexec/../completions/rbenv.fish'
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
