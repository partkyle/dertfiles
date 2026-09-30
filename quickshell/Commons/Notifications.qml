pragma Singleton

import QtQuick

// In-memory history of missed (expired) notifications, shared by the bar's
// bell and the history panel. Notifications the user dismisses or acts on are
// deliberately not recorded — the bell is for what was unattended.
// Quickshell destroys a Notification object once it closes, so shell.qml
// snapshots the fields we need into this singleton from each notification's
// `closed` signal while the object is still alive. This is the only seam
// between the notification server and the bar UI.
QtObject {
  id: root

  // Cap the history so a long-lived session cannot grow it without bound.
  readonly property int maxHistory: 50

  // Notifications that closed while the history panel was hidden. Reset when
  // the panel opens.
  property int unreadCount: 0

  // Whether the history panel is shown. Owned here so the per-screen bell
  // can toggle the single overlay window.
  property bool panelOpen: false

  // Newest first. `ListModel.count` is reactive, unlike ListView.count.
  readonly property ListModel history: ListModel {
    id: historyModel
  }

  // Snapshot a notification that expired without being interacted with. Only
  // "missed" notifications are kept: ones the user dismissed or acted on are
  // skipped (see shell.qml).
  function record(notification) {
    historyModel.insert(0, {
      id: notification.id,
      appName: notification.appName,
      appIcon: notification.appIcon,
      summary: notification.summary,
      body: notification.body,
      urgency: notification.urgency,
      image: notification.image,
      timestamp: Date.now()
    })
    while (historyModel.count > maxHistory)
      historyModel.remove(historyModel.count - 1)
    if (!panelOpen)
      unreadCount += 1
  }

  function remove(index) {
    if (index >= 0 && index < historyModel.count)
      historyModel.remove(index)
  }

  function clear() {
    historyModel.clear()
    unreadCount = 0
  }

  function markAllRead() {
    unreadCount = 0
  }
}
