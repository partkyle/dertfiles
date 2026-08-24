import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.Commons

// Shell entry point: a single long-running quickshell instance renders
// one bar per screen. App launching is handled by walker (see
// nix/modules/walker.nix).
ShellRoot {
  id: shellRoot

  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData
      screen: modelData
    }
  }
}
