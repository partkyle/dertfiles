function kthxbai
  if test -z $argv
    echo "argument is required!"
    return 1
  end

  set result (ps aux | grep "$argv" | grep -v "grep" )
  echo "$result"
  echo "$result" | awk '{print $2}' | sudo xargs kill -9
end
