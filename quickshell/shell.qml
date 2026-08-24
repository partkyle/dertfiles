import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Commons

// Shell entry point. One bar per screen, modeled on omarchy quatro's
// omarchy-shell host: a single long-running quickshell instance renders
// the bar on every connected monitor.
ShellRoot {
  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData
      screen: modelData
    }
  }
}
