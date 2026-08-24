import QtQuick
import Quickshell.Io

import qs.Commons

// Base bar module: text label with the waybar look — module-colored text,
// 2px accent underline, mauve text + top border on hover. Emits clicked /
// rightClicked / scrolled signals that widgets wire to commands.
Rectangle {
  id: root

  property string label: ""
  property color accent: Color.barText
  property color labelColor: accent
  property bool underlineVisible: true
  // Collapsed widgets (e.g. battery on a desktop) take no space.
  readonly property bool hasLabel: label.length > 0

  signal clicked()
  signal rightClicked()
  signal scrollUp()
  signal scrollDown()

  function run(cmd) {
    runner.command = cmd
    runner.running = true
  }

  Process {
    id: runner
  }

  anchors.verticalCenter: parent ? parent.verticalCenter : undefined
  height: parent ? parent.height - Style.moduleVMargin * 2 : Style.barHeight
  implicitWidth: hasLabel ? textItem.implicitWidth + Style.moduleHPadding * 2 : 0
  visible: hasLabel
  color: mouseArea.containsMouse ? Color.surface0 : "transparent"

  // accent underline (waybar border-bottom: 2px <accent>)
  Rectangle {
    visible: root.hasLabel && root.underlineVisible
    anchors.bottom: parent.bottom
    width: parent.width
    height: Style.accentBorderWidth
    color: root.accent
  }

  // hover top border (waybar button:hover)
  Rectangle {
    visible: root.hasLabel && mouseArea.containsMouse
    anchors.top: parent.top
    width: parent.width
    height: Style.accentBorderWidth
    color: Color.hoverText
  }

  Text {
    id: textItem
    anchors.centerIn: parent
    text: root.label
    color: mouseArea.containsMouse ? Color.hoverText : root.labelColor
    font.family: Style.fontFamily
    font.pixelSize: Style.fontSize
    font.bold: true
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.hasLabel
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        root.rightClicked();
      else
        root.clicked();
    }
    onWheel: wheel => {
      if (wheel.angleDelta.y > 0)
        root.scrollUp();
      else
        root.scrollDown();
    }
  }
}
