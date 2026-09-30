import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import qs.Commons

// A single notification card, replacing one mako popup. The border colour
// reflects urgency; an optional app icon / attached image, summary, body and
// per-notification action buttons are shown. The card expires on its own
// using the timeout requested by the sender, falling back to the per-urgency
// defaults from the mako config it replaces. Clicking the card invokes the
// notification's default action when there is one, otherwise it dismisses.
Item {
  id: root

  required property var notification

  readonly property color urgencyColor: notification.urgency === NotificationUrgency.Critical ? Color.red
    : notification.urgency === NotificationUrgency.Low ? Color.overlay0
    : Color.mauve

  // expireTimeout follows the D-Bus Notify argument: milliseconds, where
  // -1 means "server default", 0 means "never expire", and >0 is the delay.
  // (Quickshell's property docs claim seconds, but it passes the raw value
  // through, which is milliseconds in practice.)
  readonly property real requestedTimeout: notification.expireTimeout
  readonly property bool neverExpires: requestedTimeout === 0
  readonly property real timeoutMs: requestedTimeout > 0 ? requestedTimeout
    : notification.urgency === NotificationUrgency.Critical ? 8000
    : notification.urgency === NotificationUrgency.Low ? 3000
    : 5000

  // Icons are either a theme icon name (sender-provided or from the desktop
  // entry) or, for web notifications from Chromium-based browsers, a file://
  // URL to the site favicon (passed as app_icon). Theme names go through the
  // icon provider; file URLs and absolute paths are loaded directly, since
  // Quickshell.iconPath() only understands theme names.
  readonly property string iconSource: {
    const icon = notification.appIcon
    if (icon === "")
      return ""
    if (icon.startsWith("file:") || icon.startsWith("/"))
      return icon
    return Quickshell.iconPath(icon, true)
  }

  readonly property var defaultAction: {
    const actions = notification.actions
    for (let i = 0; i < actions.length; i++)
      if (actions[i].identifier === "default")
        return actions[i]
    return null
  }

  // "default" is triggered by clicking the card, so it is not a button.
  readonly property var buttons: {
    const actions = notification.actions
    const visible = []
    for (let i = 0; i < actions.length; i++)
      if (actions[i].identifier !== "default")
        visible.push(actions[i])
    return visible
  }

  implicitWidth: card.width
  implicitHeight: card.height

  Timer {
    running: !root.neverExpires
    interval: root.timeoutMs
    onTriggered: root.notification.expire()
  }

  Rectangle {
    id: card
    width: parent.width
    height: layout.implicitHeight + 24
    radius: 8
    color: Color.base
    border.width: 2
    border.color: root.urgencyColor

    MouseArea {
      anchors.fill: parent
      cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: {
        if (root.defaultAction)
          root.defaultAction.invoke()
        else
          root.notification.dismiss()
      }
    }

    Column {
      id: layout
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 12
      spacing: 6

      // Header: app icon, app name and close button.
      Item {
        width: parent.width
        height: 20

        Row {
          id: header
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - closeButton.width - 8
          spacing: 8

          Image {
            id: appIcon
            visible: root.iconSource !== "" && status === Image.Ready
            width: 20
            height: 20
            sourceSize: Qt.size(20, 20)
            source: root.iconSource
          }

          Text {
            width: parent.width - (appIcon.visible ? appIcon.width + header.spacing : 0)
            text: root.notification.appName
            color: Color.mauve
            elide: Text.ElideRight
            textFormat: Text.PlainText
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSize - 2
            font.bold: true
          }
        }

        Text {
          id: closeButton
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: "󰅖"
          color: closeMouse.containsMouse ? Color.text : Color.overlay1
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSize - 1

          MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.notification.dismiss()
          }
        }
      }

      // Attached image (album art, screenshot, profile picture, ...).
      Image {
        visible: root.notification.image !== ""
        width: parent.width
        height: visible ? 120 : 0
        source: root.notification.image
        fillMode: Image.PreserveAspectFit
        asynchronous: true
      }

      Text {
        width: parent.width
        visible: text !== ""
        text: root.notification.summary
        color: Color.text
        wrapMode: Text.WordWrap
        textFormat: Text.PlainText
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize
        font.bold: true
      }

      Text {
        width: parent.width
        visible: text !== ""
        text: root.notification.body
        color: Color.subtext0
        wrapMode: Text.WordWrap
        textFormat: Text.PlainText
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize - 2
      }

      Row {
        width: parent.width
        spacing: 6
        visible: root.buttons.length > 0

        Repeater {
          model: root.buttons

          delegate: Rectangle {
            required property var modelData

            implicitWidth: actionLabel.implicitWidth + 20
            height: 26
            radius: 4
            color: actionMouse.containsMouse ? Color.surface0 : Color.mantle
            border.width: 1
            border.color: Color.surface0

            Text {
              id: actionLabel
              anchors.centerIn: parent
              text: modelData.text
              color: Color.mauve
              textFormat: Text.PlainText
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSize - 2
              font.bold: true
            }

            MouseArea {
              id: actionMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              // invoke() dismisses the notification itself unless it is resident.
              onClicked: modelData.invoke()
            }
          }
        }
      }
    }
  }
}
