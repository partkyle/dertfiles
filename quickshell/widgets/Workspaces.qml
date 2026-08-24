import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.Commons

// Hyprland workspaces: digits with the focused one highlighted, click to
// activate. Mirrors the waybar hyprland/workspaces module.
Row {
  id: root

  spacing: 2

  // Sorted workspace ids, rebuilt whenever Hyprland's workspace list
  // changes (same approach as omarchy quatro's Workspaces widget).
  readonly property var workspaceIds: {
    const ids = Hyprland.workspaces.values
      .map(ws => ws.id)
      .filter(id => id > 0)
    ids.sort((a, b) => a - b)
    return ids
  }

  Repeater {
    model: root.workspaceIds

    delegate: Rectangle {
      id: wsButton

      required property int modelData

      readonly property bool focused: Hyprland.focusedWorkspace !== null
        && Hyprland.focusedWorkspace.id === wsButton.modelData

      anchors.verticalCenter: parent ? parent.verticalCenter : undefined
      height: parent ? parent.height - Style.moduleVMargin * 2 : Style.barHeight
      implicitWidth: wsLabel.implicitWidth + 8
      color: wsMouse.containsMouse ? Color.surface0 : "transparent"

      // hover top border, like waybar's button:hover
      Rectangle {
        visible: wsMouse.containsMouse
        anchors.top: parent.top
        width: parent.width
        height: Style.accentBorderWidth
        color: Color.hoverText
      }

      Text {
        id: wsLabel
        anchors.centerIn: parent
        text: String(wsButton.modelData)
        color: wsButton.focused
          ? Color.mauve
          : wsMouse.containsMouse ? Color.hoverText : Color.barText
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize
        font.bold: true
      }

      MouseArea {
        id: wsMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsButton.modelData}" })`)
      }
    }
  }
}
