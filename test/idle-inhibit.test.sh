#!/usr/bin/env bash
# Tests for nix/hypr/scripts/idle-inhibit.sh, the shared state behind the bar's
# keep-awake lock and `dert idle`. Run with `bash test/idle-inhibit.test.sh`.

set -uo pipefail

script="$(cd "$(dirname "$0")/.." && pwd)/nix/hypr/scripts/idle-inhibit.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/run" "$tmp/config"

# Source the helpers without running main. Point the state at the temp dir so a
# mistake can never touch the real lock.
export XDG_RUNTIME_DIR="$tmp/run"
export XDG_CONFIG_HOME="$tmp/config"
# shellcheck source=/dev/null
source "$script"
set +e

failures=0

check() {
  local desc=$1 expected=$2 actual=$3
  if [[ $expected == "$actual" ]]; then
    printf 'ok   %s\n' "$desc"
  else
    printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$desc" "$expected" "$actual" >&2
    failures=$((failures + 1))
  fi
}

check_rejects() {
  local desc=$1 input=$2
  if parse_duration "$input" >/dev/null 2>&1; then
    printf 'FAIL %s (accepted %q)\n' "$desc" "$input" >&2
    failures=$((failures + 1))
  else
    printf 'ok   %s\n' "$desc"
  fi
}

# ── duration parsing ────────────────────────────────────────────────────────
check "seconds pass through" 90 "$(parse_duration 90)"
check "minutes expand" 2700 "$(parse_duration 45m)"
check "hours expand" 7200 "$(parse_duration 2h)"
check "combined units sum" 5400 "$(parse_duration 1h30m)"
check "days expand" 172800 "$(parse_duration 2d)"
check_rejects "rejects empty" ""
check_rejects "rejects zero" 0
check_rejects "rejects garbage" soon
check_rejects "rejects trailing unit" 5x
check_rejects "rejects negative" -30

# ── end-to-end CLI ──────────────────────────────────────────────────────────
run() {
  XDG_RUNTIME_DIR="$tmp/run" XDG_CONFIG_HOME="$tmp/config" bash "$script" "$@"
}

check "starts released" "on" "$(run status)"
check "falls back to one hour" "3600" "$(run default)"

run default 45m >/dev/null
check "default persists" "2700" "$(run default)"
check "config stores seconds" "2700" "$(cat "$tmp/config/dert/idle-inhibit")"

run inhibit >/dev/null
state="$(run status)"
check "inhibit reports off" "off" "${state%% *}"
remaining="${state#* }"
if ((remaining > 2600 && remaining <= 2700)); then
  printf 'ok   inhibit uses the configured default\n'
else
  printf 'FAIL inhibit uses the configured default (remaining=%s)\n' "$remaining" >&2
  failures=$((failures + 1))
fi
check "check blocks while inhibited" "1" "$(run check >/dev/null 2>&1; echo $?)"

run release >/dev/null
check "release reports on" "on" "$(run status)"
check "check passes when released" "0" "$(run check >/dev/null 2>&1; echo $?)"

if ((failures > 0)); then
  printf '\n%d test(s) failed\n' "$failures" >&2
  exit 1
fi
printf '\nall tests passed\n'
