import QtQuick
import Quickshell.Services.Notifications

import qs.Commons

// One row in the notification history panel: a snapshot of a closed
// notification (see Commons/Notifications.qml). Unlike Ui/NotificationCard
// there is no live Notification behind it, so expiry and actions are gone;
// the row shows the captured fields and can be removed from history.
// `model` and `index` are injected by the ListView delegate.
Item {
  id: root

  required property var model
  required property int index

  readonly property color urgencyColor: model.urgency === NotificationUrgency.Critical ? Color.red
    : model.urgency === NotificationUrgency.Low ? Color.overlay0
    : Color.mauve

  readonly property string iconSource: IconSource.resolve(model.appIcon)

  implicitWidth: card.width
  implicitHeight: card.height

  Rectangle {
    id: card
    width: parent.width
    height: layout.implicitHeight + 16
    radius: 6
    color: mouse.containsMouse ? Color.surface0 : Color.mantle
    border.width: 1
    border.color: Color.surface0

    // Urgency stripe, matching the popup card border colour.
    Rectangle {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 3
      color: root.urgencyColor
    }

    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
    }

    Text {
      id: removeButton
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 8
      text: "󰅖"
      color: removeMouse.containsMouse ? Color.text : Color.overlay0
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSize - 1

      MouseArea {
        id: removeMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifications.remove(root.index)
      }
    }

    Column {
      id: layout
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.leftMargin: 12
      anchors.rightMargin: 28
      anchors.topMargin: 8
      spacing: 4

      Item {
        width: parent.width
        height: Math.max(headerIcon.height, headerApp.height)

        Image {
          id: headerIcon
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          visible: root.iconSource !== "" && status === Image.Ready
          width: 16
          height: 16
          sourceSize: Qt.size(16, 16)
          source: root.iconSource
        }

        Text {
          id: headerApp
          anchors.left: headerIcon.visible ? headerIcon.right : parent.left
          anchors.leftMargin: headerIcon.visible ? 8 : 0
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - (headerIcon.visible ? headerIcon.width + 8 : 0) - headerTime.width - 8
          text: root.model.appName
          color: Color.mauve
          elide: Text.ElideRight
          textFormat: Text.PlainText
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSize - 2
          font.bold: true
        }

        Text {
          id: headerTime
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: Qt.formatDateTime(new Date(root.model.timestamp), "h:mm AP")
          color: Color.overlay0
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSize - 3
        }
      }

      Text {
        width: parent.width
        visible: text !== ""
        text: root.model.summary
        color: Color.text
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        textFormat: Text.PlainText
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize - 1
        font.bold: true
      }

      Text {
        width: parent.width
        visible: text !== ""
        text: root.model.body
        color: Color.subtext0
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        textFormat: Text.PlainText
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize - 2
      }
    }
  }
}
