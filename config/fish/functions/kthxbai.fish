function kthxbai
  if test -z $argv
    echo "argument is required!"
    return 1
  end

  set_color yellow

  set result (ps aux | grep "$argv" | grep -v "grep")
  for line in $result
    echo $line
    set pids $pids (echo $line | awk '{print $2}')
  end

  set num (count $pids)

  set_color normal

  if test $num -gt 0
    set_color red
    echo
    echo "want to kill them all? ($num) [CTRL-C to cancel]"

    set_color normal

    if read -p echo
      kill -9 $pids
    end
  else
    echo "no processes found"
  end

  set_color normal
end
