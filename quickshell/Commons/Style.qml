pragma Singleton

import QtQuick

// Shared sizing/typography for the shell. Mirrors the metrics of the
// waybar config this replaces (Maple Mono NF, 14px bold).
QtObject {
  readonly property int barHeight: 34
  readonly property int fontSize: 14
  readonly property string fontFamily: "Maple Mono NF"

  // Per-module horizontal padding, matching the waybar CSS
  // (margin 4px + padding 4px each side).
  readonly property int moduleHPadding: 4
  readonly property int moduleHSpacing: 8
  readonly property int moduleVMargin: 2

  // The 2px accent underline each module carried in waybar.
  readonly property int accentBorderWidth: 2
}
