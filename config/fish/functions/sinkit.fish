function sinkit
  set_color yellow

  set result (docker ps -a | tail -n+2)
  for line in $result
    echo $line
    set cids $cids (echo $line | awk '{print $1}')
  end

  set num (count $cids)

  set_color normal

  if test $num -gt 0
    set_color red
    echo
    echo "want to kill them all? ($num) [CTRL-C to cancel]"

    set_color normal

    if read -p echo
      docker rm -f $cids
    end
  else
    echo "no containers found"
  end

  set_color normal
end
