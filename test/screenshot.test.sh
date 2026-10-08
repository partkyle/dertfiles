#!/usr/bin/env bash
# Tests for nix/hypr/scripts/screenshot.sh. Run with:
#   bash test/screenshot.test.sh

set -uo pipefail

script="$(cd "$(dirname "$0")/.." && pwd)/nix/hypr/scripts/screenshot.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home"

# Fake the external tools so both the helpers and main() can run without a
# compositor, grim, slurp or satty installed.
cat >"$tmp/bin/hyprctl" <<'HYPRCTL'
#!/usr/bin/env bash
case "${1:-}" in
activewindow)
  if [[ ${FAKE_WINDOW:-yes} == yes ]]; then
    printf 'Window 0xabc -> foot:\n\tat: 3844,1301\n\tsize: 712,1255\n\tclass: foot\n'
  else
    printf 'Invalid\n'
  fi
  ;;
monitors)
  printf 'Monitor DP-1 (ID 0):\n\tfocused: no\n\tactive workspace: 1\n'
  printf '\nMonitor DP-2 (ID 1):\n\tfocused: yes\n\tactive workspace: 2\n'
  ;;
esac
HYPRCTL

cat >"$tmp/bin/slurp" <<'SLURP'
#!/usr/bin/env bash
printf '10,20 100x50\n'
SLURP

cat >"$tmp/bin/grim" <<'GRIM'
#!/usr/bin/env bash
printf 'PNGDATA'
GRIM

cat >"$tmp/bin/wl-copy" <<'WLCOPY'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$WL_COPY_ARGS"
cat >"$WL_COPY_STDIN"
WLCOPY

cat >"$tmp/bin/satty" <<'SATTY'
#!/usr/bin/env bash
out=""
while (($#)); do
  case "$1" in
  --output-filename)
    out=$2
    shift
    ;;
  --copy-command)
    printf '%s' "$2" >"$SATTY_COPY_CMD"
    shift
    ;;
  esac
  shift
done
[[ -n $out ]] && printf 'ANNOTATED' >"$out"
SATTY

cat >"$tmp/bin/notify-send" <<'NOTIFY'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$NOTIFY_LOG"
NOTIFY

chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$PATH"

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

# ── argument parsing ────────────────────────────────────────────────────────
parse_args
check "defaults to region" "region" "$MODE"
check "defaults to clipboard" "1" "$OPT_CLIPBOARD"
check "defaults to save" "1" "$OPT_SAVE"
check "defaults to notify" "1" "$OPT_NOTIFY"

parse_args window --edit --no-save --no-clipboard --no-notify
check "parses mode" "window" "$MODE"
check "parses --edit" "1" "$OPT_EDIT"
check "parses --no-save" "0" "$OPT_SAVE"
check "parses --no-clipboard" "0" "$OPT_CLIPBOARD"
check "parses --no-notify" "0" "$OPT_NOTIFY"

parse_args region --dir /some/dir
check "parses --dir" "/some/dir" "$OPT_DIR"

parse_args full --no-save
check "resets edit between calls" "0" "$OPT_EDIT"
check "resets dir between calls" "" "$OPT_DIR"

parse_args bogus >/dev/null 2>&1
check "rejects unknown mode" "2" "$?"

parse_args --bogus >/dev/null 2>&1
check "rejects unknown option" "2" "$?"

usage_text="$(parse_args --help)"
check "help returns a distinct code" "3" "$?"
case "$usage_text" in
*"screenshot.sh [mode]"*) printf 'ok   help prints usage\n' ;;
*)
  printf 'FAIL help prints usage\n' >&2
  failures=$((failures + 1))
  ;;
esac

# ── geometry helpers ────────────────────────────────────────────────────────
export FAKE_WINDOW=yes
check "focused window geometry" "3844,1301 712x1255" "$(focused_window_geometry)"

FAKE_WINDOW=no
check "no focused window fails" "1" "$(focused_window_geometry >/dev/null 2>&1; echo $?)"
export FAKE_WINDOW=yes

check "focused output" "DP-2" "$(focused_output)"

# ── output paths ────────────────────────────────────────────────────────────
SCREENSHOT_DIR="$tmp/shots"
check "SCREENSHOT_DIR overrides" "$tmp/shots" "$(default_dir)"

check "unique path is unchanged when free" "$tmp/a.png" "$(unique_path "$tmp" a.png)"
touch "$tmp/a.png"
check "unique path suffixes a collision" "$tmp/a-1.png" "$(unique_path "$tmp" a.png)"
touch "$tmp/a-1.png"
check "unique path keeps incrementing" "$tmp/a-2.png" "$(unique_path "$tmp" a.png)"

# ── end-to-end capture ──────────────────────────────────────────────────────
run_script() {
  PATH="$tmp/bin:$PATH" HOME="$tmp/home" \
    WL_COPY_ARGS="$tmp/wl-copy.args" WL_COPY_STDIN="$tmp/wl-copy.out" \
    SATTY_COPY_CMD="$tmp/satty.copy" NOTIFY_LOG="$tmp/notify.log" \
    bash "$script" "$@"
}

png_count() { [[ -d $1 ]] && find "$1" -name '*.png' | wc -l | tr -d ' ' || echo 0; }

run_script region --no-notify --dir "$tmp/shots1"
check "region saves one file" "1" "$(png_count "$tmp/shots1")"
check "saved file holds the capture" "PNGDATA" "$(cat "$tmp"/shots1/*.png)"
check "clipboard holds the capture" "PNGDATA" "$(cat "$tmp/wl-copy.out")"
check "clipboard is typed as png" "--type image/png" "$(cat "$tmp/wl-copy.args")"

FAKE_WINDOW=no run_script window --no-notify --dir "$tmp/shots2"
check "no focused window exits 1" "1" "$?"
check "failure saves nothing" "0" "$(png_count "$tmp/shots2")"
export FAKE_WINDOW=yes

run_script full --dir "$tmp/shots3"
check "success notifies" "1" "$([[ -s $tmp/notify.log ]] && echo 1 || echo 0)"

run_script region --edit --dir "$tmp/shots4"
check "satty output is saved" "ANNOTATED" "$(cat "$tmp"/shots4/*.png)"
check "annotated image reaches the clipboard" "ANNOTATED" "$(cat "$tmp/wl-copy.out")"

if ((failures > 0)); then
  printf '\n%d test(s) failed\n' "$failures" >&2
  exit 1
fi
printf '\nall tests passed\n'
