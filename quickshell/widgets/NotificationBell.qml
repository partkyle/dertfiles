import QtQuick

import qs.Commons
import qs.Ui

// Notification bell: shows the unread count and toggles the notification
// history panel (quickshell/NotificationHistory.qml). Left click opens the
// panel and marks everything read; right click clears the history.
BarWidget {
  id: root

  label: Notifications.unreadCount > 0
    ? "󰂚 " + Notifications.unreadCount
    : "󰂚"
  accent: Notifications.unreadCount > 0 ? Color.mauve : Color.overlay0

  onClicked: {
    Notifications.panelOpen = !Notifications.panelOpen
    if (Notifications.panelOpen)
      Notifications.markAllRead()
  }
  onRightClicked: Notifications.clear()
}
