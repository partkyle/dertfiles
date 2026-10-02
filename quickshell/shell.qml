import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

import qs.Commons

// Shell entry point: a single long-running quickshell instance renders
// one bar per screen. App launching is handled by rofi.
ShellRoot {
  id: shellRoot

  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData
      screen: modelData
    }
  }

  // Notification daemon, replacing mako. Advertise the features the popup
  // renders; incoming notifications are tracked so the server keeps them
  // alive until they are dismissed or expire.
  NotificationServer {
    id: notificationServer
    actionsSupported: true
    imageSupported: true
    onNotification: notification => {
      notification.tracked = true
      // Only keep notifications that expire without being touched. Ones the
      // user dismisses or acts on are deliberately left out of the history,
      // so the bell is a list of what was missed. The Notification object is
      // destroyed shortly after the signal, so the fields must be copied here.
      notification.closed.connect(reason => {
        if (reason === NotificationCloseReason.Expired)
          Notifications.record(notification)
      })
    }
  }

  NotificationPopup {
    server: notificationServer
  }

  NotificationHistory {}

  // Minimal control surface for `qs ipc call notifications …` (wrapped by
  // `dert notif`). Kept tiny on purpose — persistence is the point, not a
  // second notification API.
  IpcHandler {
    target: "notifications"
    function ping(): string { return "pong" }
    function showHistory(): void { Notifications.showHistory() }
    function clear(): void { Notifications.clear() }
  }
}
