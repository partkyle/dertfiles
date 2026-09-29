#!/usr/bin/env bash
# idle-inhibit.sh — temporarily suspend hypridle's lock / display-sleep actions.
#
# The state is a single file in $XDG_RUNTIME_DIR holding the epoch at which the
# inhibit expires. A missing or expired stamp means idle actions are enabled
# (normal hypridle behaviour). The quickshell bar's lock icon writes the stamp;
# hypridle's listeners consult it through `check`, so both share this one
# source. Using hypridle's condition_cmd + condition_retry means the machine
# still locks once the stamp expires even if it stays idle.
#
#   toggle [seconds]    flip the inhibit state (default: 3600s / 1h)
#   on                  re-enable idle actions immediately
#   off [seconds]       inhibit idle actions for [seconds] (default: 1h)
#   status              print "on" or "off <remaining-seconds>"
#   check               exit 0 when idle actions should run, 1 while inhibited
#                       (used as hypridle's condition_cmd)

set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/hypridle-inhibit"
default_duration=3600

now() { date +%s; }

# Echo the expiry epoch and succeed while inhibited; otherwise clean up any
# stale stamp and fail.
inhibited_until() {
    [ -f "$state_file" ] || return 1
    local expiry
    expiry="$(cat "$state_file" 2>/dev/null || echo 0)"
    if [ "$expiry" -gt "$(now)" ]; then
        echo "$expiry"
        return 0
    fi
    rm -f "$state_file"
    return 1
}

inhibit() {
    local duration="${1:-$default_duration}"
    echo "$(($(now) + duration))" >"$state_file"
}

case "${1:-status}" in
toggle)
    if inhibited_until >/dev/null; then
        rm -f "$state_file"
    else
        inhibit "${2:-}"
    fi
    ;;
off)
    inhibit "${2:-}"
    ;;
on)
    rm -f "$state_file"
    ;;
status)
    if expiry="$(inhibited_until)"; then
        echo "off $((expiry - $(now)))"
    else
        echo "on"
    fi
    ;;
check)
    if inhibited_until >/dev/null; then
        exit 1
    fi
    ;;
*)
    echo "usage: $0 {toggle|on|off|status|check} [seconds]" >&2
    exit 2
    ;;
esac
