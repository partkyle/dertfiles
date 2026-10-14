#!/usr/bin/env bash
# dpms.sh — blank/wake every output for hypridle, whichever compositor runs.
#
# Hyprland has its own dpms dispatcher. mango (and other wlroots compositors)
# implement wlr-output-power-management, which wlopm drives. Hyprland does not
# implement that protocol, so pick the right tool from the session env.
#
#   dpms.sh off   blank every output
#   dpms.sh on    wake every output

set -euo pipefail

action="${1:-}"
case "$action" in
off | on) ;;
*)
	printf 'usage: dpms.sh <off|on>\n' >&2
	exit 2
	;;
esac

if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
	if [[ $action == off ]]; then
		hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' >/dev/null
	else
		hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' >/dev/null
	fi
else
	if [[ $action == off ]]; then
		wlopm --off '*'
	else
		wlopm --on '*'
	fi
fi
