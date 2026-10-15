#!/usr/bin/env bash
# background.sh — pick a random image from ~/.config/backgrounds and hand off
# to swaybg, which draws it for the lifetime of the compositor.
#
# Run as the `mango-background` systemd user service, bound to
# mango-session.target. Restart it to roll a new image:
#
#   systemctl --user restart mango-background

set -euo pipefail

bg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/backgrounds"

shopt -s nullglob
images=("$bg_dir"/*.png "$bg_dir"/*.jpg "$bg_dir"/*.jpeg)
shopt -u nullglob

if ((${#images[@]} == 0)); then
	printf 'background.sh: no images in %s\n' "$bg_dir" >&2
	exit 1
fi

image="${images[RANDOM % ${#images[@]}]}"

exec swaybg -i "$image" -m fill
