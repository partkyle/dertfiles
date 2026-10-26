#!/usr/bin/env bash
# idle-action.sh — swayidle actions that respect the keep-awake stamp.
#
# `lock` and `dpms-off` run immediately when idle-inhibit.sh's `check` passes.
# While it fails, they start a detached `_wait` child that polls the stamp and
# fires the action once the stamp expires. Swayidle's resume command cancels
# those children on activity. `sleep` always locks and cancels deferrals.

set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}"
inhibit_script="$HOME/.config/idle/scripts/idle-inhibit.sh"
dpms_script="$HOME/.config/idle/scripts/dpms.sh"

lock_now() {
    pidof swaylock >/dev/null 2>&1 || swaylock -f
}

pidfile_for() {
    printf '%s/swayidle-%s.pid\n' "$state_dir" "$1"
}

cancel_one() {
    local pidfile=$1 pid cmdline
    [[ -r $pidfile ]] || return 0
    pid="$(<"$pidfile")"
    if [[ $pid =~ ^[0-9]+$ ]]; then
        cmdline="$(tr '\0' ' ' 2>/dev/null <"/proc/$pid/cmdline" || true)"
        if [[ $cmdline == *"idle-action.sh _wait"* ]]; then
            kill "$pid" 2>/dev/null || true
        fi
    fi
    rm -f "$pidfile"
}

cancel() {
    cancel_one "$(pidfile_for lock)"
    cancel_one "$(pidfile_for dpms-off)"
}

wait_and_run() {
    local action=$1 pidfile
    pidfile="$(pidfile_for "$action")"
    printf '%s\n' "$$" >"$pidfile"
    while ! "$inhibit_script" check; do
        sleep 5
    done
    case "$action" in
    lock) lock_now ;;
    dpms-off) "$dpms_script" off ;;
    esac
    if [[ -r $pidfile && "$(<"$pidfile")" == "$$" ]]; then
        rm -f "$pidfile"
    fi
}

defer() {
    local action=$1
    cancel_one "$(pidfile_for "$action")"
    "$0" _wait "$action" >/dev/null 2>&1 &
}

resume() {
    cancel
    "$dpms_script" on
}

sleep_now() {
    cancel
    lock_now
}

case "${1:-}" in
lock)
    if "$inhibit_script" check; then lock_now; else defer lock; fi
    ;;
dpms-off)
    if "$inhibit_script" check; then "$dpms_script" off; else defer dpms-off; fi
    ;;
resume) resume ;;
sleep) sleep_now ;;
cancel) cancel ;;
_wait)
    shift
    wait_and_run "${1:?missing action}"
    ;;
*)
    printf 'usage: idle-action.sh <lock|dpms-off|resume|sleep|cancel>\n' >&2
    exit 2
    ;;
esac
