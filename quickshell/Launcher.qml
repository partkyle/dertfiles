import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import qs.Commons
import "Commons/AppSearch.js" as AppSearch

// App launcher overlay (replaces rofi -show drun). One overlay per screen;
// the shell exposes `launcherOpen` and the "launcher" IPC target, so
// `qs ipc call launcher toggle` from a Hyprland keybind summons it.
PanelWindow {
  id: root

  property bool active: shellRoot.launcherOpen

  screen: modelData
  visible: active
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  color: "transparent"

  WlrLayershell.namespace: "partkyle-launcher"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore

  onActiveChanged: {
    if (active) {
      searchField.clear()
      searchField.forceActiveFocus()
    }
  }

  function close() {
    shellRoot.launcherOpen = false
  }

  function launch(entry) {
    close()
    if (entry)
      entry.execute()
  }

  // fully transparent click-catch layer: no dim, but clicking outside
  // the card still dismisses
  Rectangle {
    anchors.fill: parent
    color: "transparent"
    visible: root.active

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }
  }

  Rectangle {
    id: card

    readonly property real cardWidth: 560
    readonly property real maxHeight: root.height - Math.round(root.height * 0.22) - 48

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Math.round(parent.height * 0.22)
    width: Math.min(cardWidth, parent.width - 48)
    height: Math.min(
      searchField.height + 16 + listView.clipHeight + 16,
      maxHeight)
    radius: 12
    color: Color.base
    border.color: Color.surface0
    border.width: 1

    MouseArea {
      // swallow clicks so they don't dismiss
      anchors.fill: parent
      onClicked: searchField.forceActiveFocus()
    }

    Column {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 16

      TextField {
        id: searchField

        property var allEntries: DesktopEntries.applications.values || []
        property var results: AppSearch.search(allEntries, text)
        // reset selection whenever the result set changes
        onResultsChanged: listView.currentIndex = 0

        function clear() {
          text = ""
        }

        width: parent.width
        placeholderText: "Search apps…"
        placeholderTextColor: Color.overlay0
        color: Color.text
        font.family: Style.fontFamily
        font.pixelSize: 16
        selectByMouse: true
        background: Rectangle {
          color: Color.mantle
          radius: 8
          border.color: searchField.activeFocus ? Color.mauve : Color.surface0
          border.width: 1
        }

        Keys.onPressed: event => {
          // Ctrl+A selects all (not provided by the bare TextField on
          // wayland sessions without a platform theme)
          if (event.key === Qt.Key_A && event.modifiers & Qt.ControlModifier) {
            selectAll()
            event.accepted = true
          } else if (event.key === Qt.Key_Escape) {
            root.close()
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.launch(listView.currentItem ? listView.currentItem.entry : null)
            event.accepted = true
          } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !event.modifiers)) {
            listView.incrementCurrentIndex()
            event.accepted = true
          } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier)) {
            listView.decrementCurrentIndex()
            event.accepted = true
          }
        }
      }

      ListView {
        id: listView

        readonly property real rowHeight: 44
        // natural content height, capped by the space the card can spare
        readonly property real clipHeight: Math.min(
          count * rowHeight,
          card.maxHeight - searchField.height - 16 - 32)

        width: parent.width
        height: clipHeight
        clip: true
        model: searchField.results
        currentIndex: 0
        keyNavigationEnabled: false

        delegate: Rectangle {
          id: row

          required property var modelData
          required property int index

          readonly property var entry: modelData

          width: listView.width
          height: listView.rowHeight
          radius: 8
          color: ListView.isCurrentItem ? Color.surface0
            : rowMouse.containsMouse ? Color.mantle
            : "transparent"

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 12

            IconImage {
              anchors.verticalCenter: parent.verticalCenter
              source: {
                const icon = String(row.entry.icon || "")
                if (icon.startsWith("/") || icon.startsWith("file://") || icon.startsWith("image://"))
                  return icon
                const themed = Quickshell.iconPath(icon, true)
                return themed.length > 0 ? themed
                  : Quickshell.iconPath("application-x-executable", true)
              }
              implicitSize: 26
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 26 - 12

              Text {
                width: parent.width
                text: row.entry.name
                color: ListView.isCurrentItem ? Color.rosewater : Color.text
                font.family: Style.fontFamily
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
              }

              Text {
                width: parent.width
                visible: text.length > 0
                text: row.entry.comment || ""
                color: Color.subtext0
                font.family: Style.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
              }
            }
          }

          MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.launch(row.entry)
          }
        }
      }

      Text {
        visible: searchField.results.length === 0
        text: "No matches"
        color: Color.overlay0
        font.family: Style.fontFamily
        font.pixelSize: 13
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }
  }
}
