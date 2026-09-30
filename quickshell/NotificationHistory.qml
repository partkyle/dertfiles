import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.Commons
import qs.Ui

// Notification history panel — the list behind the bar's bell. A single
// overlay window follows the focused Hyprland monitor, like
// NotificationPopup, and shows the snapshots collected in
// Commons/Notifications.qml. Toggled by the bell via Notifications.panelOpen.
PanelWindow {
  id: root

  // Follow the monitor under the cursor, exactly like NotificationPopup:
  // Hyprland's `focusedMonitor` tracks the mouse (`follow_mouse = 1`), and we
  // never fall back to screens[0] so the panel cannot land on the wrong
  // monitor before the first focusedMonitor update.
  property var panelScreen: null

  function refreshPanelScreen() {
    const monitor = Hyprland.focusedMonitor
    if (!monitor)
      return
    const screens = Quickshell.screens
    for (let i = 0; i < screens.length; i++) {
      const m = Hyprland.monitorFor(screens[i])
      if (m && m.name === monitor.name) {
        panelScreen = screens[i]
        return
      }
    }
  }

  Component.onCompleted: refreshPanelScreen()

  Connections {
    target: Hyprland
    function onFocusedMonitorChanged() { root.refreshPanelScreen() }
  }

  // Never overflow the screen; the list scrolls once it is full.
  readonly property real maxHeight: panelScreen
    ? panelScreen.height - (Style.barHeight + Style.moduleHSpacing) - 16
    : 400

  screen: panelScreen

  anchors {
    top: true
    right: true
  }
  margins.top: Style.barHeight + Style.moduleHSpacing
  margins.right: Style.moduleHSpacing + 4

  // Fixed layer-surface height (same reason as NotificationPopup: resizing a
  // layer surface while content animates smears the previous buffer). The
  // visible `panel` rectangle is sized to its content and used as the input
  // mask, so clicks outside it pass through.
  implicitWidth: 360
  implicitHeight: maxHeight
  visible: Notifications.panelOpen
  exclusionMode: ExclusionMode.Ignore
  focusable: false
  color: "transparent"

  WlrLayershell.namespace: "partkyle-notification-history"
  WlrLayershell.layer: WlrLayer.Overlay

  mask: Region {
    item: panel
  }

  Rectangle {
    id: panel
    // Inner padding so the cards sit inside the panel border instead of
    // covering it.
    readonly property int pad: 6
    anchors.top: parent.top
    anchors.right: parent.right
    width: parent.width
    height: header.height + (Notifications.history.count > 0
      ? 2 * pad + Math.min(list.contentHeight, list.viewportHeight)
      : emptyText.implicitHeight + 24)
    radius: 8
    color: Color.base
    border.width: 2
    border.color: Color.mauve
    clip: true

    Item {
      id: header
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: 34

      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        text: "Notifications"
        color: Color.text
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize
        font.bold: true
      }

      Text {
        id: clearButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 12
        visible: Notifications.history.count > 0
        text: "Clear all"
        color: clearMouse.containsMouse ? Color.hoverText : Color.overlay1
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize - 2

        MouseArea {
          id: clearMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Notifications.clear()
            Notifications.panelOpen = false
          }
        }
      }

      Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Color.surface0
      }
    }

    // Fixed viewport: a zero-height ListView never instantiates delegates,
    // so contentHeight would stay 0 and the panel could never size itself.
    ListView {
      id: list
      anchors.top: header.bottom
      anchors.topMargin: panel.pad
      anchors.left: parent.left
      anchors.leftMargin: panel.pad
      anchors.right: parent.right
      anchors.rightMargin: panel.pad
      height: viewportHeight
      spacing: 1
      clip: true
      interactive: contentHeight > height
      boundsBehavior: Flickable.StopAtBounds
      model: Notifications.history
      visible: Notifications.history.count > 0

      readonly property real viewportHeight: root.maxHeight - header.height - 2 * panel.pad

      delegate: NotificationHistoryCard {
        width: list.width
      }
    }

    Text {
      id: emptyText
      visible: Notifications.history.count === 0
      anchors.top: header.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 12
      text: "No notifications"
      horizontalAlignment: Text.AlignHCenter
      color: Color.overlay0
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSize - 2
    }
  }
}
