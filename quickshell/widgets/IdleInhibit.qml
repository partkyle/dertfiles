import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Toggle for hypridle's lock / display-sleep actions. Left click inhibits idle
// actions for the configured default duration (see `dert idle default`); right
// click re-enables them immediately. While inhibited the icon is "unlocked"
// and the label counts down the remaining time. State is shared with hypridle
// via hypr/scripts/idle-inhibit.sh, so the daemon honours the same stamp and
// `dert idle` drives the same lock.
BarWidget {
  id: root

  property bool inhibited: false
  property int remaining: 0 // seconds until idle actions resume

  // Expanded by the shell that runs it, so no dependency on the home dir.
  readonly property string script: "$HOME/.config/hypr/scripts/idle-inhibit.sh"

  function refresh() {
    if (!statusProc.running)
      statusProc.running = true
  }

  function toggle() {
    actionProc.command = ["sh", "-c", "exec " + script + " toggle"]
    actionProc.running = true
  }

  function enable() {
    actionProc.command = ["sh", "-c", "exec " + script + " on"]
    actionProc.running = true
  }

  function formatRemaining(seconds) {
    const minutes = Math.ceil(seconds / 60)
    return minutes >= 60 ? Math.floor(minutes / 60) + "h " + (minutes % 60) + "m"
      : minutes + "m"
  }

  label: inhibited ? "󰌿 " + formatRemaining(remaining) : "󰌾"
  accent: inhibited ? Color.peach : Color.green

  onClicked: toggle()
  onRightClicked: enable()

  Process {
    id: statusProc
    command: ["sh", "-c", "exec " + root.script + " status"]
    stdout: SplitParser {
      onRead: line => {
        const parts = line.trim().split(/\s+/)
        root.inhibited = parts[0] === "off"
        root.remaining = parts.length > 1 ? parseInt(parts[1]) : 0
      }
    }
  }

  Process {
    id: actionProc
    onExited: root.refresh()
  }

  // Keeps the countdown current, notices expiry on its own, and picks up
  // changes made by `dert idle` without waiting for the next click.
  Timer {
    interval: 10000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
