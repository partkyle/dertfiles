import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Current tiling layout for this bar's monitor, shown as an icon: dwindle
// (binary splits), tile/master (master pane + stack), monocle (one fullscreen
// window) and scroller/scrolling (horizontally scrolling columns). The
// compositor is the source of truth, not a file written by a helper program:
// mango pushes per-tag layouts through `mmsg watch all-tags` (layout belongs to
// the active tag, which is per monitor), and under Hyprland a hyprctl poll
// reflects the globally applied layout. `dert <wm> layout` only dispatches the
// switch. Left click cycles.
BarWidget {
  id: root

  // The screen this bar renders on; set by Bar.qml. Mango layouts are per
  // monitor, so this selects the right tag.
  property var screen: null
  readonly property string monitorName: screen ? screen.name : ""

  // Hyprland exports HYPRLAND_INSTANCE_SIGNATURE; mango does not.
  readonly property bool isHyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "") !== ""
  readonly property string wmGroup: isHyprland ? "hypr" : "mango"

  readonly property var layouts: isHyprland
    ? ["dwindle", "master", "monocle", "scrolling"]
    : ["dwindle", "tile", "monocle", "scroller"]

  property string layout: isHyprland ? "dwindle" : "right_tile"

  // `mmsg` reports a layout symbol; map it to the name the icon and cycle list
  // use (mirrors `mmsg get layouts`).
  readonly property var mangoLayoutNames: ({
    "DW": "dwindle",
    "T": "tile",
    "M": "monocle",
    "S": "scroller",
    "G": "grid",
    "K": "deck",
    "F": "fair",
    "CT": "center_tile",
    "RT": "right_tile",
    "VS": "vertical_scroller",
    "VT": "vertical_tile",
    "VG": "vertical_grid",
    "VK": "vertical_deck",
    "VF": "vertical_fair"
  })

  // ~/.local/bin is not on the shell service's PATH, so call dert absolutely.
  readonly property string dertBin: (Quickshell.env("HOME") || "") + "/.local/bin/dert"

  function iconFor(name) {
    if (name === "master" || name === "tile" || name === "right_tile")
      return "󰆥"
    if (name === "monocle")
      return ""
    if (name === "scrolling" || name === "scroller")
      return ""
    return "󰕰"
  }

  // Pull this monitor's active tag layout out of a `mmsg watch all-tags`
  // snapshot. Falls back to whichever monitor has an active tag if the screen
  // name does not match a mango output.
  function applyMangoTags(text) {
    try {
      const monitors = JSON.parse(text).all_tags || []
      const mon = monitors.find(m => m.monitor === root.monitorName)
        || monitors.find(m => (m.tags || []).some(t => t.is_active))
        || monitors[0]
      if (!mon)
        return
      const active = (mon.tags || []).find(t => t.is_active)
      if (active)
        root.layout = root.mangoLayoutNames[active.layout] || active.layout
    } catch (e) {
      // Ignore malformed output; keep the last known layout.
    }
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

  // mango: push stream of tag changes, including the active tag's layout, so
  // the icon tracks every switch regardless of what made it. `mmsg` locates
  // the compositor through MANGO_INSTANCE_SIGNATURE, which mango imports into
  // the user session.
  Process {
    id: mangoWatch
    command: ["mmsg", "watch", "all-tags"]
    running: !root.isHyprland
    stdout: SplitParser {
      onRead: line => root.applyMangoTags(line)
    }
    onExited: {
      // Reconnect if the compositor restarts or the watch drops.
      if (!root.isHyprland)
        mangoRetry.start()
    }
  }

  Timer {
    id: mangoRetry
    interval: 1000
    onTriggered: mangoWatch.running = true
  }

  Process {
    id: evalProc
  }

  // Hyprland: the tiling layout is applied globally, so polling the active
  // workspace reconciles a change made outside the bar.
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
          // Ignore malformed output; keep the last known layout.
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: root.isHyprland
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!layoutProc.running)
        layoutProc.running = true
    }
  }
}
