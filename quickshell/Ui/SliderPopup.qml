import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Commons

// Shared slider popup behind the bar's brightness and volume modules. It is a
// full-screen overlay rather than a PopupWindow because a PopupWindow cannot
// attach an xdg_popup to the layer-shell bar: it would not position below the
// bar and a grabbing popup fails outright. The transparent overlay catches
// clicks outside the card (dismissing it) and holds keyboard focus so the
// percentage can be typed.
//
// The caller owns the state and the writes; this component only renders and
// reports intent through percentRequested/dismissRequested/muteToggled.
PanelWindow {
  id: root

  // Set by the caller; `screen` is PanelWindow's own property.
  property bool open: false
  property real rightMargin: 0

  property string title: ""
  property color accent: Colors.blue

  // Current value, mirrored from the caller.
  property real fraction: 0
  property int percent: 0

  // Optional mute toggle, used by volume only.
  property bool showMute: false
  property bool muted: false
  property string muteLabel: ""

  signal percentRequested(real value)
  signal dismissRequested()
  signal muteToggled()

  // Fill the screen; the card is positioned inside.
  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  visible: root.open
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  focusable: true

  WlrLayershell.namespace: "partkyle-slider"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  // Apply a typed value when the popup closes, instead of silently dropping
  // it. Escape cancels first (see TextInput), so this is a no-op then.
  onVisibleChanged: if (!visible) valueField.commit()

  // Clicking anywhere but the card closes the popup. The card is declared
  // after this, so it (and its controls) sit above the catcher.
  MouseArea {
    anchors.fill: parent
    onClicked: root.dismissRequested()
  }

  Rectangle {
    id: card

    anchors.top: parent.top
    anchors.topMargin: Style.barHeight + Style.moduleHSpacing
    anchors.right: parent.right
    anchors.rightMargin: root.rightMargin
    width: 240
    height: content.implicitHeight + 24
    radius: 8
    color: Colors.base
    border.width: 2
    border.color: root.accent
    focus: true
    Keys.onEscapePressed: root.dismissRequested()

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

      // Title with an optional mute toggle on the right.
      Item {
        width: parent.width
        height: 20

        Text {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          text: root.title
          color: Colors.overlay1
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSize
          font.bold: true
        }

        Text {
          id: muteButton
          visible: root.showMute
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: root.muteLabel
          color: muteMouse.containsMouse
            ? Colors.hoverText
            : root.muted ? Colors.red : Colors.overlay1
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSize - 2
          font.bold: true

          MouseArea {
            id: muteMouse
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.muteToggled()
          }
        }
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
            valueInput.text = String(root.percent)
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
              root.percentRequested(value)
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
            text: root.percent + "%"
            color: valueMouse.containsMouse ? Colors.hoverText : Colors.text
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
            color: Colors.text
            selectionColor: Colors.mauve
            selectedTextColor: Colors.base
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

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Colors.surface0

            Rectangle {
              width: Math.max(0, parent.width * root.fraction)
              height: parent.height
              radius: parent.radius
              color: root.accent
            }
          }

          Rectangle {
            id: handle
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(slider.width - width, root.fraction * slider.width - width / 2))
            width: 14
            height: 14
            radius: 7
            color: Colors.text
            border.width: 2
            border.color: sliderMouse.containsMouse ? Colors.hoverText : root.accent
          }

          MouseArea {
            id: sliderMouse
            anchors.fill: parent
            anchors.topMargin: -6
            anchors.bottomMargin: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function setFromX(px) {
              root.percentRequested(Math.max(0, Math.min(1, px / width)) * 100)
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
