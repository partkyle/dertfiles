import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Current tiling layout, shown as an icon: dwindle (binary splits),
// tile/master (master pane + stack), monocle (one fullscreen window) and
// scroller/scrolling (horizontally scrolling columns). `dert <wm> layout` sets
// the mode and writes it to a runtime file this widget watches, so keybind and
// CLI switches are instant. Under Hyprland a slow hyprctl poll reconciles
// changes made outside dert; mango's file is authoritative. Left click cycles.
BarWidget {
  id: root

  // Hyprland exports HYPRLAND_INSTANCE_SIGNATURE; mango does not.
  readonly property bool isHyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "") !== ""
  readonly property string wmGroup: isHyprland ? "hypr" : "mango"

  readonly property var layouts: isHyprland
    ? ["dwindle", "master", "monocle", "scrolling"]
    : ["dwindle", "tile", "monocle", "scroller"]

  property string layout: isHyprland ? "dwindle" : "tile"

  // Mirror of the path written by `dert <wm> layout` (bin/dert).
  readonly property string statePath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp")
    + (isHyprland ? "/hypr-layout" : "/mango-layout")
  // ~/.local/bin is not on the shell service's PATH, so call dert absolutely.
  readonly property string dertBin: (Quickshell.env("HOME") || "") + "/.local/bin/dert"

  function iconFor(name) {
    if (name === "master" || name === "tile")
      return "󰆥"
    if (name === "monocle")
      return ""
    if (name === "scrolling" || name === "scroller")
      return ""
    return "󰕰"
  }

  function cycle() {
    const next = layouts[(layouts.indexOf(layout) + 1) % layouts.length]
    layout = next
    evalProc.command = [root.dertBin, root.wmGroup, "layout", next]
    evalProc.running = true
  }

  label: iconFor(layout)
  accent: Color.blue

  onClicked: cycle()

  // Instant updates from `dert <wm> layout`. watchChanges emits fileChanged
  // but does not reload on its own, hence the explicit reload().
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

  // Hyprland-only backstop: reconcile a layout set outside dert.
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
    running: root.isHyprland
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!layoutProc.running)
        layoutProc.running = true
    }
  }
}
