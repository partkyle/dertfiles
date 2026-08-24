pragma Singleton

import QtQuick

// Catppuccin Mocha palette, matching the old waybar mocha.css theme.
QtObject {
  // surfaces
  readonly property color crust: "#11111b"
  readonly property color mantle: "#181825"
  readonly property color base: "#1e1e2e"
  readonly property color surface0: "#313244"

  // text
  readonly property color text: "#cdd6f4"
  readonly property color subtext0: "#a6adc8"
  readonly property color overlay0: "#6c7086"
  readonly property color overlay1: "#7f849c"

  // accents
  readonly property color rosewater: "#f5e0dc"
  readonly property color mauve: "#cba6f7"
  readonly property color blue: "#89b4fa"
  readonly property color sky: "#89dceb"
  readonly property color peach: "#fab387"
  readonly property color yellow: "#f9e2af"
  readonly property color green: "#a6e3a1"
  readonly property color red: "#f38ba8"
  readonly property color maroon: "#eba0ac"
  readonly property color lavender: "#b4befe"

  // bar chrome
  readonly property color barBackground: crust
  readonly property color barBorder: overlay1
  readonly property color barText: overlay0
  readonly property color hoverText: mauve

  // waybar's focused-workspace background: rgba(0,0,0,0.3)
  readonly property color workspaceFocused: Qt.rgba(0, 0, 0, 0.3)
  readonly property color urgent: "#eb4d4b"

}
