import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.Commons

// Shell entry point, modeled on omarchy quatro's omarchy-shell host: a
// single long-running quickshell instance renders one bar per screen and
// hosts the launcher overlay, summoned via IPC from a Hyprland keybind
// (`qs ipc call launcher toggle`).
ShellRoot {
  id: shellRoot

  property bool launcherOpen: false

  IpcHandler {
    target: "launcher"

    function toggle(): void {
      shellRoot.launcherOpen = !shellRoot.launcherOpen
    }

    function open(): void {
      shellRoot.launcherOpen = true
    }

    function close(): void {
      shellRoot.launcherOpen = false
    }
  }

  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData
      screen: modelData
    }
  }

  Variants {
    model: Quickshell.screens

    Launcher {
      required property var modelData
      screen: modelData
    }
  }
}
