import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Commons
import qs.Ui

// Focused window title, driven by the generic foreign-toplevel protocol
// (Quickshell.Wayland.ToplevelManager), so it works on mango and Hyprland.
// The old "[N/M] title" position/count was Hyprland-specific and is gone.
BarWidget {
  id: root

  readonly property var toplevel: ToplevelManager.activeToplevel

  label: toplevel ? toplevel.title : ""

  accent: Color.blue
}
