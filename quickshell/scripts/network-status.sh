#!/usr/bin/env bash
# Network status for the quickshell bar. Single line out:
#   wifi\t<ssid> | ethernet | disconnected
#
# Uses systemd-networkd + iwd (this system does not run NetworkManager).
ansi="s/\x1b\[[0-9;]*m//g"

dev=$(iwctl device list 2>/dev/null | sed "$ansi" | awk '$NF=="station" {print $1; exit}')
if [ -n "$dev" ]; then
  ssid=$(iwctl station "$dev" show 2>/dev/null | sed "$ansi" \
    | awk '/^ *Connected network/ {sub(/^ *Connected network[ \t]+/, ""); sub(/[ \t]+$/, ""); print}')
  if [ -n "$ssid" ]; then
    printf 'wifi\t%s\n' "$ssid"
    exit 0
  fi
fi

if networkctl list --no-legend 2>/dev/null | grep -qE 'ether[[:space:]]+(routable|degraded|carrier)'; then
  echo ethernet
  exit 0
fi

echo disconnected
