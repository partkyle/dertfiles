import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Commons

// Brightness popup, opened by the bar's brightness module. It is a
// full-screen overlay rather than a PopupWindow because a PopupWindow cannot
// attach an xdg_popup to the layer-shell bar: it would not position below the
// bar and a grabbing popup fails outright. The transparent overlay catches
// clicks outside the card (dismissing it) and holds keyboard focus so the
// percentage can be typed.
PanelWindow {
  id: root

  // Fill the screen; the card is positioned inside.
  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  visible: Brightness.panelOpen
  screen: Brightness.panelScreen
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  focusable: true

  WlrLayershell.namespace: "partkyle-brightness"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  // Apply a typed value when the popup closes, instead of silently dropping
  // it. Escape cancels first (see TextInput), so this is a no-op then.
  onVisibleChanged: if (!visible) valueField.commit()

  // Clicking anywhere but the card closes the popup. The card is declared
  // after this, so it (and its controls) sit above the catcher.
  MouseArea {
    anchors.fill: parent
    onClicked: Brightness.closePanel()
  }

  Rectangle {
    id: card

    anchors.top: parent.top
    anchors.topMargin: Style.barHeight + Style.moduleHSpacing
    anchors.right: parent.right
    anchors.rightMargin: Brightness.panelRightMargin
    width: 240
    height: content.implicitHeight + 24
    radius: 8
    color: Color.base
    border.width: 2
    border.color: Color.yellow
    focus: true
    Keys.onEscapePressed: Brightness.closePanel()

    // Consume clicks that land on the card but not on a control, so they do
    // not fall through to the dismiss catcher.
    MouseArea {
      anchors.fill: parent
    }

    Column {
      id: content
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.margins: 12
      spacing: 10

      Text {
        text: "Brightness"
        color: Color.overlay1
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSize
        font.bold: true
      }

      // Slider with the value to its right. The value doubles as a text
      // field: click it to type an exact percentage, Enter or focus loss to
      // apply, Escape to cancel.
      Item {
        id: sliderRow
        width: parent.width
        height: 22

        Item {
          id: valueField
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          width: 48
          height: parent.height
          property bool editing: false

          function beginEdit() {
            valueInput.text = String(Brightness.percent)
            editing = true
            valueInput.forceActiveFocus()
            valueInput.selectAll()
          }

          function commit() {
            if (!editing)
              return
            editing = false
            valueInput.focus = false
            const value = parseInt(valueInput.text)
            if (!isNaN(value))
              Brightness.setPercent(value)
          }

          function cancel() {
            editing = false
            valueInput.focus = false
          }

          Text {
            anchors.fill: parent
            visible: !valueField.editing
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            text: Brightness.percent + "%"
            color: valueMouse.containsMouse ? Color.hoverText : Color.text
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSize
            font.bold: true

            MouseArea {
              id: valueMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: valueField.beginEdit()
            }
          }

          TextInput {
            id: valueInput
            anchors.fill: parent
            visible: valueField.editing
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Color.text
            selectionColor: Color.mauve
            selectedTextColor: Color.base
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSize
            font.bold: true
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 0; top: 100 }
            onEditingFinished: valueField.commit()
            Keys.onEscapePressed: valueField.cancel()
          }
        }

        // Plain-Item slider so the shell keeps to QtQuick (no Controls
        // dependency) and matches the Catppuccin theme.
        Item {
          id: slider
          anchors.left: parent.left
          anchors.right: valueField.left
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          height: 22
          readonly property real value: Brightness.fraction

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Color.surface0

            Rectangle {
              width: Math.max(0, parent.width * slider.value)
              height: parent.height
              radius: parent.radius
              color: Color.yellow
            }
          }

          Rectangle {
            id: handle
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(slider.width - width, slider.value * slider.width - width / 2))
            width: 14
            height: 14
            radius: 7
            color: Color.text
            border.width: 2
            border.color: sliderMouse.containsMouse ? Color.hoverText : Color.yellow
          }

          MouseArea {
            id: sliderMouse
            anchors.fill: parent
            anchors.topMargin: -6
            anchors.bottomMargin: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function setFromX(px) {
              Brightness.setPercent(Math.max(0, Math.min(1, px / width)) * 100)
            }

            onPressed: mouse => setFromX(mouse.x)
            onPositionChanged: mouse => {
              if (pressed)
                setFromX(mouse.x)
            }
          }
        }
      }
    }
  }
}
