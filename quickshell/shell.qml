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
    onNotification: notification => notification.tracked = true
  }

  NotificationPopup {
    server: notificationServer
  }
}
