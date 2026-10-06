#!/usr/bin/env bash
# idle-inhibit.sh — temporarily suspend hypridle's lock / display-sleep actions.
#
# The runtime state is a single file in $XDG_RUNTIME_DIR holding the epoch at
# which the inhibit expires. A missing or expired stamp means idle actions are
# enabled (normal hypridle behaviour). The quickshell bar's lock icon writes the
# stamp; hypridle's listeners consult it through `check`, so both share this one
# source. Using hypridle's condition_cmd + condition_retry means the machine
# still locks once the stamp expires even if it stays idle.
#
# The length used when no duration is given (the bar's left click, or a bare
# `dert idle on`) is configurable. It lives under XDG config so it can be
# changed at runtime; `dert idle` wraps this script.
#
#   toggle [duration]    flip the inhibit state
#   inhibit [duration]   inhibit idle actions (alias: off)
#   release              re-enable idle actions immediately (alias: on)
#   default [duration]   print, or set, the default inhibit duration
#   status               print "on" or "off <remaining-seconds>"
#   check                exit 0 when idle actions should run, 1 while inhibited
#                        (used as hypridle's condition_cmd)
#
# Durations are seconds or a suffixed string: 90, 45m, 2h, 1h30m.
# Mutation commands print the resulting status, so callers can report it.

set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/hypridle-inhibit"
config_file="${XDG_CONFIG_HOME:-$HOME/.config}/dert/idle-inhibit"
fallback_duration=3600

now() { date +%s; }

# Parse a human duration ("90", "45m", "2h", "1h30m") into seconds.
parse_duration() {
    local spec=$1 total=0 num unit
    [[ -n $spec ]] || return 1
    if [[ $spec =~ ^[0-9]+$ ]]; then
        total=$spec
    else
        while [[ -n $spec ]]; do
            if [[ $spec =~ ^([0-9]+)([smhd])(.*)$ ]]; then
                num=${BASH_REMATCH[1]}
                unit=${BASH_REMATCH[2]}
                spec=${BASH_REMATCH[3]}
                case $unit in
                s) total=$((total + num)) ;;
                m) total=$((total + num * 60)) ;;
                h) total=$((total + num * 3600)) ;;
                d) total=$((total + num * 86400)) ;;
                esac
            else
                return 1
            fi
        done
    fi
    ((total > 0)) || return 1
    printf '%s\n' "$total"
}

# The configured default, or the fallback when unset/invalid.
default_duration() {
    local value
    if [[ -r $config_file ]] && value="$(cat "$config_file" 2>/dev/null)" \
        && [[ $value =~ ^[0-9]+$ ]] && ((value > 0)); then
        printf '%s\n' "$value"
    else
        printf '%s\n' "$fallback_duration"
    fi
}

set_default() {
    local seconds
    seconds="$(parse_duration "$1")" || {
        echo "invalid duration: $1" >&2
        return 2
    }
    mkdir -p -- "$(dirname "$config_file")"
    printf '%s\n' "$seconds" >"$config_file"
    printf '%s\n' "$seconds"
}

# Echo the expiry epoch and succeed while inhibited; otherwise clean up any
# stale stamp and fail.
inhibited_until() {
    [ -f "$state_file" ] || return 1
    local expiry
    expiry="$(cat "$state_file" 2>/dev/null || echo 0)"
    if [[ $expiry =~ ^[0-9]+$ ]] && ((expiry > $(now))); then
        printf '%s\n' "$expiry"
        return 0
    fi
    rm -f "$state_file"
    return 1
}

status() {
    local expiry
    if expiry="$(inhibited_until)"; then
        printf 'off %s\n' "$((expiry - $(now)))"
    else
        printf 'on\n'
    fi
}

inhibit() {
    local seconds
    if [[ -n ${1:-} ]]; then
        seconds="$(parse_duration "$1")" || {
            echo "invalid duration: $1" >&2
            return 2
        }
    else
        seconds="$(default_duration)"
    fi
    printf '%s\n' "$(($(now) + seconds))" >"$state_file"
    status
}

release() {
    rm -f "$state_file"
    printf 'on\n'
}

main() {
    case "${1:-status}" in
    toggle)
        if inhibited_until >/dev/null; then
            release
        else
            inhibit "${2:-}"
        fi
        ;;
    off | inhibit)
        inhibit "${2:-}"
        ;;
    on | release)
        release
        ;;
    default)
        if [[ -n ${2:-} ]]; then
            set_default "$2"
        else
            default_duration
        fi
        ;;
    status)
        status
        ;;
    check)
        if inhibited_until >/dev/null; then
            exit 1
        fi
        ;;
    *)
        echo "usage: $0 {toggle|inhibit|release|default|status|check} [duration]" >&2
        exit 2
        ;;
    esac
}

# Allow the test suite to source the helpers without running the CLI.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
