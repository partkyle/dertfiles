function wait_for_it
	while not eval $argv
echo 'waiting'
sleep 1
end
end
