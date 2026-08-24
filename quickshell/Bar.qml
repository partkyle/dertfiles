import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Commons
import qs.widgets

// One bar surface per screen. Layout matches the replaced waybar config:
// workspaces on the left; tray, cpu, memory, network, audio, battery and
// clock on the right.
PanelWindow {
  id: root

  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: Style.barHeight
  color: "transparent"
  exclusiveZone: Style.barHeight

  WlrLayershell.namespace: "partkyle-bar"
  WlrLayershell.layer: WlrLayer.Top

  Rectangle {
    id: background
    anchors.fill: parent
    color: Color.barBackground
  }

  // border-bottom: 1px solid overlay1
  Rectangle {
    anchors.bottom: parent.bottom
    width: parent.width
    height: 1
    color: Color.barBorder
  }

  Workspaces {
    anchors.left: parent.left
    anchors.leftMargin: Style.moduleHSpacing / 2
    height: parent.height
  }

  Row {
    anchors.right: parent.right
    anchors.rightMargin: Style.moduleHSpacing / 2
    spacing: Style.moduleHSpacing
    height: parent.height

    Tray {}
    Cpu {}
    Memory {}
    Network {}
    Audio {}
    Battery {}
    Clock {}
  }
}
