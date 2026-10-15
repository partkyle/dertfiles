import QtQuick
import Quickshell
import Quickshell.WindowManager

import qs.Commons

// Workspaces (mango tags) on this screen: digits with the focused one
// highlighted, click to activate. Driven by the generic ext-workspace
// protocol through Quickshell.WindowManager, so it is compositor-agnostic.
Row {
  id: root

  // The screen this bar belongs to, used to pick the right ext-workspace
  // projection. Falls back to the global list when unset.
  property var screen: null

  spacing: 2

  // Windowset = one ext-workspace (a mango tag). Only show the ones the
  // compositor marks visible: mango hides empty tags, so this is the occupied
  // tags plus the active one. (Hyprland only hides special workspaces, so
  // there it still shows all of them.) Sort by coordinate, falling back to
  // the numeric name.
  readonly property var windowsets: {
    const projection = root.screen ? WindowManager.screenProjection(root.screen) : null
    const source = projection && projection.windowsets.length
      ? projection.windowsets
      : WindowManager.windowsets
    const list = []
    for (let i = 0; i < source.length; i++) {
      if (source[i].shouldDisplay)
        list.push(source[i])
    }
    list.sort((a, b) => {
      const ac = a.coordinates && a.coordinates.length ? a.coordinates[0] : parseInt(a.name)
      const bc = b.coordinates && b.coordinates.length ? b.coordinates[0] : parseInt(b.name)
      return ac - bc
    })
    return list
  }

  Repeater {
    model: root.windowsets

    delegate: Rectangle {
      id: wsButton

      required property var modelData

      readonly property bool focused: modelData.active
      readonly property bool urgent: modelData.urgent

      anchors.verticalCenter: parent ? parent.verticalCenter : undefined
      height: parent ? parent.height - Style.moduleVMargin * 2 : Style.barHeight
      implicitWidth: wsLabel.implicitWidth + 8
      color: wsMouse.containsMouse ? Color.surface0 : "transparent"

      // hover top border, like waybar's button:hover
      Rectangle {
        visible: wsMouse.containsMouse
        anchors.top: parent.top
        width: parent.width
        height: Style.accentBorderWidth
        color: Color.hoverText
      }

      Text {
        id: wsLabel
        anchors.centerIn: parent
        text: wsButton.modelData.name
        color: wsButton.focused
          ? Color.mauve
          : wsButton.urgent ? Color.peach
          : wsMouse.containsMouse ? Color.hoverText : Color.barText
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize
        font.bold: true
      }

      MouseArea {
        id: wsMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: wsButton.modelData.activate()
      }
    }
  }
}
