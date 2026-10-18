pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Backlight state shared by the bar's brightness module and its popup.
//
// Reads come straight from sysfs (world-readable) and are watched, so the
// compositor's brightness keys and `dert bright` update the bar immediately.
// Writes go through brightnessctl so systemd-logind grants the permission;
// the sysfs node itself is owned by root.
QtObject {
  id: root

  // brightnessctl's selected device, e.g. "intel_backlight". Empty when the
  // machine has no backlight (e.g. the desktop), which hides the module.
  property string device: ""
  property int raw: 0
  property int maxRaw: 0

  // brightnessctl's floor; writing 0 would turn the panel off entirely.
  readonly property int minRaw: 1

  readonly property bool available: device !== "" && maxRaw > 0
  readonly property real fraction: available
    ? Math.max(0, Math.min(1, raw / maxRaw))
    : 0
  readonly property int percent: Math.round(fraction * 100)

  readonly property string sysfsDir: device !== "" ? "/sys/class/backlight/" + device : ""

  function applyRaw(text) {
    const value = parseInt(text.trim())
    if (!isNaN(value))
      raw = value
  }

  function applyMax(text) {
    const value = parseInt(text.trim())
    if (!isNaN(value) && value > 0)
      maxRaw = value
  }

  // Ask brightnessctl which backlight it would drive, so the widget matches
  // what `dert bright` and the compositor keybinds act on.
  readonly property Process discover: Process {
    command: ["brightnessctl", "-m", "info"]
    running: true
    stdout: SplitParser {
      onRead: line => {
        const fields = line.trim().split(",")
        if (fields.length >= 5)
          root.device = fields[0]
      }
    }
  }

  // The sysfs nodes are the source of truth, so hardware and software changes
  // both land here. `onFileChanged` re-reads after the inotify notification.
  readonly property FileView rawFile: FileView {
    path: root.sysfsDir !== "" ? root.sysfsDir + "/brightness" : ""
    watchChanges: root.sysfsDir !== ""
    printErrors: false
    onFileChanged: reload()
    onTextChanged: root.applyRaw(text())
  }

  readonly property FileView maxFile: FileView {
    path: root.sysfsDir !== "" ? root.sysfsDir + "/max_brightness" : ""
    printErrors: false
    onTextChanged: root.applyMax(text())
  }

  // ── writes ──────────────────────────────────────────────────────────────
  // Writes are coalesced on a short timer so dragging the slider issues one
  // brightnessctl call per tick instead of one per pointer event.

  property int pendingRaw: -1

  readonly property Timer writeTimer: Timer {
    interval: 40
    onTriggered: root.flush()
  }

  readonly property Process writeProcess: Process {
    // If the write failed (e.g. permission denied), snap back to the value
    // actually on disk instead of keeping the optimistic one.
    onExited: root.applyRaw(root.rawFile.text())
  }

  function setRaw(value) {
    if (!available)
      return
    const clamped = Math.max(minRaw, Math.min(maxRaw, Math.round(value)))
    if (clamped === raw)
      return
    // Optimistic update so the slider tracks the pointer; the sysfs watch
    // then confirms the real value.
    raw = clamped
    pendingRaw = clamped
    writeTimer.restart()
  }

  function setPercent(value) {
    if (available)
      setRaw(value * maxRaw / 100)
  }

  function flush() {
    if (pendingRaw < 0)
      return
    const value = pendingRaw
    pendingRaw = -1
    writeProcess.command = ["brightnessctl", "-q", "-d", device, "set", String(value)]
    writeProcess.running = true
  }

  // ── popup ───────────────────────────────────────────────────────────────
  // The bar module owns none of the popup UI: a single shell-root overlay
  // (BrightnessPopup.qml) follows whichever screen opened it and is offset so
  // its right edge sits under the module.

  property bool panelOpen: false
  property var panelScreen: null
  property real panelRightMargin: 0

  function openPanel(screen, rightMargin) {
    panelScreen = screen
    panelRightMargin = rightMargin
    panelOpen = true
  }

  function closePanel() {
    panelOpen = false
  }
}
