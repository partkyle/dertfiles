import QtQuick
import Quickshell.Hyprland

import qs.Commons
import qs.Ui

// Focused Hyprland window, shown as "[N/M] title" where N is the window's
// position in its workspace's toplevel list and M is the number of windows
// there. Fully event-driven: every value is a binding on Quickshell's
// Hyprland IPC models, which are fed by Hyprland's event socket, so there is
// no polling and updates land on the same event that changed focus, title or
// the window list.
BarWidget {
  id: root

  // activeToplevel is authoritative while it points at a window on the focused
  // workspace, but Quickshell 0.3.1 never clears it when focus moves to an
  // empty workspace (its activewindowv2 handler bails on the empty address),
  // so trusting it blindly leaves the last workspace's title up. It also stays
  // null until the first `activewindow` event after the shell starts. On a
  // restart (e.g. a config change) that leaves the title blank until focus
  // moves, so fall back to the window with the lowest focusHistoryID — the
  // initial `hyprctl clients` query that populates the models already carries it.
  readonly property var focusedToplevel: {
    const active = Hyprland.activeToplevel
    const ws = Hyprland.focusedWorkspace
    if (active && active.workspace && ws && active.workspace.id === ws.id)
      return active
    if (!ws)
      return active
    const toplevels = ws.toplevels.values
    let best = null
    let bestId = Infinity
    for (let i = 0; i < toplevels.length; i++) {
      const toplevel = toplevels[i]
      const history = toplevel.lastIpcObject ? toplevel.lastIpcObject.focusHistoryID : undefined
      if (history !== undefined && history < bestId) {
        bestId = history
        best = toplevel
      }
    }
    return best
  }

  // The focused window's workspace, so special workspaces and multi-monitor
  // setups count the right set of windows.
  readonly property var workspace: {
    const toplevel = focusedToplevel
    return toplevel ? toplevel.workspace : Hyprland.focusedWorkspace
  }

  readonly property var toplevels: workspace ? workspace.toplevels.values : []
  readonly property int focusedIndex: {
    const toplevel = focusedToplevel
    return toplevel ? toplevels.indexOf(toplevel) : -1
  }

  label: {
    const toplevel = focusedToplevel
    if (!toplevel || focusedIndex < 0)
      return ""
    return "[" + (focusedIndex + 1) + "/" + toplevels.length + "] " + toplevel.title
  }

  accent: Color.blue
}
