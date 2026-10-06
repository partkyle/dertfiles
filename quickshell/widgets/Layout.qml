import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Current Hyprland tiling layout, shown as an icon: dwindle (binary splits),
// master (master pane + stack), monocle (one fullscreen window) and scrolling
// (horizontally scrolling columns). `dert hypr layout` sets the mode and writes
// it to a file this widget watches, so keybind and CLI switches are instant; a
// slow hyprctl poll reconciles changes made outside dert. Left click cycles.
BarWidget {
  id: root

  readonly property var layouts: ["dwindle", "master", "monocle", "scrolling"]
  property string layout: "dwindle"

  // Mirror of the path written by `dert hypr layout` (bin/dert).
  readonly property string statePath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/hypr-layout"
  // ~/.local/bin is not on the shell service's PATH, so call dert absolutely.
  readonly property string dertBin: (Quickshell.env("HOME") || "") + "/.local/bin/dert"

  function iconFor(name) {
    if (name === "master")
      return "󰆥"
    if (name === "monocle")
      return ""
    if (name === "scrolling")
      return ""
    return "󰕰"
  }

  function cycle() {
    const next = layouts[(layouts.indexOf(layout) + 1) % layouts.length]
    layout = next
    evalProc.command = [root.dertBin, "hypr", "layout", next]
    evalProc.running = true
  }

  label: iconFor(layout)
  accent: Color.blue

  onClicked: cycle()

  // Instant updates from `dert hypr layout`; the poll below is only a backstop.
  // watchChanges emits fileChanged but does not reload on its own, hence the
  // explicit reload().
  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      const mode = text().trim()
      if (mode)
        root.layout = mode
    }
  }

  Process {
    id: layoutProc
    command: ["hyprctl", "-j", "activeworkspace"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const ws = JSON.parse(text)
          if (ws && ws.tiledLayout)
            root.layout = ws.tiledLayout
        } catch (e) {
          // Ignore malformed output; keep the last known mode.
        }
      }
    }
  }

  Process {
    id: evalProc
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!layoutProc.running)
        layoutProc.running = true
    }
  }
}
