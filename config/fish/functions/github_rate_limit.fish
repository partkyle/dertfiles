function github_rate_limit
	printf '%s remaining\n' (curl -s -u partkyle:(cat ~/.github) https://api.github.com/rate_limit  | jq '.resources.core.remaining'); python -c 't = ('(curl -s -u partkyle:(cat ~/.github) https://api.github.com/rate_limit  | jq '.resources.core.reset')' - '(date '+%s')'); print t/60, "min", t%60, "sec"'
end
