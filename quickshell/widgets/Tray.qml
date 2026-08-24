import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.Commons

// System tray icons (StatusNotifierHost). Left click activates the item,
// like waybar's tray module.
Row {
  id: root

  spacing: 8
  anchors.verticalCenter: parent ? parent.verticalCenter : undefined
  height: parent ? parent.height : 0

  Repeater {
    model: SystemTray.items

    delegate: Item {
      id: trayItem

      required property SystemTrayItem modelData

      anchors.verticalCenter: parent ? parent.verticalCenter : undefined
      implicitWidth: 16
      implicitHeight: 16

      IconImage {
        id: icon
        anchors.fill: parent
        source: trayItem.modelData.icon
        implicitSize: 16
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => trayItem.modelData.activate(mouse.x, mouse.y)
      }
    }
  }
}
