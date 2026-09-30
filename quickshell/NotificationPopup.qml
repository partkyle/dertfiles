import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Wayland

import qs.Commons
import qs.Ui

// Notification popups — replaces mako. A single overlay window follows the
// focused Hyprland monitor and stacks tracked notifications from the
// top-right, just below the bar. The server owns the notification list (see
// shell.qml), so dismissing or expiring a card removes it from view
// automatically.
PanelWindow {
  id: root

  required property NotificationServer server

  // Follow the monitor under the cursor. Hyprland's `focusedMonitor` tracks the
  // mouse (`follow_mouse = 1`), so we update whenever it changes. We never
  // fall back to screens[0]: at startup `focusedMonitor` can be null, and
  // latching onto the first screen is what used to put the first notification
  // on the wrong monitor.
  property var popupScreen: null

  function refreshPopupScreen() {
    const monitor = Hyprland.focusedMonitor
    if (!monitor)
      return
    const screens = Quickshell.screens
    for (let i = 0; i < screens.length; i++) {
      const m = Hyprland.monitorFor(screens[i])
      if (m && m.name === monitor.name) {
        popupScreen = screens[i]
        return
      }
    }
  }

  Component.onCompleted: refreshPopupScreen()
  onNotificationCountChanged: refreshPopupScreen()

  Connections {
    target: Hyprland
    function onFocusedMonitorChanged() { root.refreshPopupScreen() }
  }

  // Never overflow the screen; the list scrolls once it is full.
  readonly property real maxHeight: popupScreen
    ? popupScreen.height - (Style.barHeight + Style.moduleHSpacing) - 16
    : 400

  readonly property var notificationModel: server ? server.trackedNotifications : null
  readonly property int notificationCount: notificationModel ? notificationModel.values.length : 0

  screen: popupScreen

  anchors {
    top: true
    right: true
  }
  margins.top: Style.barHeight + Style.moduleHSpacing
  margins.right: Style.moduleHSpacing + 4

  // Fixed surface height (capped to the available screen space): resizing a
  // layer surface while cards animate makes the compositor scale the previous
  // buffer, which ghosts/smears the card outlines. A fixed surface avoids
  // that entirely. The `mask` limits clicks to the card stack so the
  // transparent remainder passes through to windows below.
  implicitWidth: 360
  implicitHeight: maxHeight
  visible: notificationCount > 0
  exclusionMode: ExclusionMode.Ignore
  focusable: false
  color: "transparent"

  WlrLayershell.namespace: "partkyle-notifications"
  WlrLayershell.layer: WlrLayer.Overlay

  mask: Region {
    item: maskItem
  }

  // Bounds of the visible stack; only this region accepts clicks.
  Item {
    id: maskItem
    anchors.top: parent.top
    width: parent.width
    height: list.contentHeight
  }

  ListView {
    id: list
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    // Fixed viewport: a zero-height viewport would never instantiate
    // delegates, so contentHeight must be measured from a real viewport.
    // The surface itself is fixed at maxHeight (see above).
    height: root.maxHeight
    spacing: 8
    clip: true
    interactive: contentHeight > root.height
    boundsBehavior: Flickable.StopAtBounds
    model: root.notificationModel

    delegate: NotificationCard {
      required property var modelData
      notification: modelData
      width: list.width
    }

    add: Transition {
      NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
    }
    remove: Transition {
      NumberAnimation { property: "opacity"; to: 0; duration: 150 }
    }
    displaced: Transition {
      NumberAnimation { property: "y"; duration: 150; easing.type: Easing.OutCubic }
    }
  }
}
