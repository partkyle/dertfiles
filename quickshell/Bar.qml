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

  Row {
    id: leftRow
    anchors.left: parent.left
    anchors.leftMargin: Style.moduleHSpacing / 2
    spacing: Style.moduleHSpacing
    height: parent.height

    Layout {}

    Workspaces {
      height: parent.height
    }
  }

  Row {
    id: rightRow
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
    IdleInhibit {}
    NotificationBell {}
    Clock {}
  }

  // Title is pinned to the left edge of the gap the two clusters leave, so it
  // sits just after the workspaces instead of re-centering as the title text
  // changes. It is still capped to the gap so a long title elides rather than
  // running under the right side.
  Item {
    id: titleArea
    anchors.left: leftRow.right
    anchors.right: rightRow.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Title {
      anchors.left: parent.left
      anchors.leftMargin: Style.moduleHSpacing
      maximumTextWidth: Math.max(1, titleArea.width - Style.moduleHSpacing * 2)
    }
  }
}
