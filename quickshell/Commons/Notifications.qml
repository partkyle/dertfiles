pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "NotificationLogic.js" as Logic

// In-memory history of missed (expired) notifications, shared by the bar's
// bell and the history panel. Notifications the user dismisses or acts on are
// deliberately not recorded — the bell is for what was unattended.
//
// Quickshell destroys a Notification object once it closes, so shell.qml
// snapshots the fields we need into this singleton from each notification's
// `closed` signal while the object is still alive. Expired snapshots are also
// persisted to disk (one JSON file per entry) and reloaded at startup, so a
// shell restart no longer wipes the history. The pure data shaping lives in
// NotificationLogic.js; this file owns the I/O.
QtObject {
  id: root

  // Cap the history so a long-lived session cannot grow it without bound.
  // The on-disk directory is trimmed to the same number (see persistScript).
  readonly property int maxHistory: Logic.MAX_HISTORY

  // Notifications that closed while the history panel was hidden. Reset when
  // the panel opens. Disk-loaded rows are not counted.
  property int unreadCount: 0

  // Whether the history panel is shown. Owned here so the per-screen bell
  // can toggle the single overlay window.
  property bool panelOpen: false

  // State lives under XDG state, not cache: losing it loses real history.
  // Quickshell.stateDir is Quickshell's own internal directory, so the XDG
  // state home is resolved here.
  readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
  readonly property string stateDir: stateHome + "/dert/notifications"
  readonly property string historyDir: stateDir + "/history"
  readonly property string imageDir: stateDir + "/images"

  // Newest first. `ListModel.count` is reactive, unlike ListView.count.
  readonly property ListModel history: ListModel {
    id: historyModel
  }

  Component.onCompleted: loadPersisted()

  // ── file I/O ────────────────────────────────────────────────────────────
  // Every write goes through one shell queue. A notification burst (or a
  // burst plus a clear) runs one command at a time, so a trim can never race
  // the write it is trimming.

  property var commandQueue: []
  property var activeCommand: null

  readonly property Process fileProcess: Process {
    id: fileProcess
    stdout: StdioCollector {
      id: fileStdout
      waitForEnd: true
    }
    onExited: (exitCode, exitStatus) => root.onProcessExited(exitCode)
  }

  // Copy file-backed images and write the entry, then trim the directory to
  // maxHistory. The JSON arrives as an argument, not interpolated into the
  // script, so notification text cannot reach the shell parser.
  readonly property string persistScript: [
    'umask 077',
    'state=$1; stem=$2; max=$3; maxbytes=$4; json=$5',
    'shift 5',
    'hist="$state/history"; imgs="$state/images"',
    'mkdir -p -- "$hist" "$imgs"',
    'while [ "$#" -ge 2 ]; do',
    '  src=$1; dst=$2; shift 2',
    '  [ -f "$src" ] || continue',
    '  size=$(stat -c%s -- "$src" 2>/dev/null) || continue',
    '  case $size in ""|*[!0-9]*) continue ;; esac',
    '  [ "$size" -le "$maxbytes" ] || continue',
    '  tmp="$dst.tmp.$$"',
    '  if timeout 5 cp -- "$src" "$tmp" 2>/dev/null; then',
    '    mv -- "$tmp" "$dst" 2>/dev/null || rm -f -- "$tmp"',
    '  else',
    '    rm -f -- "$tmp"',
    '  fi',
    'done',
    'tmp="$hist/$stem.json.tmp.$$"',
    'if printf "%s\\n" "$json" > "$tmp" && mv -- "$tmp" "$hist/$stem.json"; then :; else rm -f -- "$tmp"; fi',
    'cd -- "$hist" 2>/dev/null || exit 0',
    'ls -1 *.json 2>/dev/null | sort -t- -k1,1nr | tail -n +$((max + 1)) | while IFS= read -r f; do',
    '  s=${f%.json}',
    '  rm -f -- "$f" "$imgs/$s-appIcon" "$imgs/$s-image"',
    'done',
    'exit 0'
  ].join("\n")

  readonly property string loadScript: [
    'hist="$1/history"',
    'if [ -d "$hist" ]; then',
    '  find "$hist" -maxdepth 1 -type f -name "*.json" -exec cat -- {} + 2>/dev/null',
    'fi',
    'exit 0'
  ].join("\n")

  readonly property string deleteScript: [
    'state=$1; shift',
    'hist="$state/history"; imgs="$state/images"',
    'for stem in "$@"; do',
    '  rm -f -- "$hist/$stem.json" "$imgs/$stem-appIcon" "$imgs/$stem-image"',
    'done',
    'exit 0'
  ].join("\n")

  readonly property string clearScript: [
    'state=$1',
    'rm -f -- "$state"/history/*.json "$state"/images/*',
    'exit 0'
  ].join("\n")

  function enqueue(command, done) {
    commandQueue.push({ command: command, done: done || null })
    pumpQueue()
  }

  // Start the next command if one is not already running. `done` callbacks may
  // enqueue follow-up work (e.g. deleting what a load trimmed); pumping is
  // idempotent so a callback cannot leave two processes in flight.
  function pumpQueue() {
    if (activeCommand || commandQueue.length === 0)
      return
    activeCommand = commandQueue.shift()
    fileProcess.command = activeCommand.command
    fileProcess.running = true
  }

  function onProcessExited(exitCode) {
    const finished = activeCommand
    activeCommand = null
    if (finished && finished.done)
      finished.done(exitCode, fileStdout.text)
    pumpQueue()
  }

  // ── history ─────────────────────────────────────────────────────────────

  // Snapshot a notification that expired without being interacted with. Only
  // "missed" notifications are kept: ones the user dismissed or acted on are
  // skipped (see shell.qml).
  function record(notification) {
    const entry = Logic.snapshotOf(notification, Date.now())
    historyModel.insert(0, entry)
    while (historyModel.count > maxHistory)
      historyModel.remove(historyModel.count - 1)
    if (!panelOpen)
      unreadCount += 1
    persist(entry)
  }

  function persist(entry) {
    const prepared = Logic.persistableEntry(entry, imageDir)
    const command = [
      "bash", "-c", persistScript, "dert-notifications",
      stateDir, prepared.stem, String(maxHistory), String(Logic.MAX_IMAGE_BYTES),
      Logic.serializeEntry(prepared.entry)
    ]
    for (let i = 0; i < prepared.copies.length; i++) {
      command.push(prepared.copies[i].source)
      command.push(prepared.copies[i].path)
    }
    enqueue(command)
  }

  function loadPersisted() {
    enqueue([ "bash", "-c", loadScript, "dert-notifications", stateDir ], (exitCode, text) => {
      if (exitCode !== 0)
        return
      const plan = Logic.trimPlan(Logic.parseEntries(text), maxHistory)
      for (let i = 0; i < plan.kept.length; i++)
        historyModel.append(plan.kept[i])
      deleteEntries(plan.evicted)
    })
  }

  function remove(index) {
    if (index < 0 || index >= historyModel.count)
      return
    const entry = historyModel.get(index)
    historyModel.remove(index)
    deleteEntries([ entry ])
  }

  // Delete the on-disk copy of every entry in `entries`, so an entry removed
  // from the panel (or trimmed on load) cannot reappear after a restart.
  function deleteEntries(entries) {
    if (entries.length === 0)
      return
    const stems = []
    for (let i = 0; i < entries.length; i++)
      stems.push(Logic.entryStem(entries[i]))
    enqueue([ "bash", "-c", deleteScript, "dert-notifications", stateDir ].concat(stems))
  }

  function clear() {
    historyModel.clear()
    unreadCount = 0
    enqueue([ "bash", "-c", clearScript, "dert-notifications", stateDir ])
  }

  function showHistory() {
    panelOpen = true
    markAllRead()
  }

  function markAllRead() {
    unreadCount = 0
  }
}
