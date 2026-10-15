#!/usr/bin/env bash
# wm-dir.sh — directional focus/move that also behaves in monocle.
#
# Mango's monocle layout stacks every window at the same geometry, so
# `focusdir` finds no neighbour (and on a multi-monitor setup it would jump to
# the adjacent monitor instead). `move_client` has the same problem and would
# shove the window onto another monitor. Hyprland's config handled this in Lua:
# in monocle, left/up cycled to the previous stack window, right/down to the
# next, and move did nothing. This reproduces that on the same keys.
#
#   wm-dir.sh focus <left|right|up|down>
#   wm-dir.sh move  <left|right|up|down>

set -euo pipefail

mode="${1:-}"
dir="${2:-}"

case "$mode" in
focus | move) ;;
*)
	printf 'usage: wm-dir.sh <focus|move> <left|right|up|down>\n' >&2
	exit 2
	;;
esac

case "$dir" in
left | right | up | down) ;;
*)
	printf 'wm-dir.sh: bad direction: %s\n' "$dir" >&2
	exit 2
	;;
esac

# Monitor of the focused window, falling back to the monitor under the cursor.
monitor="$(mmsg get focusing-client 2>/dev/null | sed -n 's/.*"monitor":"\([^"]*\)".*/\1/p')"
if [[ -z $monitor ]]; then
	monitor="$(mmsg get cursorpos 2>/dev/null | sed -n 's/.*"monitor":"\([^"]*\)".*/\1/p')"
fi
[[ -n $monitor ]] || exit 0

# Is the active tag on that monitor monocle? mango reports its symbol as "M".
if mmsg get tags "$monitor" 2>/dev/null | grep -q '"is_active":true[^}]*"layout":"M"'; then
	# Single stack: cycle it. Moving a window within monocle is meaningless,
	# so do nothing (as Hyprland did).
	[[ $mode == move ]] && exit 0
	case "$dir" in
	left | up) mmsg dispatch focusstack,prev ;;
	right | down) mmsg dispatch focusstack,next ;;
	esac
else
	if [[ $mode == focus ]]; then
		mmsg dispatch "focusdir,$dir"
	else
		mmsg dispatch "move_client,$dir"
	fi
fi
