#!/usr/bin/env bash
# screenshot.sh — screenshot support for Hyprland.
#
# Captures the screen with grim, picking the area with slurp (region) or
# hyprctl (window / output), then saves the PNG under ~/Pictures/Screenshots
# and copies it to the clipboard. `--edit` opens the capture in satty to
# annotate it first. Images are attached to the notification, which the
# quickshell shell renders and persists.
#
# Cancelling slurp, or quitting satty without saving, exits 1 and does nothing.

set -euo pipefail

usage() {
	cat <<'EOF'
screenshot.sh — screenshot support for Hyprland (grim + slurp + satty).

Usage: screenshot.sh [mode] [options]

Modes (default: region):
  region   interactively select an area with slurp
  window   the focused window
  output   the focused monitor
  full     every monitor combined

Options:
  -e, --edit            annotate in satty before saving and copying
  -c, --clipboard       copy the result to the clipboard (default)
      --no-clipboard    do not copy
  -n, --notify          show a notification on success (default)
      --no-notify       do not notify
      --no-save         do not write a file
  -d, --dir DIR         save into DIR instead of ~/Pictures/Screenshots
                        (the SCREENSHOT_DIR variable overrides the default)
  -h, --help            show this help

Cancelling the selection, or quitting satty without saving, exits 1 without
touching the clipboard or the screenshots directory.
EOF
}

# ── argument parsing ────────────────────────────────────────────────────────
# Populates MODE, OPT_EDIT, OPT_CLIPBOARD, OPT_NOTIFY, OPT_SAVE and OPT_DIR so
# the tests can exercise it without running a capture.

MODE=region
OPT_EDIT=0
OPT_CLIPBOARD=1
OPT_NOTIFY=1
OPT_SAVE=1
OPT_DIR=""

parse_args() {
	MODE=""
	OPT_EDIT=0
	OPT_CLIPBOARD=1
	OPT_NOTIFY=1
	OPT_SAVE=1
	OPT_DIR=""
	while (($#)); do
		case "$1" in
		region | window | output | full)
			if [[ -n $MODE ]]; then
				echo "screenshot.sh: mode already set to '$MODE'" >&2
				return 2
			fi
			MODE=$1
			;;
		-e | --edit) OPT_EDIT=1 ;;
		-c | --clipboard) OPT_CLIPBOARD=1 ;;
		--no-clipboard) OPT_CLIPBOARD=0 ;;
		-n | --notify) OPT_NOTIFY=1 ;;
		--no-notify) OPT_NOTIFY=0 ;;
		--no-save) OPT_SAVE=0 ;;
		-d | --dir)
			if (($# < 2)); then
				echo "screenshot.sh: --dir needs a directory" >&2
				return 2
			fi
			OPT_DIR=$2
			shift
			;;
		-h | --help | help)
			usage
			return 3
			;;
		-*)
			echo "screenshot.sh: unknown option '$1'" >&2
			return 2
			;;
		*)
			echo "screenshot.sh: unknown mode '$1'" >&2
			return 2
			;;
		esac
		shift
	done
	MODE="${MODE:-region}"
}

# ── geometry helpers ────────────────────────────────────────────────────────

# Parse `hyprctl activewindow` into grim's "x,y WxH". Fails when no window is
# focused, or the window is not on screen.
focused_window_geometry() {
	hyprctl activewindow 2>/dev/null | awk '
		/^\tat: /   { split($2, a, ","); x = a[1]; y = a[2] }
		/^\tsize: / { split($2, s, ","); w = s[1]; h = s[2] }
		END {
			if (x == "" || y == "" || w == "" || h == "") exit 1
			printf "%s,%s %sx%s\n", x, y, w, h
		}
	'
}

# Name of the focused monitor (for grim -o).
focused_output() {
	hyprctl monitors 2>/dev/null | awk '
		/^Monitor / { name = $2 }
		/^\tfocused: yes/ { print name; found = 1; exit }
		END { if (!found) exit 1 }
	'
}

# ── capture ─────────────────────────────────────────────────────────────────

capture() {
	local geometry name
	case "$MODE" in
	region)
		geometry="$(slurp -b '#00000000' -c '#89b4faaa' -w 2)" || return 1
		[[ -n $geometry ]] || return 1
		grim -g "$geometry" -
		;;
	window)
		geometry="$(focused_window_geometry)" || return 1
		grim -g "$geometry" -
		;;
	output)
		name="$(focused_output)" || return 1
		grim -o "$name" -
		;;
	full)
		grim -
		;;
	esac
}

# ── output paths ────────────────────────────────────────────────────────────

default_dir() {
	printf '%s\n' "${SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots}"
}

# A path in DIR for NAME, suffixing -1, -2, ... rather than overwriting.
unique_path() {
	local dir=$1 name=$2 stem ext candidate n=1
	stem="${name%.*}"
	ext="${name##*.}"
	candidate="$dir/$name"
	while [[ -e $candidate ]]; do
		candidate="$dir/${stem}-${n}.${ext}"
		n=$((n + 1))
	done
	printf '%s\n' "$candidate"
}

# ── main ────────────────────────────────────────────────────────────────────

main() {
	local status=0
	parse_args "$@" || status=$?
	case $status in
	0) ;;
	3) exit 0 ;;
	*)
		usage >&2
		exit 2
		;;
	esac

	local tmp raw out="" dir=""
	tmp="$(mktemp -d)"
	trap "rm -rf -- ${tmp@Q}" EXIT
	raw="$tmp/capture.png"

	if ! capture >"$raw"; then
		exit 1
	fi

	if ((OPT_EDIT || OPT_SAVE)); then
		dir="${OPT_DIR:-$(default_dir)}"
		mkdir -p -- "$dir"
		out="$(unique_path "$dir" "Screenshot-$(date +%Y-%m-%d-%H%M%S).png")"
	fi

	if ((OPT_EDIT)); then
		local satty_args=(--filename "$raw")
		((OPT_SAVE)) && satty_args+=(--output-filename "$out")
		# Without a saved file, satty's copy action is the only way out.
		((OPT_CLIPBOARD && !OPT_SAVE)) && satty_args+=(--copy-command "wl-copy --type image/png")
		satty "${satty_args[@]}"
		# satty only writes the output when the user actually saves.
		if ((OPT_SAVE)) && [[ ! -e $out ]]; then
			exit 1
		fi
	fi

	if ((OPT_SAVE && !OPT_EDIT)); then
		cp -- "$raw" "$out"
	fi

	if ((OPT_CLIPBOARD)); then
		if [[ -n $out ]]; then
			wl-copy --type image/png <"$out"
		elif ((!OPT_EDIT)); then
			wl-copy --type image/png <"$raw"
		fi
	fi

	if ((OPT_NOTIFY)); then
		if [[ -n $out ]]; then
			notify-send -a "Screenshot" -i "camera-photo" \
				-h "string:image-path:$out" "Screenshot saved" "$out"
		elif ((OPT_CLIPBOARD)); then
			notify-send -a "Screenshot" -i "camera-photo" \
				"Screenshot copied to clipboard" ""
		fi
	fi
}

# Allow the test suite to source the helpers without capturing anything.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	main "$@"
fi
