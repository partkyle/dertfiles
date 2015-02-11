function kthxbai
  if test -z $argv
    echo "argument is required!"
    return 1
  end

  set_color yellow

  set result (ps aux | grep "$argv" | grep -v "grep")
  echo "$result"

  set_color normal

  if test (echo "$result" | awk '/^.+$/{print $1}' | wc -l) -gt 0
    set_color red
    echo
    echo 'want to kill them all?'

    set_color normal

    if read -p echo
      echo "$result" | awk '{print $2}' | sudo xargs kill -9
    end
  end

  set_color normal
end
