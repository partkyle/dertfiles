#!/usr/bin/env bash
set -euo pipefail

SPIN=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

git status --short
echo "---"
git diff --cached --stat
git diff --stat

pi -p "Review the current git status and diff, then update CHANGELOG.md with a single entry for today's date based on what changed. Follow the existing format in CHANGELOG.md." &
PID=$!
i=0
while kill -0 "$PID" 2>/dev/null; do
	printf "\r%s updating changelog..." "${SPIN[$((i % ${#SPIN[@]}))]}"
	sleep 0.1
	i=$((i + 1))
done
wait "$PID"
printf "\r✓ changelog updated\n"
